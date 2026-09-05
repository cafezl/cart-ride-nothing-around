import {
  renderErrorPage,
  renderKeyPage,
  renderLandingPage,
  renderPendingPage,
} from "./ui.js";

const PRODUCT = "nothrilo";
const SESSION_COOKIE = "nothrilo_key_session";
const DEFAULT_SESSION_TTL = 15 * 60;
const DEFAULT_KEY_TTL = 24 * 60 * 60;
const DEFAULT_START_WINDOW = 10 * 60;
const DEFAULT_START_IP_LIMIT = 30;
const DEFAULT_START_USER_LIMIT = 10;
const DEFAULT_START_PAIR_LIMIT = 6;
const DEFAULT_PENDING_IP_LIMIT = 20;
const DEFAULT_PENDING_USER_LIMIT = 4;
const DEFAULT_PENDING_PAIR_LIMIT = 3;
const DEFAULT_CLEANUP_INTERVAL = 15 * 60;
const DEFAULT_CLEANUP_PAGE_SIZE = 128;
const DEFAULT_CLEANUP_MAX_PAGES = 16;
const DEFAULT_PROVIDER_TIMEOUT_MS = 10 * 1000;
const DEFAULT_PROVIDER_RESPONSE_MAX_BYTES = 64 * 1024;
const DEFAULT_ADMIN_ISSUE_WINDOW = 15 * 60;
const DEFAULT_ADMIN_ISSUE_IP_LIMIT = 6;
const DEFAULT_ADMIN_ISSUE_USER_LIMIT = 3;
const DEFAULT_VERIFY_WINDOW = 60;
const DEFAULT_VERIFY_IP_LIMIT = 60;
const DEFAULT_VERIFY_PAIR_LIMIT = 12;
const CLEANUP_CURSOR_KEY = "metadata:cleanup-cursor";

const encoder = new TextEncoder();

function corsHeaders() {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "content-type",
    "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
  };
}

function json(data, status = 200, headers = {}) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      "Cache-Control": "no-store",
      "X-Content-Type-Options": "nosniff",
      "Referrer-Policy": "no-referrer",
      ...corsHeaders(),
      ...headers,
    },
  });
}

function privateJson(data, status = 200, headers = {}) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      "Cache-Control": "no-store, max-age=0",
      Pragma: "no-cache",
      Expires: "0",
      "Referrer-Policy": "no-referrer",
      "X-Content-Type-Options": "nosniff",
      "X-Robots-Tag": "noindex, nofollow, noarchive",
      Vary: "Authorization",
      ...headers,
    },
  });
}

function html(page, status = 200, headers = {}) {
  return new Response(page.markup, {
    status,
    headers: {
      "Content-Type": "text/html; charset=utf-8",
      "Cache-Control": "no-store",
      "Content-Language": "pt-BR",
      "Referrer-Policy": "no-referrer",
      "X-Content-Type-Options": "nosniff",
      "X-Frame-Options": "DENY",
      "X-Permitted-Cross-Domain-Policies": "none",
      "X-Robots-Tag": "noindex, nofollow, noarchive",
      "Cross-Origin-Opener-Policy": "same-origin",
      "Cross-Origin-Resource-Policy": "same-origin",
      "Permissions-Policy": "camera=(), microphone=(), geolocation=(), payment=(), usb=()",
      "Content-Security-Policy": `default-src 'none'; connect-src 'self'; style-src 'nonce-${page.nonce}'; script-src 'nonce-${page.nonce}'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'; object-src 'none'; manifest-src 'none'`,
      ...headers,
    },
  });
}

function redirect(location, headers = {}) {
  return new Response(null, {
    status: 302,
    headers: {
      Location: location,
      "Cache-Control": "no-store",
      "Referrer-Policy": "no-referrer",
      "X-Content-Type-Options": "nosniff",
      ...headers,
    },
  });
}

function asPositiveInt(value, fallback, min = 1, max = Number.MAX_SAFE_INTEGER) {
  const parsed = Number.parseInt(String(value ?? ""), 10);
  if (!Number.isFinite(parsed)) return fallback;
  return Math.min(max, Math.max(min, parsed));
}

function normalizeUserId(value) {
  if (typeof value !== "string" && typeof value !== "number") return null;
  if (typeof value === "number" && (!Number.isSafeInteger(value) || value <= 0)) return null;
  const text = String(value).trim();
  if (!/^\d{1,20}$/.test(text)) return null;
  return text.replace(/^0+/, "") || null;
}

// Bound the actual stream, not just Content-Length or the decoded character
// count. Reading request.text()/json() first would already allocate the body.
async function readJsonBody(request, maxBytes) {
  const type = (request.headers.get("Content-Type") || "").split(";", 1)[0].trim().toLowerCase();
  if (type !== "application/json") return { error: "unsupported_media_type", status: 415 };
  const declared = Number(request.headers.get("Content-Length"));
  if (Number.isFinite(declared) && declared > maxBytes) {
    void request.body?.cancel().catch(() => {});
    return { error: "request_too_large", status: 413 };
  }
  if (!request.body) return { error: "invalid_json", status: 400 };
  const reader = request.body.getReader();
  const chunks = [];
  let size = 0;
  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      size += value.byteLength;
      if (size > maxBytes) {
        void reader.cancel().catch(() => {});
        return { error: "request_too_large", status: 413 };
      }
      chunks.push(value);
    }
    const bytes = new Uint8Array(size);
    let offset = 0;
    for (const chunk of chunks) {
      bytes.set(chunk, offset);
      offset += chunk.byteLength;
    }
    const body = JSON.parse(new TextDecoder("utf-8", { fatal: true }).decode(bytes));
    if (!body || typeof body !== "object" || Array.isArray(body)) {
      return { error: "invalid_json", status: 400 };
    }
    return { body };
  } catch {
    return { error: "invalid_json", status: 400 };
  } finally {
    reader.releaseLock();
  }
}

