import assert from "node:assert/strict";
import test from "node:test";
import vm from "node:vm";
import worker, { KeyStore } from "../src/index.js";

class MemoryStorage {
  constructor() {
    this.values = new Map();
    this.alarm = null;
    this.listLimits = [];
  }

  async get(key) {
    const value = this.values.get(key);
    return value === undefined ? undefined : structuredClone(value);
  }

  async put(key, value) {
    this.values.set(key, structuredClone(value));
  }

  async delete(keys) {
    for (const key of Array.isArray(keys) ? keys : [keys]) this.values.delete(key);
  }

  async list(options = {}) {
    this.listLimits.push(options.limit);
    const entries = [...this.values.entries()]
      .sort(([left], [right]) => left.localeCompare(right))
      .filter(([key]) => !options.prefix || key.startsWith(options.prefix))
      .filter(([key]) => !options.startAfter || key > options.startAfter)
      .slice(0, options.limit || Number.MAX_SAFE_INTEGER);
    return new Map(entries);
  }

  async getAlarm() {
    return this.alarm;
  }

  async setAlarm(value) {
    this.alarm = value;
  }
}

async function call(store, path, body) {
  const response = await store.fetch(new Request(`https://key-store.internal${path}`, {
    method: body ? "POST" : "GET",
    headers: body ? { "Content-Type": "application/json" } : undefined,
    body: body ? JSON.stringify(body) : undefined,
  }));
  return { status: response.status, body: await response.json() };
}

function sessionRequest(provider, userId, clientKey = "c".repeat(64)) {
  return { provider, userId, clientKey };
}

function bindingFor(store) {
  return {
    idFromName(name) {
      return name;
    },
    get() {
      return {
        fetch(url, init) {
          return store.fetch(new Request(url, init));
        },
      };
    },
  };
}

function neverRespond(_input, init = {}) {
  return new Promise((_resolve, reject) => {
    const abort = () => {
      const error = new Error("aborted");
      error.name = "AbortError";
      reject(error);
    };
    if (init.signal?.aborted) abort();
    else init.signal?.addEventListener("abort", abort, { once: true });
  });
}

test("creates, completes and verifies a 24-hour key", async () => {
  const storage = new MemoryStorage();
  const store = new KeyStore({ storage }, { SESSION_TTL_SECONDS: "900", KEY_TTL_SECONDS: "86400" });

  const created = await call(store, "/session", sessionRequest("workink", "123456"));
  assert.equal(created.status, 200);
  assert.match(created.body.sessionId, /^[a-f0-9]{32}$/);

  const completed = await call(store, "/complete", {
    sessionId: created.body.sessionId,
    provider: "workink",
    proofId: "11111111-2222-4333-8444-555555555555",
  });
  assert.equal(completed.status, 200);
  assert.match(completed.body.key, /^NOTH-[A-Z0-9]{4}(?:-[A-Z0-9]{4}){4}$/);

  const valid = await call(store, "/verify", { key: completed.body.key, userId: "123456" });
  assert.equal(valid.status, 200);
  assert.equal(valid.body.ok, true);
  assert.equal(valid.body.provider, "workink");
  assert.ok(valid.body.ttlSeconds > 86390);
  assert.match(valid.body.lease, /^NLEASE-[a-f0-9]{64}$/);

  const repeatedKey = await call(store, "/verify", { key: completed.body.key, userId: "123456" });
  assert.equal(repeatedKey.status, 200);
  assert.equal(repeatedKey.body.ok, true);
  assert.equal(repeatedKey.body.lease, valid.body.lease);
  assert.equal((await storage.list({ prefix: "lease:" })).size, 1);

  const cachedLease = await call(store, "/verify", { lease: valid.body.lease, userId: "123456" });
  assert.equal(cachedLease.status, 200);
  assert.equal(cachedLease.body.ok, true);
  assert.equal(cachedLease.body.lease, valid.body.lease);

  const wrongUser = await call(store, "/verify", { key: completed.body.key, userId: "654321" });
  assert.equal(wrongUser.status, 401);
  assert.equal(wrongUser.body.ok, false);
});

