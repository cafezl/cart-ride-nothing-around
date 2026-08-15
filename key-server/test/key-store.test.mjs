import assert from "node:assert/strict";
import test from "node:test";
import { KeyStore } from "../src/index.js";

class MemoryStorage {
  constructor() {
    this.values = new Map();
    this.alarm = null;
  }

  async get(key) {
    return this.values.get(key);
  }

  async put(key, value) {
    this.values.set(key, structuredClone(value));
  }

  async delete(keys) {
    for (const key of Array.isArray(keys) ? keys : [keys]) this.values.delete(key);
  }

  async list(options = {}) {
    const entries = [...this.values.entries()]
      .filter(([key]) => !options.prefix || key.startsWith(options.prefix))
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

test("creates, completes and verifies a 24-hour key", async () => {
  const storage = new MemoryStorage();
  const store = new KeyStore({ storage }, { SESSION_TTL_SECONDS: "900", KEY_TTL_SECONDS: "86400" });

  const created = await call(store, "/session", { provider: "workink", userId: "123456" });
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

test("does not allow one provider proof to issue two keys", async () => {
  const storage = new MemoryStorage();
  const store = new KeyStore({ storage }, { SESSION_TTL_SECONDS: "900", KEY_TTL_SECONDS: "86400" });
  const first = await call(store, "/session", { provider: "linkvertise", userId: "10" });
  const second = await call(store, "/session", { provider: "linkvertise", userId: "20" });
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

test("rejects invalid providers and expired sessions", async () => {
  const storage = new MemoryStorage();
  const store = new KeyStore({ storage }, { SESSION_TTL_SECONDS: "300", KEY_TTL_SECONDS: "86400" });
  const invalid = await call(store, "/session", { provider: "unknown", userId: "123" });
  assert.equal(invalid.status, 400);

  const created = await call(store, "/session", { provider: "lootlabs", userId: "123" });
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