function normalizeProvider(value) {
  const provider = String(value ?? "").trim().toLowerCase();
  return ["workink", "lootlabs", "linkvertise"].includes(provider) ? provider : null;
}

function randomHex(bytes = 16) {
  const data = new Uint8Array(bytes);
  crypto.getRandomValues(data);
  return [...data].map((part) => part.toString(16).padStart(2, "0")).join("");
}

async function sha256Hex(value) {
  const digest = await crypto.subtle.digest("SHA-256", encoder.encode(String(value)));
  return [...new Uint8Array(digest)]
    .map((part) => part.toString(16).padStart(2, "0"))
    .join("");
}

async function secretsEqual(provided, configured) {
  const left = String(provided ?? "");
  const right = String(configured ?? "");
  if (left.length < 32 || left.length > 512 || right.length < 32 || right.length > 512) return false;
  const [leftDigest, rightDigest] = await Promise.all([
    crypto.subtle.digest("SHA-256", encoder.encode(left)),
    crypto.subtle.digest("SHA-256", encoder.encode(right)),
  ]);
  const leftBytes = new Uint8Array(leftDigest);
  const rightBytes = new Uint8Array(rightDigest);
  let difference = left.length === right.length ? 0 : 1;
  for (let index = 0; index < leftBytes.length; index += 1) {
    difference |= leftBytes[index] ^ rightBytes[index];
  }
  return difference === 0;
}

function readCookie(request, name) {
  const cookie = request.headers.get("Cookie") || "";
  for (const part of cookie.split(";")) {
    const index = part.indexOf("=");
    if (index < 0) continue;
    if (part.slice(0, index).trim() === name) {
      try {
        return decodeURIComponent(part.slice(index + 1).trim());
      } catch {
        return null;
      }
    }
  }
  return null;
}

function sessionCookie(sessionId, maxAge) {
  return `${SESSION_COOKIE}=${encodeURIComponent(sessionId)}; Max-Age=${maxAge}; Path=/; HttpOnly; Secure; SameSite=Lax`;
}

function clientAddress(request) {
  const value = String(request.headers.get("CF-Connecting-IP") || "").trim().toLowerCase();
  return /^[0-9a-f:.]{3,64}$/i.test(value) ? value : "unknown";
}

function appendQuery(urlString, name, value) {
  const url = new URL(urlString);
  url.searchParams.set(name, value);
  return url.href;
}

function providerLabel(provider) {
  return {
    workink: "Work.ink",
    lootlabs: "LootLabs",
    linkvertise: "Linkvertise",
  }[provider] || provider;
}

async function providerFetch(env, input, init = {}, responseType = "json") {
  const timeoutMs = asPositiveInt(env.PROVIDER_TIMEOUT_MS, DEFAULT_PROVIDER_TIMEOUT_MS, 100, 30 * 1000);
  const maxBytes = asPositiveInt(
    env.PROVIDER_RESPONSE_MAX_BYTES,
    DEFAULT_PROVIDER_RESPONSE_MAX_BYTES,
    256,
    256 * 1024,
  );
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const response = await fetch(input, { ...init, signal: controller.signal });
    const declared = Number(response.headers.get("Content-Length"));
    if (Number.isFinite(declared) && declared > maxBytes) {
      void response.body?.cancel().catch(() => {});
      throw new Error("provider_response_too_large");
    }
    const reader = response.body?.getReader();
    const chunks = [];
    let size = 0;
    if (reader) {
      try {
        while (true) {
          const { done, value } = await reader.read();
          if (done) break;
          size += value.byteLength;
          if (size > maxBytes) {
            void reader.cancel().catch(() => {});
            throw new Error("provider_response_too_large");
          }
          chunks.push(value);
        }
      } finally {
        reader.releaseLock();
      }
    }
    const bytes = new Uint8Array(size);
    let offset = 0;
    for (const chunk of chunks) {
      bytes.set(chunk, offset);
      offset += chunk.byteLength;
    }
    let text;
    try {
      text = new TextDecoder("utf-8", { fatal: true }).decode(bytes);
    } catch {
      text = "";
    }
    let body;
    if (responseType === "text") {
      body = text;
    } else {
      try {
        body = JSON.parse(text);
      } catch {
        body = null;
      }
    }
    return { response, body };
  } finally {
    clearTimeout(timeout);
  }
}

function configuredHttpsUrl(value, allowedHostnames) {
  const text = String(value || "").trim();
  let url;
  try {
    url = new URL(text);
  } catch {
    return null;
  }
  if (
    url.protocol !== "https:"
    || url.username
    || url.password
    || url.port
    || url.hash
    || !allowedHostnames.includes(url.hostname.toLowerCase())
  ) {
    return null;
  }
  return url.href;
}

function landingPage(origin) {
  return renderLandingPage(origin, randomHex(16));
}

function errorPage(message, status = 400, headers = {}) {
  return html(renderErrorPage(message, randomHex(16)), status, headers);
}

function keyPage(key, expiresAt, provider) {
  const expiry = new Date(expiresAt).toLocaleString("pt-BR", { timeZone: "America/Sao_Paulo" });
  return html(renderKeyPage({
    key,
    expiry,
    provider: providerLabel(provider),
    nonce: randomHex(16),
  }));
}

function pendingLootlabsPage() {
  return html(renderPendingPage(randomHex(16)));
}

async function internalRequest(env, path, init = {}) {
  const id = env.KEY_STORE.idFromName(PRODUCT);
  const stub = env.KEY_STORE.get(id);
  return stub.fetch(`https://key-store.internal${path}`, init);
}