test("issues an owner test key only with the admin secret and binds it to one UserId", async () => {
  const storage = new MemoryStorage();
  const keyStore = new KeyStore({ storage }, { KEY_TTL_SECONDS: "86400" });
  const secret = "s".repeat(64);
  const env = {
    ADMIN_ISSUE_SECRET: secret,
    KEY_STORE: bindingFor(keyStore),
  };
  const request = new Request("https://nothrilo.test/v1/nothrilo/key/admin/issue", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${secret}`,
      "CF-Connecting-IP": "203.0.113.25",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ userId: "123456789" }),
  });
  const response = await worker.fetch(request, env);
  assert.equal(response.status, 200);
  assert.match(response.headers.get("cache-control"), /no-store/);
  assert.equal(response.headers.get("access-control-allow-origin"), null);
  const issued = await response.json();
  assert.equal(issued.ok, true);
  assert.equal(issued.userId, "123456789");
  assert.equal(issued.provider, "owner-test");
  assert.match(issued.key, /^NOTH-[A-Z0-9]{4}(?:-[A-Z0-9]{4}){4}$/);
  assert.ok(issued.ttlSeconds > 86390 && issued.ttlSeconds <= 86400);

  const valid = await worker.fetch(new Request("https://nothrilo.test/v1/nothrilo/key/verify", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ key: issued.key, userId: "123456789" }),
  }), env);
  assert.equal(valid.status, 200);
  assert.equal((await valid.json()).provider, "owner-test");

  const wrongUser = await worker.fetch(new Request("https://nothrilo.test/v1/nothrilo/key/verify", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ key: issued.key, userId: "987654321" }),
  }), env);
  assert.equal(wrongUser.status, 401);
});

test("rejects missing or incorrect admin secrets before touching Durable Object state", async () => {
  let bindingCalls = 0;
  const env = {
    ADMIN_ISSUE_SECRET: "a".repeat(64),
    KEY_STORE: {
      idFromName() {
        bindingCalls += 1;
        return "unused";
      },
    },
  };

  for (const authorization of [undefined, `Bearer ${"b".repeat(64)}`]) {
    const headers = { "Content-Type": "application/json" };
    if (authorization) headers.Authorization = authorization;
    const response = await worker.fetch(new Request("https://nothrilo.test/v1/nothrilo/key/admin/issue", {
      method: "POST",
      headers,
      body: JSON.stringify({ userId: "123456789" }),
    }), env);
    assert.equal(response.status, 401);
    assert.match(response.headers.get("www-authenticate"), /^Bearer /);
    assert.match(response.headers.get("cache-control"), /no-store/);
  }
  assert.equal(bindingCalls, 0);
});

test("rejects an oversized admin issuance body even without Content-Length", async () => {
  let bindingCalls = 0;
  const secret = "z".repeat(64);
  const env = {
    ADMIN_ISSUE_SECRET: secret,
    KEY_STORE: {
      idFromName() {
        bindingCalls += 1;
        return "unused";
      },
    },
  };
  const request = new Request("https://nothrilo.test/v1/nothrilo/key/admin/issue", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${secret}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ userId: "123", padding: "x".repeat(2000) }),
  });
  request.headers.delete("Content-Length");
  const response = await worker.fetch(request, env);
  assert.equal(response.status, 413);
  assert.equal((await response.json()).error, "request_too_large");
  assert.equal(bindingCalls, 0);
});

test("rate limits manual owner key issuance by IP and returns Retry-After", async () => {
  const storage = new MemoryStorage();
  const keyStore = new KeyStore({ storage }, {
    KEY_TTL_SECONDS: "86400",
    ADMIN_ISSUE_RATE_WINDOW_SECONDS: "600",
    ADMIN_ISSUE_RATE_IP_LIMIT: "2",
    ADMIN_ISSUE_RATE_USER_LIMIT: "10",
  });
  const secret = "r".repeat(64);
  const env = { ADMIN_ISSUE_SECRET: secret, KEY_STORE: bindingFor(keyStore) };

  async function issue(userId) {
    return worker.fetch(new Request("https://nothrilo.test/v1/nothrilo/key/admin/issue", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${secret}`,
        "CF-Connecting-IP": "198.51.100.50",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ userId }),
    }), env);
  }

  assert.equal((await issue("1")).status, 200);
  assert.equal((await issue("2")).status, 200);
  const limited = await issue("3");
  assert.equal(limited.status, 429);
  assert.ok(Number(limited.headers.get("retry-after")) > 0);
  assert.deepEqual((await limited.json()).error, "rate_limited");
});