async function createSession(env, provider, userId, clientKey) {
  const response = await internalRequest(env, "/session", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ provider, userId, clientKey }),
  });
  return { status: response.status, data: await response.json() };
}

async function cancelSession(env, sessionId) {
  const response = await internalRequest(env, "/cancel", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ sessionId }),
  });
  return { status: response.status, data: await response.json() };
}

async function completeSession(env, sessionId, provider, proofId) {
  const response = await internalRequest(env, "/complete", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ sessionId, provider, proofId }),
  });
  return { status: response.status, data: await response.json() };
}

async function getSessionStatus(env, sessionId) {
  const response = await internalRequest(env, `/status?session=${encodeURIComponent(sessionId)}`);
  return { status: response.status, data: await response.json() };
}

async function verifyIssuedKey(env, credential, userId, clientKey) {
  const response = await internalRequest(env, "/verify", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ ...credential, userId, clientKey }),
  });
  return { status: response.status, data: await response.json() };
}

async function issueManualOwnerKey(env, userId, clientKey) {
  const response = await internalRequest(env, "/manual-issue", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ userId, clientKey }),
  });
  return { status: response.status, data: await response.json() };
}

function providerConfiguration(env, provider) {
  if (provider === "workink") {
    const baseLink = configuredHttpsUrl(env.WORKINK_URL, ["work.ink"]);
    const expectedLinkId = String(env.WORKINK_LINK_ID || "").trim();
    return baseLink && /^\d{1,20}$/.test(expectedLinkId)
      ? { ok: true, baseLink }
      : { ok: false, message: "A opção Work.ink ainda não foi configurada." };
  }
  if (provider === "linkvertise") {
    const link = configuredHttpsUrl(env.LINKVERTISE_URL, ["linkvertise.com", "link-to.net", "direct-link.net"]);
    return link
      ? { ok: true, link }
      : { ok: false, message: "A opção Linkvertise ainda não foi configurada." };
  }
  const link = configuredHttpsUrl(env.LOOTLABS_URL, ["loot-link.com"]);
  return link
    ? { ok: true, link }
    : { ok: false, message: "A opção LootLabs ainda não foi configurada." };
}

async function startProvider(request, env, url) {
  const provider = normalizeProvider(url.searchParams.get("provider"));
  const userId = normalizeUserId(url.searchParams.get("userId") || url.searchParams.get("uid"));
  if (!provider || !userId) return errorPage("Provedor ou usuário inválido.");

  const configuration = providerConfiguration(env, provider);
  if (!configuration.ok) return errorPage(configuration.message, 503);

  const clientKey = await sha256Hex(`ip:${clientAddress(request)}`);
  const created = await createSession(env, provider, userId, clientKey);
  if (!created.data.ok) {
    if (created.status === 429) {
      const retryAfter = asPositiveInt(created.data.retryAfter, 60, 1, 3600);
      const message = created.data.error === "too_many_pending"
        ? "Você já tem tentativas abertas. Termine uma delas ou aguarde alguns minutos."
        : "Muitas tentativas em pouco tempo. Aguarde um pouco e tente novamente.";
      return errorPage(message, 429, { "Retry-After": String(retryAfter) });
    }
    return errorPage("Não foi possível iniciar esta sessão.", 503);
  }
  const sessionId = created.data.sessionId;
  const maxAge = asPositiveInt(env.SESSION_TTL_SECONDS, DEFAULT_SESSION_TTL, 300, 3600);
  const headers = { "Set-Cookie": sessionCookie(sessionId, maxAge) };

  if (provider === "workink") {
    const destination = `${url.origin}/v1/nothrilo/key/callback/workink?session=${encodeURIComponent(sessionId)}&token={TOKEN}`;
    const overrideUrl = `https://work.ink/_api/v2/override?destination=${encodeURIComponent(destination)}`;
    let overrideResponse;
    let override;
    try {
      const providerResult = await providerFetch(env, overrideUrl, { headers: { Accept: "application/json" } });
      overrideResponse = providerResult.response;
      override = providerResult.body;
    } catch {
      await cancelSession(env, sessionId).catch(() => null);
      return errorPage("Work.ink não respondeu ao iniciar a key.", 502);
    }
    if (!overrideResponse.ok) {
      await cancelSession(env, sessionId).catch(() => null);
      return errorPage("Work.ink não respondeu ao iniciar a key.", 502);
    }
    if (!override || typeof override.sr !== "string" || override.sr.length < 1 || override.sr.length > 2048) {
      await cancelSession(env, sessionId).catch(() => null);
      return errorPage("Work.ink retornou uma sessão inválida.", 502);
    }
    return redirect(appendQuery(configuration.baseLink, "sr", override.sr), headers);
  }

  if (provider === "linkvertise") {
    return redirect(configuration.link, headers);
  }

  return redirect(appendQuery(configuration.link, "puid", sessionId), headers);
}

async function workinkCallback(env, url) {
  const sessionId = String(url.searchParams.get("session") || "");
  const token = String(url.searchParams.get("token") || "");
  if (!/^[a-f0-9-]{20,80}$/i.test(sessionId) || !/^[a-f0-9-]{20,80}$/i.test(token)) {
    return errorPage("Token Work.ink inválido.");
  }
  const endpoint = `https://work.ink/_api/v2/token/isValid/${encodeURIComponent(token)}?deleteToken=1`;
  let response;
  let result;
  try {
    const providerResult = await providerFetch(env, endpoint, { headers: { Accept: "application/json" } });
    response = providerResult.response;
    result = providerResult.body;
  } catch {
    return errorPage("Work.ink demorou para responder. Tente novamente.", 502);
  }
  const expectedLinkId = String(env.WORKINK_LINK_ID || "").trim();
  const linkMatches = expectedLinkId !== "" && String(result?.info?.linkId ?? "") === expectedLinkId;
  const notExpired = Number(result?.info?.expiresAfter || 0) > Date.now();
  if (!response.ok || result?.valid !== true || result?.deleted !== true || !linkMatches || !notExpired) {
    return errorPage("A conclusão do Work.ink não pôde ser confirmada.", 403);
  }
  const completed = await completeSession(env, sessionId, "workink", token);
  if (!completed.data.ok) return errorPage("Esta conclusão já foi usada ou expirou.", completed.status);
  return keyPage(completed.data.key, completed.data.expiresAt, "workink");
}

async function linkvertiseCallback(request, env, url) {
  const sessionId = readCookie(request, SESSION_COOKIE);
  const hash = String(url.searchParams.get("hash") || "");
  const secret = String(env.LINKVERTISE_ANTI_BYPASS_TOKEN || "");
  if (!/^[a-f0-9]{32}$/i.test(sessionId || "") || !/^[a-f0-9]{64}$/i.test(hash) || secret.length !== 64) {
    return errorPage("Sessão ou hash Linkvertise inválido.");
  }
  const endpoint = new URL("https://publisher.linkvertise.com/api/v1/anti_bypassing");
  endpoint.searchParams.set("token", secret);
  endpoint.searchParams.set("hash", hash);
  let response;
  let verdict;
  try {
    const providerResult = await providerFetch(env, endpoint, { method: "POST" }, "text");
    response = providerResult.response;
    verdict = providerResult.body.trim().toUpperCase();
  } catch {
    return errorPage("Linkvertise demorou para responder. Tente novamente.", 502);
  }
  if (!response.ok || verdict !== "TRUE") return errorPage("A conclusão do Linkvertise não pôde ser confirmada.", 403);
  const completed = await completeSession(env, sessionId, "linkvertise", hash);
  if (!completed.data.ok) return errorPage("Esta conclusão já foi usada ou expirou.", completed.status);
  return keyPage(completed.data.key, completed.data.expiresAt, "linkvertise");
}

async function lootlabsPostback(env, url) {
  const configuredSecret = String(env.LOOTLABS_POSTBACK_SECRET || "");
  const providedSecret = String(url.searchParams.get("secret") || "");
  if (!await secretsEqual(providedSecret, configuredSecret)) return privateJson({ ok: false }, 403);
  const sessionId = String(url.searchParams.get("click_id") || url.searchParams.get("puid") || "");
  const uniqueId = String(url.searchParams.get("unique_id") || "");
  if (!/^[a-f0-9]{32}$/i.test(sessionId) || uniqueId.length < 6 || uniqueId.length > 256) {
    return json({ ok: false, error: "invalid_postback" }, 400);
  }
  const completed = await completeSession(env, sessionId, "lootlabs", uniqueId);
  return json({ ok: completed.data.ok }, completed.data.ok ? 200 : completed.status);
}

async function verifyKeyRequest(request, env) {
  const parsed = await readJsonBody(request, 2048);
  if (parsed.error) return json({ ok: false, error: parsed.error }, parsed.status);
  const { body } = parsed;
  const key = typeof body.key === "string" ? body.key.trim().toUpperCase() : "";
  const lease = typeof body.lease === "string" ? body.lease.trim() : "";
  const userId = normalizeUserId(body?.userId);
  const hasKey = /^NOTH-[A-Z0-9]{4}(?:-[A-Z0-9]{4}){4}$/.test(key);
  const hasLease = /^NLEASE-[a-f0-9]{64}$/i.test(lease);
  if ((body.key !== undefined) === (body.lease !== undefined) || (!hasKey && !hasLease) || !userId) {
    return json({ ok: false, error: "invalid_key" }, 401);
  }
  const clientKey = await sha256Hex(`verify-ip:${clientAddress(request)}`);
  const verified = await verifyIssuedKey(env, hasKey ? { key } : { lease }, userId, clientKey);
  const headers = verified.status === 429
    ? { "Retry-After": String(asPositiveInt(verified.data.retryAfter, 60, 1, 3600)) }
    : {};
  return json(verified.data, verified.status, headers);
}

async function manualOwnerIssueRequest(request, env) {
  const contentLength = Number.parseInt(request.headers.get("Content-Length") || "0", 10);
  if (Number.isFinite(contentLength) && contentLength > 1024) {
    return privateJson({ ok: false, error: "request_too_large" }, 413);
  }

  const authorization = String(request.headers.get("Authorization") || "");
  const providedSecret = authorization.startsWith("Bearer ") ? authorization.slice(7) : "";
  const configuredSecret = String(env.ADMIN_ISSUE_SECRET || "");
  if (!await secretsEqual(providedSecret, configuredSecret)) {
    return privateJson({ ok: false, error: "unauthorized" }, 401, {
      "WWW-Authenticate": 'Bearer realm="nothrilo-owner"',
    });
  }

  const parsed = await readJsonBody(request, 1024);
  if (parsed.error) return privateJson({ ok: false, error: parsed.error }, parsed.status);
  const { body } = parsed;
  const userId = normalizeUserId(body?.userId);
  if (!userId) return privateJson({ ok: false, error: "invalid_user_id" }, 400);

  const clientKey = await sha256Hex(`admin-ip:${clientAddress(request)}`);
  const issued = await issueManualOwnerKey(env, userId, clientKey);
  const headers = {};
  if (issued.status === 429) {
    headers["Retry-After"] = String(asPositiveInt(issued.data.retryAfter, 60, 1, 24 * 60 * 60));
  }
  return privateJson(issued.data, issued.status, headers);
}