test("manual owner keys really expire instead of becoming permanent", async () => {
  const storage = new MemoryStorage();
  const keyStore = new KeyStore({ storage }, { KEY_TTL_SECONDS: "86400" });
  const secret = "e".repeat(64);
  const env = { ADMIN_ISSUE_SECRET: secret, KEY_STORE: bindingFor(keyStore) };
  const issuedResponse = await worker.fetch(new Request("https://nothrilo.test/v1/nothrilo/key/admin/issue", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${secret}`,
      "CF-Connecting-IP": "192.0.2.10",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ userId: "123456789" }),
  }), env);
  const issued = await issuedResponse.json();
  const keyEntries = await storage.list({ prefix: "key:" });
  assert.equal(keyEntries.size, 1);
  const [keyRecordKey, keyRecord] = [...keyEntries.entries()][0];
  keyRecord.expiresAt = Date.now() - 1;
  await storage.put(keyRecordKey, keyRecord);

  const expired = await worker.fetch(new Request("https://nothrilo.test/v1/nothrilo/key/verify", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ key: issued.key, userId: "123456789" }),
  }), env);
  assert.equal(expired.status, 401);
  assert.deepEqual(await expired.json(), { ok: false, error: "invalid_key" });
});

test("expires both key and lease and requires a fresh completion", async () => {
  const storage = new MemoryStorage();
  const store = new KeyStore({ storage }, { SESSION_TTL_SECONDS: "900", KEY_TTL_SECONDS: "86400" });

  const firstSession = await call(store, "/session", sessionRequest("workink", "123456"));
  const firstCompletion = await call(store, "/complete", {
    sessionId: firstSession.body.sessionId,
    provider: "workink",
    proofId: "21111111-2222-4333-8444-555555555555",
  });
  const firstVerification = await call(store, "/verify", {
    key: firstCompletion.body.key,
    userId: "123456",
  });
  assert.equal(firstVerification.status, 200);

  for (const [storageKey, record] of storage.values) {
    if (storageKey.startsWith("key:") || storageKey.startsWith("lease:")) {
      record.expiresAt = Date.now() - 1;
      storage.values.set(storageKey, record);
    }
  }

  const expiredKey = await call(store, "/verify", {
    key: firstCompletion.body.key,
    userId: "123456",
  });
  assert.equal(expiredKey.status, 401);
  assert.equal(expiredKey.body.error, "invalid_key");

  const expiredLease = await call(store, "/verify", {
    lease: firstVerification.body.lease,
    userId: "123456",
  });
  assert.equal(expiredLease.status, 401);
  assert.equal(expiredLease.body.error, "invalid_lease");

  const nextSession = await call(store, "/session", sessionRequest("workink", "123456"));
  const nextCompletion = await call(store, "/complete", {
    sessionId: nextSession.body.sessionId,
    provider: "workink",
    proofId: "31111111-2222-4333-8444-555555555555",
  });
  assert.equal(nextCompletion.status, 200);
  assert.notEqual(nextCompletion.body.key, firstCompletion.body.key);
});

test("serializes concurrent lease creation for one key", async () => {
  const storage = new MemoryStorage();
  const store = new KeyStore({ storage }, { SESSION_TTL_SECONDS: "900", KEY_TTL_SECONDS: "86400" });
  const created = await call(store, "/session", sessionRequest("workink", "123456"));
  const completed = await call(store, "/complete", {
    sessionId: created.body.sessionId,
    provider: "workink",
    proofId: "11111111-2222-4333-8444-555555555555",
  });

  const results = await Promise.all(Array.from({ length: 20 }, () => (
    call(store, "/verify", { key: completed.body.key, userId: "123456" })
  )));
  assert.equal(results.every((result) => result.status === 200), true);
  assert.equal(new Set(results.map((result) => result.body.lease)).size, 1);
  assert.equal((await storage.list({ prefix: "lease:" })).size, 1);
});

test("does not allow one provider proof to issue two keys", async () => {
  const storage = new MemoryStorage();
  const store = new KeyStore({ storage }, { SESSION_TTL_SECONDS: "900", KEY_TTL_SECONDS: "86400" });
  const first = await call(store, "/session", sessionRequest("linkvertise", "10"));
  const second = await call(store, "/session", sessionRequest("linkvertise", "20"));
  const proof = "a".repeat(64);

  const accepted = await call(store, "/complete", {
    sessionId: first.body.sessionId,
    provider: "linkvertise",
    proofId: proof,
  });
  assert.equal(accepted.status, 200);

  const rejected = await call(store, "/complete", {
    sessionId: second.body.sessionId,
    provider: "linkvertise",
    proofId: proof,
  });
  assert.equal(rejected.status, 409);
  assert.equal(rejected.body.error, "proof_already_used");
});

test("atomically consumes one proof under concurrent completions", async () => {
  const storage = new MemoryStorage();
  const store = new KeyStore({ storage }, { SESSION_TTL_SECONDS: "900", KEY_TTL_SECONDS: "86400" });
  const sessions = await Promise.all(Array.from({ length: 8 }, (_, index) => (
    call(store, "/session", sessionRequest("linkvertise", String(index + 1)))
  )));
  const proof = "b".repeat(64);

  const results = await Promise.all(sessions.map((session) => call(store, "/complete", {
    sessionId: session.body.sessionId,
    provider: "linkvertise",
    proofId: proof,
  })));
  assert.equal(results.filter((result) => result.status === 200).length, 1);
  assert.equal(results.filter((result) => result.status === 409).length, 7);
  assert.equal((await storage.list({ prefix: "key:" })).size, 1);
  assert.equal((await storage.list({ prefix: "proof:" })).size, 1);
});

test("rejects invalid providers and expired sessions", async () => {
  const storage = new MemoryStorage();
  const store = new KeyStore({ storage }, { SESSION_TTL_SECONDS: "300", KEY_TTL_SECONDS: "86400" });
  const invalid = await call(store, "/session", sessionRequest("unknown", "123"));
  assert.equal(invalid.status, 400);

  const created = await call(store, "/session", sessionRequest("lootlabs", "123"));
  const record = await storage.get(`session:${created.body.sessionId}`);
  record.expiresAt = Date.now() - 1;
  await storage.put(`session:${created.body.sessionId}`, record);

  const expired = await call(store, "/complete", {
    sessionId: created.body.sessionId,
    provider: "lootlabs",
    proofId: "unique-proof",
  });
  assert.equal(expired.status, 410);
  assert.equal(expired.body.error, "expired_session");
});

test("root route returns an HTML response", async () => {
  const response = await worker.fetch(new Request("https://nothrilo.test/"), {});
  assert.equal(response.status, 200);
  assert.match(response.headers.get("content-type"), /^text\/html/);
  assert.match(await response.text(), /Nothrilo Key/);
});

test("handles malformed session cookies without throwing", async () => {
  const request = new Request("https://nothrilo.test/v1/nothrilo/key/status", {
    headers: { Cookie: "nothrilo_key_session=%" },
  });
  const response = await worker.fetch(request, {});
  assert.equal(response.status, 401);
  assert.deepEqual(await response.json(), { ok: false, error: "missing_session" });
});

test("stops LootLabs pending polling after about 60 seconds", async () => {
  const response = await worker.fetch(new Request("https://nothrilo.test/v1/nothrilo/key/callback/lootlabs"), {});
  const page = await response.text();
  const script = page.match(/<script>([\s\S]*?)<\/script>/)?.[1];
  assert.ok(script);

  const scheduled = [];
  let fetchCalls = 0;
  const elements = {
    status: { className: "", textContent: "" },
    result: { innerHTML: "" },
  };
  vm.runInNewContext(script, {
    document: { getElementById: (id) => elements[id] },
    fetch: async () => {
      fetchCalls += 1;
      return { json: async () => ({ ok: false, error: "pending", status: "pending" }) };
    },
    setTimeout: (callback) => scheduled.push(callback),
    navigator: { clipboard: { writeText: async () => {} } },
  });
  await new Promise((resolve) => setImmediate(resolve));
  while (scheduled.length > 0) {
    const callback = scheduled.shift();
    await callback();
  }

  assert.equal(fetchCalls, 40);
  assert.match(elements.status.textContent, /demorou demais/);
  assert.equal(scheduled.length, 0);
});

test("rate limits starts by IP, user and pair without blocking normal retries", async () => {
  const storage = new MemoryStorage();
  const store = new KeyStore({ storage }, {
    SESSION_TTL_SECONDS: "900",
    KEY_TTL_SECONDS: "86400",
    START_RATE_IP_LIMIT: "30",
    START_RATE_USER_LIMIT: "10",
    START_RATE_PAIR_LIMIT: "3",
    MAX_PENDING_IP: "20",
    MAX_PENDING_USER: "10",
    MAX_PENDING_PAIR: "10",
  });
  const request = sessionRequest("linkvertise", "42");
  for (let attempt = 0; attempt < 3; attempt += 1) {
    assert.equal((await call(store, "/session", request)).status, 200);
  }
  const limited = await call(store, "/session", request);
  assert.equal(limited.status, 429);
  assert.equal(limited.body.error, "rate_limited");
  assert.ok(limited.body.retryAfter > 0);
});

test("releases pending quota after a session completes", async () => {
  const storage = new MemoryStorage();
  const store = new KeyStore({ storage }, {
    SESSION_TTL_SECONDS: "900",
    KEY_TTL_SECONDS: "86400",
    START_RATE_IP_LIMIT: "30",
    START_RATE_USER_LIMIT: "10",
    START_RATE_PAIR_LIMIT: "10",
    MAX_PENDING_IP: "20",
    MAX_PENDING_USER: "2",
    MAX_PENDING_PAIR: "2",
  });
  const request = sessionRequest("linkvertise", "99");
  const first = await call(store, "/session", request);
  assert.equal(first.status, 200);
  assert.equal((await call(store, "/session", request)).status, 200);
  const blocked = await call(store, "/session", request);
  assert.equal(blocked.status, 429);
  assert.equal(blocked.body.error, "too_many_pending");

  const completed = await call(store, "/complete", {
    sessionId: first.body.sessionId,
    provider: "linkvertise",
    proofId: "d".repeat(64),
  });
  assert.equal(completed.status, 200);
  assert.equal((await call(store, "/session", request)).status, 200);
});

test("rejects an unconfigured provider before touching Durable Object state", async () => {
  let bindingCalls = 0;
  const env = {
    LOOTLABS_URL: "REPLACE_AFTER_DEPLOY",
    KEY_STORE: {
      idFromName() {
        bindingCalls += 1;
        return "unused";
      },
    },
  };
  const request = new Request("https://nothrilo.test/v1/nothrilo/key/start?provider=lootlabs&userId=123", {
    headers: { "CF-Connecting-IP": "203.0.113.10" },
  });
  const response = await worker.fetch(request, env);
  assert.equal(response.status, 503);
  assert.equal(bindingCalls, 0);
});

test("starts a configured provider through the public Worker route", async () => {
  const storage = new MemoryStorage();
  const keyStore = new KeyStore({ storage }, { SESSION_TTL_SECONDS: "900", KEY_TTL_SECONDS: "86400" });
  const env = {
    SESSION_TTL_SECONDS: "900",
    LINKVERTISE_URL: "https://direct-link.net/123/example",
    KEY_STORE: bindingFor(keyStore),
  };
  const request = new Request("https://nothrilo.test/v1/nothrilo/key/start?provider=linkvertise&userId=123", {
    headers: { "CF-Connecting-IP": "203.0.113.10" },
  });
  const response = await worker.fetch(request, env);
  assert.equal(response.status, 302);
  assert.equal(response.headers.get("location"), env.LINKVERTISE_URL);
  assert.match(response.headers.get("set-cookie"), /nothrilo_key_session=[a-f0-9]{32}/);
  assert.equal((await storage.list({ prefix: "session:" })).size, 1);
});

test("times out an unresponsive provider and cancels its pending session", async () => {
  const storage = new MemoryStorage();
  const keyStore = new KeyStore({ storage }, { SESSION_TTL_SECONDS: "900", KEY_TTL_SECONDS: "86400" });
  const env = {
    SESSION_TTL_SECONDS: "900",
    PROVIDER_TIMEOUT_MS: "100",
    WORKINK_URL: "https://work.ink/example/nothrilo",
    WORKINK_LINK_ID: "123",
    KEY_STORE: bindingFor(keyStore),
  };
  const originalFetch = globalThis.fetch;
  globalThis.fetch = neverRespond;
  try {
    const request = new Request("https://nothrilo.test/v1/nothrilo/key/start?provider=workink&userId=123", {
      headers: { "CF-Connecting-IP": "203.0.113.10" },
    });
    const response = await worker.fetch(request, env);
    assert.equal(response.status, 502);
    assert.equal((await storage.list({ prefix: "session:" })).size, 0);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("times out Linkvertise verification without completing the session", async () => {
  const storage = new MemoryStorage();
  const keyStore = new KeyStore({ storage }, { SESSION_TTL_SECONDS: "900", KEY_TTL_SECONDS: "86400" });
  const created = await call(keyStore, "/session", sessionRequest("linkvertise", "123"));
  const env = {
    PROVIDER_TIMEOUT_MS: "100",
    LINKVERTISE_ANTI_BYPASS_TOKEN: "f".repeat(64),
    KEY_STORE: bindingFor(keyStore),
  };
  const originalFetch = globalThis.fetch;
  globalThis.fetch = neverRespond;
  try {
    const request = new Request(`https://nothrilo.test/v1/nothrilo/key/callback/linkvertise?hash=${"e".repeat(64)}`, {
      headers: { Cookie: `nothrilo_key_session=${created.body.sessionId}` },
    });
    const response = await worker.fetch(request, env);
    assert.equal(response.status, 502);
    const session = await storage.get(`session:${created.body.sessionId}`);
    assert.equal(session.status, "pending");
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("cleans expired records in bounded pages and reschedules remaining work", async () => {
  const storage = new MemoryStorage();
  const now = Date.now();
  for (let index = 0; index < 30; index += 1) {
    await storage.put(`expired:${String(index).padStart(2, "0")}`, { expiresAt: now - 1 });
  }
  await storage.put("live:record", { expiresAt: now + 60 * 60 * 1000 });
  const store = new KeyStore({ storage }, {
    CLEANUP_PAGE_SIZE: "8",
    CLEANUP_MAX_PAGES: "2",
    CLEANUP_INTERVAL_SECONDS: "900",
  });

  storage.listLimits = [];
  await store.alarm();
  assert.equal([...storage.values.keys()].filter((key) => key.startsWith("expired:")).length, 14);
  assert.equal(storage.listLimits.every((limit) => Number.isInteger(limit) && limit <= 8), true);
  assert.ok(storage.alarm <= Date.now() + 61 * 1000);

  storage.listLimits = [];
  await store.alarm();
  assert.equal([...storage.values.keys()].filter((key) => key.startsWith("expired:")).length, 0);
  assert.equal(storage.values.has("live:record"), true);
  assert.equal(storage.listLimits.every((limit) => Number.isInteger(limit) && limit <= 8), true);
});