export class KeyStore {
  constructor(state, env) {
    this.state = state;
    this.storage = state.storage;
    this.env = env;
    this.mutationQueue = Promise.resolve();
  }

  async withMutationLock(operation) {
    let release;
    const previous = this.mutationQueue;
    this.mutationQueue = new Promise((resolve) => {
      release = resolve;
    });
    await previous;
    try {
      return await operation();
    } finally {
      release();
    }
  }

  async ensureAlarm(delayMs) {
    const interval = asPositiveInt(this.env.CLEANUP_INTERVAL_SECONDS, DEFAULT_CLEANUP_INTERVAL, 60, 6 * 60 * 60) * 1000;
    const target = Date.now() + Math.min(Number(delayMs) > 0 ? Number(delayMs) : interval, interval);
    const alarm = await this.storage.getAlarm();
    if (alarm == null || alarm > target) await this.storage.setAlarm(target);
  }

  async removePendingSession(session) {
    const now = Date.now();
    const keys = Array.isArray(session?.pendingKeys) ? session.pendingKeys : [];
    for (const key of keys) {
      if (!/^pending:(?:ip|user|pair):[a-f0-9]{64}$/i.test(key)) continue;
      const record = await this.storage.get(key);
      if (!record || !Array.isArray(record.sessions)) continue;
      const sessions = record.sessions.filter((entry) => (
        entry && entry.sessionId !== session.sessionId && Number(entry.expiresAt || 0) > now
      ));
      if (sessions.length === 0) {
        await this.storage.delete(key);
      } else {
        await this.storage.put(key, {
          sessions,
          expiresAt: Math.max(...sessions.map((entry) => entry.expiresAt)),
        });
      }
    }
  }

  async consumeVerificationBudget(userId, clientKey) {
    return this.withMutationLock(async () => {
      const now = Date.now();
      const windowSeconds = asPositiveInt(this.env.VERIFY_WINDOW_SECONDS, DEFAULT_VERIFY_WINDOW, 10, 3600);
      const pairKey = await sha256Hex(`verify-pair:${clientKey}:${userId}`);
      // Do not rate-limit a claimed UserId globally: it is public, so another
      // IP must not be able to lock the legitimate user out by naming them.
      const specs = [
        ["ip", clientKey, asPositiveInt(this.env.VERIFY_IP_LIMIT, DEFAULT_VERIFY_IP_LIMIT, 1, 600)],
        ["pair", pairKey, asPositiveInt(this.env.VERIFY_PAIR_LIMIT, DEFAULT_VERIFY_PAIR_LIMIT, 1, 120)],
      ];
      const records = [];
      for (const [kind, key, limit] of specs) {
        const storageKey = `verify-rate:${kind}:${key}`;
        const stored = await this.storage.get(storageKey);
        const record = stored && Number(stored.expiresAt) > now
          ? { count: Number(stored.count) || 0, expiresAt: Number(stored.expiresAt) }
          : { count: 0, expiresAt: now + windowSeconds * 1000 };
        if (record.count >= limit) {
          return json({ ok: false, error: "rate_limited", retryAfter: Math.max(1, Math.ceil((record.expiresAt - now) / 1000)) }, 429);
        }
        records.push({ storageKey, record });
      }
      for (const { storageKey, record } of records) {
        await this.storage.put(storageKey, { count: record.count + 1, expiresAt: record.expiresAt });
      }
      await this.ensureAlarm(windowSeconds * 1000);
      return null;
    });
  }

  async createRateLimitedSession(provider, userId, clientKey) {
    return this.withMutationLock(async () => {
      const now = Date.now();
      const sessionTtl = asPositiveInt(this.env.SESSION_TTL_SECONDS, DEFAULT_SESSION_TTL, 300, 3600);
      const windowSeconds = asPositiveInt(this.env.START_RATE_WINDOW_SECONDS, DEFAULT_START_WINDOW, 60, 3600);
      const userKey = await sha256Hex(`user:${userId}`);
      const pairKey = await sha256Hex(`pair:${clientKey}:${userId}`);
      const rateSpecs = [
        ["ip", clientKey, asPositiveInt(this.env.START_RATE_IP_LIMIT, DEFAULT_START_IP_LIMIT, 5, 500)],
        ["user", userKey, asPositiveInt(this.env.START_RATE_USER_LIMIT, DEFAULT_START_USER_LIMIT, 3, 100)],
        ["pair", pairKey, asPositiveInt(this.env.START_RATE_PAIR_LIMIT, DEFAULT_START_PAIR_LIMIT, 2, 50)],
      ];
      const rateRecords = [];
      for (const [kind, key, limit] of rateSpecs) {
        const storageKey = `rate:${kind}:${key}`;
        const stored = await this.storage.get(storageKey);
        const record = stored && Number(stored.expiresAt || 0) > now
          ? { count: Number(stored.count || 0), expiresAt: Number(stored.expiresAt) }
          : { count: 0, expiresAt: now + windowSeconds * 1000 };
        if (record.count >= limit) {
          return json({
            ok: false,
            error: "rate_limited",
            retryAfter: Math.max(1, Math.ceil((record.expiresAt - now) / 1000)),
          }, 429);
        }
        rateRecords.push({ storageKey, record });
      }

      const pendingSpecs = [
        ["ip", clientKey, asPositiveInt(this.env.MAX_PENDING_IP, DEFAULT_PENDING_IP_LIMIT, 3, 200)],
        ["user", userKey, asPositiveInt(this.env.MAX_PENDING_USER, DEFAULT_PENDING_USER_LIMIT, 1, 20)],
        ["pair", pairKey, asPositiveInt(this.env.MAX_PENDING_PAIR, DEFAULT_PENDING_PAIR_LIMIT, 1, 10)],
      ];
      const pendingRecords = [];
      for (const [kind, key, limit] of pendingSpecs) {
        const storageKey = `pending:${kind}:${key}`;
        const stored = await this.storage.get(storageKey);
        const sessions = Array.isArray(stored?.sessions)
          ? stored.sessions.filter((entry) => entry && Number(entry.expiresAt || 0) > now)
          : [];
        if (sessions.length >= limit) {
          return json({ ok: false, error: "too_many_pending", retryAfter: sessionTtl }, 429);
        }
        pendingRecords.push({ storageKey, sessions });
      }

      const sessionId = randomHex(16);
      const expiresAt = now + sessionTtl * 1000;
      for (const { storageKey, record } of rateRecords) {
        await this.storage.put(storageKey, { count: record.count + 1, expiresAt: record.expiresAt });
      }
      for (const record of pendingRecords) {
        record.sessions.push({ sessionId, expiresAt });
        await this.storage.put(record.storageKey, { sessions: record.sessions, expiresAt });
      }
      await this.storage.put(`session:${sessionId}`, {
        sessionId,
        provider,
        userId,
        status: "pending",
        pendingKeys: pendingRecords.map((record) => record.storageKey),
        createdAt: now,
        expiresAt,
      });
      await this.ensureAlarm(Math.min(sessionTtl, windowSeconds) * 1000);
      return json({ ok: true, sessionId, expiresAt });
    });
  }

  async createRateLimitedManualKey(userId, clientKey) {
    return this.withMutationLock(async () => {
      const now = Date.now();
      const windowSeconds = asPositiveInt(
        this.env.ADMIN_ISSUE_RATE_WINDOW_SECONDS,
        DEFAULT_ADMIN_ISSUE_WINDOW,
        60,
        24 * 60 * 60,
      );
      const userKey = await sha256Hex(`admin-user:${userId}`);
      const rateSpecs = [
        ["ip", clientKey, asPositiveInt(this.env.ADMIN_ISSUE_RATE_IP_LIMIT, DEFAULT_ADMIN_ISSUE_IP_LIMIT, 1, 100)],
        ["user", userKey, asPositiveInt(this.env.ADMIN_ISSUE_RATE_USER_LIMIT, DEFAULT_ADMIN_ISSUE_USER_LIMIT, 1, 50)],
      ];
      const records = [];
      for (const [kind, key, limit] of rateSpecs) {
        const storageKey = `admin-rate:${kind}:${key}`;
        const stored = await this.storage.get(storageKey);
        const record = stored && Number(stored.expiresAt || 0) > now
          ? { count: Number(stored.count || 0), expiresAt: Number(stored.expiresAt) }
          : { count: 0, expiresAt: now + windowSeconds * 1000 };
        if (record.count >= limit) {
          return json({
            ok: false,
            error: "rate_limited",
            retryAfter: Math.max(1, Math.ceil((record.expiresAt - now) / 1000)),
          }, 429);
        }
        records.push({ storageKey, record });
      }

      for (const { storageKey, record } of records) {
        await this.storage.put(storageKey, { count: record.count + 1, expiresAt: record.expiresAt });
      }
      const issued = await this.issueKey({ userId, provider: "owner-test" });
      await this.ensureAlarm(Math.min(windowSeconds * 1000, issued.expiresAt - now));
      return json({
        ok: true,
        key: issued.key,
        userId,
        provider: issued.provider,
        expiresAt: issued.expiresAt,
        ttlSeconds: Math.max(0, Math.floor((issued.expiresAt - Date.now()) / 1000)),
      });
    });
  }

  async issueKey(session) {
    const raw = randomHex(10).toUpperCase();
    const key = `NOTH-${raw.slice(0, 4)}-${raw.slice(4, 8)}-${raw.slice(8, 12)}-${raw.slice(12, 16)}-${raw.slice(16, 20)}`;
    const keyHash = await sha256Hex(key);
    const ttl = asPositiveInt(this.env.KEY_TTL_SECONDS, DEFAULT_KEY_TTL, 300, DEFAULT_KEY_TTL);
    const record = {
      product: PRODUCT,
      userId: session.userId,
      provider: session.provider,
      createdAt: Date.now(),
      expiresAt: Date.now() + ttl * 1000,
    };
    await this.storage.put(`key:${keyHash}`, record);
    return { key, ...record };
  }

  async fetch(request) {
    const url = new URL(request.url);
    if (url.pathname === "/session" && request.method === "POST") {
      const body = await request.json().catch(() => null);
      const provider = normalizeProvider(body?.provider);
      const userId = normalizeUserId(body?.userId);
      const clientKey = String(body?.clientKey || "");
      if (!provider || !userId || !/^[a-f0-9]{64}$/i.test(clientKey)) return json({ ok: false, error: "invalid_session" }, 400);
      return this.createRateLimitedSession(provider, userId, clientKey.toLowerCase());
    }

    if (url.pathname === "/manual-issue" && request.method === "POST") {
      const body = await request.json().catch(() => null);
      const userId = normalizeUserId(body?.userId);
      const clientKey = String(body?.clientKey || "");
      if (!userId || !/^[a-f0-9]{64}$/i.test(clientKey)) {
        return json({ ok: false, error: "invalid_manual_issue" }, 400);
      }
      return this.createRateLimitedManualKey(userId, clientKey.toLowerCase());
    }

    if (url.pathname === "/cancel" && request.method === "POST") {
      const body = await request.json().catch(() => null);
      const sessionId = String(body?.sessionId || "");
      if (!/^[a-f0-9]{32}$/i.test(sessionId)) return json({ ok: false, error: "invalid_session" }, 400);
      return this.withMutationLock(async () => {
        const sessionKey = `session:${sessionId}`;
        const session = await this.storage.get(sessionKey);
        if (!session) return json({ ok: true });
        if (session.status === "pending") {
          await this.storage.delete(sessionKey);
          await this.removePendingSession(session);
        }
        return json({ ok: true });
      });
    }

    if (url.pathname === "/complete" && request.method === "POST") {
      const body = await request.json().catch(() => null);
      const sessionId = String(body?.sessionId || "");
      const provider = normalizeProvider(body?.provider);
      const proofId = String(body?.proofId || "");
      if (!/^[a-f0-9]{32}$/i.test(sessionId) || !provider || !proofId) return json({ ok: false, error: "invalid_completion" }, 400);
      return this.withMutationLock(async () => {
        const sessionKey = `session:${sessionId}`;
        const session = await this.storage.get(sessionKey);
        if (!session || session.expiresAt <= Date.now() || session.provider !== provider) return json({ ok: false, error: "expired_session" }, 410);
        if (session.status === "complete" && session.key) {
          return json({ ok: true, key: session.key, expiresAt: session.keyExpiresAt, provider });
        }
        const proofHash = await sha256Hex(`${provider}:${proofId}`);
        const proofKey = `proof:${proofHash}`;
        if (await this.storage.get(proofKey)) return json({ ok: false, error: "proof_already_used" }, 409);
        const issued = await this.issueKey(session);
        session.status = "complete";
        session.key = issued.key;
        session.keyExpiresAt = issued.expiresAt;
        session.expiresAt = Math.max(session.expiresAt, Date.now() + 15 * 60 * 1000);
        await this.storage.put(proofKey, { expiresAt: issued.expiresAt });
        await this.storage.put(sessionKey, session);
        await this.removePendingSession(session);
        await this.ensureAlarm();
        return json({ ok: true, key: issued.key, expiresAt: issued.expiresAt, provider });
      });
    }

    if (url.pathname === "/status") {
      const sessionId = String(url.searchParams.get("session") || "");
      if (!/^[a-f0-9]{32}$/i.test(sessionId)) return json({ ok: false, error: "invalid_session" }, 400);
      const session = await this.storage.get(`session:${sessionId}`);
      if (!session || session.expiresAt <= Date.now()) return json({ ok: false, error: "expired_session" }, 410);
      if (session.status !== "complete") return json({ ok: false, error: "pending", status: "pending" }, 202);
      return json({ ok: true, status: "complete", key: session.key, expiresAt: session.keyExpiresAt, provider: session.provider });
    }

    if (url.pathname === "/verify" && request.method === "POST") {
      const body = await request.json().catch(() => null);
      const key = String(body?.key || "").trim().toUpperCase();
      const lease = String(body?.lease || "").trim();
      const userId = normalizeUserId(body?.userId);
      if (!userId) return json({ ok: false, error: "invalid_key" }, 401);
      const clientKey = String(body?.clientKey || "");
      if (!/^[a-f0-9]{64}$/.test(clientKey)) return json({ ok: false, error: "invalid_client" }, 400);
      const limited = await this.consumeVerificationBudget(userId, clientKey);
      if (limited) return limited;

      if (/^NLEASE-[a-f0-9]{64}$/i.test(lease)) {
        const leaseHash = await sha256Hex(lease);
        const leaseRecord = await this.storage.get(`lease:${leaseHash}`);
        if (!leaseRecord || leaseRecord.product !== PRODUCT || leaseRecord.userId !== userId || leaseRecord.expiresAt <= Date.now()) {
          return json({ ok: false, error: "invalid_lease" }, 401);
        }
        return json({
          ok: true,
          product: PRODUCT,
          provider: leaseRecord.provider,
          expiresAt: leaseRecord.expiresAt,
          ttlSeconds: Math.max(0, Math.floor((leaseRecord.expiresAt - Date.now()) / 1000)),
          lease,
        });
      }

      if (!/^NOTH-[A-Z0-9]{4}(?:-[A-Z0-9]{4}){4}$/.test(key)) return json({ ok: false, error: "invalid_key" }, 401);
      return this.withMutationLock(async () => {
        const keyHash = await sha256Hex(key);
        const keyRecordKey = `key:${keyHash}`;
        const record = await this.storage.get(keyRecordKey);
        if (!record || record.product !== PRODUCT || record.userId !== userId || record.expiresAt <= Date.now()) {
          return json({ ok: false, error: "invalid_key" }, 401);
        }
        const issuedLease = /^NLEASE-[a-f0-9]{64}$/i.test(record.lease)
          ? record.lease
          : `NLEASE-${randomHex(32)}`;
        const leaseHash = await sha256Hex(issuedLease);
        const leaseKey = `lease:${leaseHash}`;
        const savedLease = record.lease ? await this.storage.get(leaseKey) : null;
        if (record.lease !== issuedLease || !savedLease || savedLease.product !== PRODUCT
            || savedLease.userId !== userId || savedLease.expiresAt !== record.expiresAt) {
          record.lease = issuedLease;
          await this.storage.put(keyRecordKey, record);
          await this.storage.put(leaseKey, { ...record, expiresAt: record.expiresAt });
        }
        await this.ensureAlarm();
        return json({
          ok: true,
          product: PRODUCT,
          provider: record.provider,
          expiresAt: record.expiresAt,
          ttlSeconds: Math.max(0, Math.floor((record.expiresAt - Date.now()) / 1000)),
          lease: issuedLease,
        });
      });
    }

    return json({ ok: false, error: "not_found" }, 404);
  }

  async alarm() {
    return this.withMutationLock(async () => {
      const now = Date.now();
      const pageSize = asPositiveInt(this.env.CLEANUP_PAGE_SIZE, DEFAULT_CLEANUP_PAGE_SIZE, 8, 512);
      const maxPages = asPositiveInt(this.env.CLEANUP_MAX_PAGES, DEFAULT_CLEANUP_MAX_PAGES, 1, 64);
      const interval = asPositiveInt(this.env.CLEANUP_INTERVAL_SECONDS, DEFAULT_CLEANUP_INTERVAL, 60, 6 * 60 * 60) * 1000;
      const savedCursor = await this.storage.get(CLEANUP_CURSOR_KEY);
      let startAfter = typeof savedCursor?.cursor === "string" ? savedCursor.cursor : undefined;
      let pageCount = 0;
      let hasMore = false;
      let nextExpiry = Number.POSITIVE_INFINITY;

      while (pageCount < maxPages) {
        const options = { limit: pageSize };
        if (startAfter) options.startAfter = startAfter;
        const records = await this.storage.list(options);
        if (records.size === 0) break;
        pageCount += 1;
        const expired = [];
        for (const [key, value] of records) {
          startAfter = key;
          if (key === CLEANUP_CURSOR_KEY) continue;
          const expiresAt = Number(value?.expiresAt || 0);
          if (expiresAt <= now) expired.push(key);
          else nextExpiry = Math.min(nextExpiry, expiresAt);
        }
        if (expired.length) await this.storage.delete(expired);
        if (records.size < pageSize) break;
      }

      if (startAfter && pageCount >= maxPages) {
        hasMore = (await this.storage.list({ startAfter, limit: 1 })).size > 0;
      }
      // Persist progress. Restarting at the first live page on every alarm
      // starves expired records that sort beyond the per-invocation budget.
      if (hasMore) await this.storage.put(CLEANUP_CURSOR_KEY, { cursor: startAfter });
      else await this.storage.delete(CLEANUP_CURSOR_KEY);
      if ((await this.storage.list({ limit: 1 })).size > 0) {
        const delay = hasMore
          ? 60 * 1000
          : Math.max(60 * 1000, Math.min(interval, nextExpiry - now));
        await this.storage.setAlarm(now + (Number.isFinite(delay) ? delay : interval));
      }
    });
  }
}

const routeMethods = new Map([
  ["/", "GET"],
  ["/v1/nothrilo/key/health", "GET"],
  ["/v1/nothrilo/key/admin/issue", "POST"],
  ["/v1/nothrilo/key/start", "GET"],
  ["/v1/nothrilo/key/callback/workink", "GET"],
  ["/v1/nothrilo/key/callback/linkvertise", "GET"],
  ["/v1/nothrilo/key/callback/lootlabs", "GET"],
  ["/v1/nothrilo/key/postback/lootlabs", "GET"],
  ["/v1/nothrilo/key/status", "GET"],
  ["/v1/nothrilo/key/verify", "POST"],
]);

async function dispatchRequest(request, env) {
    const url = new URL(request.url);
    const administrative = url.pathname === "/v1/nothrilo/key/admin/issue";
    const method = routeMethods.get(url.pathname);
    if (!method) return json({ ok: false, error: "not_found" }, 404);
    if (request.method === "OPTIONS" && !administrative) {
      return new Response(null, { status: 204, headers: { ...corsHeaders(), "Access-Control-Allow-Methods": method } });
    }
    if (request.method !== method) {
      return (administrative ? privateJson : json)({ ok: false, error: "method_not_allowed" }, 405, { Allow: method });
    }

    if (url.pathname === "/" && request.method === "GET") return html(landingPage(url.origin));
    if (url.pathname === "/v1/nothrilo/key/health") return json({ ok: true, product: PRODUCT });
    if (url.pathname === "/v1/nothrilo/key/admin/issue" && request.method === "POST") {
      return manualOwnerIssueRequest(request, env);
    }
    if (url.pathname === "/v1/nothrilo/key/start" && request.method === "GET") return startProvider(request, env, url);
    if (url.pathname === "/v1/nothrilo/key/callback/workink" && request.method === "GET") return workinkCallback(env, url);
    if (url.pathname === "/v1/nothrilo/key/callback/linkvertise" && request.method === "GET") return linkvertiseCallback(request, env, url);
    if (url.pathname === "/v1/nothrilo/key/callback/lootlabs" && request.method === "GET") return pendingLootlabsPage();
    if (url.pathname === "/v1/nothrilo/key/postback/lootlabs" && request.method === "GET") return lootlabsPostback(env, url);
    if (url.pathname === "/v1/nothrilo/key/status" && request.method === "GET") {
      const sessionId = readCookie(request, SESSION_COOKIE);
      if (!sessionId || !/^[a-f0-9]{32}$/i.test(sessionId)) {
        return privateJson({ ok: false, error: "missing_session" }, 401);
      }
      const result = await getSessionStatus(env, sessionId);
      return privateJson(result.data, result.status, { Vary: "Cookie" });
    }
    if (url.pathname === "/v1/nothrilo/key/verify" && request.method === "POST") return verifyKeyRequest(request, env);
    return json({ ok: false, error: "not_found" }, 404);
}

export default {
  async fetch(request, env) {
    try {
      return await dispatchRequest(request, env);
    } catch {
      // Do not reflect exception messages or log token-bearing URLs/bodies.
      // Clients get a stable JSON error rather than a platform HTML traceback.
      const respond = new URL(request.url).pathname === "/v1/nothrilo/key/admin/issue" ? privateJson : json;
      return respond({ ok: false, error: "service_unavailable" }, 503, { "Retry-After": "30" });
    }
  },
};
