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
      ...corsHeaders(),
      ...headers,
    },
  });
}

function html(content, status = 200, headers = {}) {
  return new Response(content, {
    status,
    headers: {
      "Content-Type": "text/html; charset=utf-8",
      "Cache-Control": "no-store",
      "Referrer-Policy": "no-referrer",
      "X-Content-Type-Options": "nosniff",
      "X-Frame-Options": "DENY",
      "Content-Security-Policy": "default-src 'none'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'",
      ...headers,
    },
  });
}

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function asPositiveInt(value, fallback, min = 1, max = Number.MAX_SAFE_INTEGER) {
  const parsed = Number.parseInt(String(value ?? ""), 10);
  if (!Number.isFinite(parsed)) return fallback;
  return Math.min(max, Math.max(min, parsed));
}

function normalizeUserId(value) {
  const text = String(value ?? "").trim();
  return /^\d{1,20}$/.test(text) && text !== "0" ? text : null;
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
  const separator = urlString.includes("?") ? "&" : "?";
  return `${urlString}${separator}${encodeURIComponent(name)}=${encodeURIComponent(value)}`;
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
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const response = await fetch(input, { ...init, signal: controller.signal });
    let body;
    if (responseType === "text") {
      body = await response.text();
    } else {
      try {
        body = await response.json();
      } catch (error) {
        if (controller.signal.aborted) throw error;
        body = null;
      }
    }
    return { response, body };
  } finally {
    clearTimeout(timeout);
  }
}

function pageShell(title, body, script = "") {
  return `<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>${escapeHtml(title)}</title>
  <style>
    :root{color-scheme:dark;font-family:Inter,ui-sans-serif,system-ui,-apple-system,"Segoe UI",sans-serif}
    *{box-sizing:border-box}body{margin:0;min-height:100vh;display:grid;place-items:center;background:#07070a;color:#f8f8fb;padding:20px;overflow-x:hidden}
    body:before{content:"";position:fixed;inset:-35%;background:conic-gradient(from 90deg,#ff159d,#7048ff,#00d8ff,#35ef86,#ffe047,#ff159d);filter:blur(110px);opacity:.16;animation:spin 12s linear infinite;pointer-events:none}
    @keyframes spin{to{transform:rotate(360deg)}}
    .card{position:relative;width:min(520px,100%);border:1px solid transparent;border-radius:26px;padding:28px;background:linear-gradient(#101015,#101015) padding-box,linear-gradient(120deg,#ff159d,#7159ff,#00dbff,#6dff73) border-box;box-shadow:0 22px 80px #000b}
    .brand{font-size:13px;letter-spacing:.14em;text-transform:uppercase;color:#ff4fb1;font-weight:800}.title{font-size:clamp(27px,7vw,40px);line-height:1.05;margin:9px 0 10px}.muted{color:#b8b8c4;line-height:1.55}.providers{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;margin:22px 0}.provider{border:1px solid #30303b;border-radius:15px;background:#19191f;color:#fff;padding:14px 10px;font-weight:800;text-align:center}.key{width:100%;padding:15px;border-radius:14px;border:1px solid #343440;background:#09090c;color:#fff;font:700 15px ui-monospace,SFMono-Regular,Consolas,monospace;text-align:center}.copy{width:100%;margin-top:10px;border:0;border-radius:14px;padding:14px;background:linear-gradient(90deg,#ff159d,#8c4fff);color:#fff;font-weight:900;cursor:pointer}.status{margin-top:14px;padding:12px 14px;border-radius:13px;background:#18181e;color:#cfcfd8}.ok{color:#6dff99}.bad{color:#ff7698}.small{font-size:12px;color:#8e8e9b;margin-top:17px}@media(max-width:520px){.card{padding:22px}.providers{grid-template-columns:1fr}.provider{padding:12px}}
  </style>
</head>
<body><main class="card">${body}</main>${script ? `<script>${script}</script>` : ""}</body>
</html>`;
}

function landingPage(origin) {
  const body = `
    <div class="brand">Nothrilo 🇧🇷</div>
    <h1 class="title">Key grátis</h1>
    <p class="muted">Abra o Nothrilo, escolha Work.ink, LootLabs ou Linkvertise e conclua uma das opções. Todas liberam o menu inteiro por 24 horas.</p>
    <div class="providers"><div class="provider">Work.ink</div><div class="provider">LootLabs</div><div class="provider">Linkvertise</div></div>
    <div class="status">Servidor online em <strong>${escapeHtml(origin)}</strong>.</div>
    <p class="small">Nenhuma função é Premium. A key serve somente para liberar o menu completo.</p>`;
  return pageShell("Nothrilo Key", body);
}

function errorPage(message, status = 400, headers = {}) {
  const body = `
    <div class="brand">Nothrilo 🇧🇷</div>
    <h1 class="title">Não deu certo</h1>
    <p class="muted">${escapeHtml(message)}</p>
    <div class="status bad">Volte ao menu e tente novamente.</div>`;
  return html(pageShell("Erro — Nothrilo Key", body), status, headers);
}

function keyPage(key, expiresAt, provider) {
  const expiry = new Date(expiresAt).toLocaleString("pt-BR", { timeZone: "America/Sao_Paulo" });
  const body = `
    <div class="brand">Nothrilo 🇧🇷</div>
    <h1 class="title">Key liberada ✨</h1>
    <p class="muted">Você concluiu pela opção ${escapeHtml(providerLabel(provider))}. Copie a key e cole no Nothrilo.</p>
    <input id="key" class="key" readonly value="${escapeHtml(key)}" aria-label="Sua key">
    <button id="copy" class="copy" type="button">Copiar key</button>
    <div id="status" class="status ok">Válida até ${escapeHtml(expiry)}.</div>
    <p class="small">A key é vinculada ao seu usuário do Roblox e libera todas as funções.</p>`;
  const script = `
    const button=document.getElementById('copy');
    button.addEventListener('click',async()=>{const field=document.getElementById('key');field.select();try{await navigator.clipboard.writeText(field.value);button.textContent='Copiada ✓'}catch{document.execCommand('copy');button.textContent='Copiada ✓'}});`;
  return html(pageShell("Key liberada — Nothrilo", body, script));
}

function pendingLootlabsPage() {
  const body = `
    <div class="brand">Nothrilo 🇧🇷</div>
    <h1 class="title">Confirmando…</h1>
    <p class="muted">Aguardando o postback do LootLabs. Normalmente leva poucos segundos.</p>
    <div id="status" class="status">Verificando conclusão…</div>
    <div id="result"></div>`;
  const script = `
    const status=document.getElementById('status');
    const result=document.getElementById('result');
    let attempts=0;
    async function poll(){
      attempts++;
      try{
        const response=await fetch('/v1/nothrilo/key/status',{cache:'no-store'});
        const data=await response.json();
        if(data.ok&&data.status==='complete'){
          status.className='status ok';status.textContent='Key liberada!';
          result.innerHTML='<input id="key" class="key" readonly><button id="copy" class="copy" type="button">Copiar key</button>';
          document.getElementById('key').value=data.key;
          document.getElementById('copy').onclick=async()=>{const key=document.getElementById('key').value;try{await navigator.clipboard.writeText(key)}catch{};document.getElementById('copy').textContent='Copiada ✓'};
          return;
        }
        if(!data.ok&&data.error!=='pending') throw new Error(data.error||'invalid');
      }catch(error){}
      if(attempts>=40){status.className='status bad';status.textContent='A confirmação demorou demais. Volte ao menu e tente novamente.';return}
      setTimeout(poll,1500);
    }
    poll();`;
  return html(pageShell("Confirmando — Nothrilo Key", body, script));
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

async function verifyIssuedKey(env, credential, userId) {
  const response = await internalRequest(env, "/verify", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ ...credential, userId }),
  });
  return { status: response.status, data: await response.json() };
}

function providerConfiguration(env, provider) {
  if (provider === "workink") {
    const baseLink = String(env.WORKINK_URL || "").trim();
    const expectedLinkId = String(env.WORKINK_LINK_ID || "").trim();
    return /^https:\/\/work\.ink\//i.test(baseLink) && expectedLinkId
      ? { ok: true, baseLink }
      : { ok: false, message: "A opção Work.ink ainda não foi configurada." };
  }
  if (provider === "linkvertise") {
    const link = String(env.LINKVERTISE_URL || "").trim();
    return /^https:\/\/(?:linkvertise\.com|link-to\.net|direct-link\.net)\//i.test(link)
      ? { ok: true, link }
      : { ok: false, message: "A opção Linkvertise ainda não foi configurada." };
  }
  const link = String(env.LOOTLABS_URL || "").trim();
  return /^https:\/\/loot-link\.com\//i.test(link)
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
    if (!override || typeof override.sr !== "string" || !override.sr) {
      await cancelSession(env, sessionId).catch(() => null);
      return errorPage("Work.ink retornou uma sessão inválida.", 502);
    }
    return new Response(null, {
      status: 302,
      headers: { Location: appendQuery(configuration.baseLink, "sr", override.sr), ...headers },
    });
  }

  if (provider === "linkvertise") {
    return new Response(null, { status: 302, headers: { Location: configuration.link, ...headers } });
  }

  return new Response(null, {
    status: 302,
    headers: { Location: appendQuery(configuration.link, "puid", sessionId), ...headers },
  });
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
  if (!sessionId || !/^[a-f0-9]{64}$/i.test(hash) || secret.length !== 64) {
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
  if (configuredSecret.length < 32 || providedSecret !== configuredSecret) return json({ ok: false }, 403);
  const sessionId = String(url.searchParams.get("click_id") || url.searchParams.get("puid") || "");
  const uniqueId = String(url.searchParams.get("unique_id") || "");
  if (!/^[a-f0-9]{32}$/i.test(sessionId) || uniqueId.length < 6 || uniqueId.length > 256) {
    return json({ ok: false, error: "invalid_postback" }, 400);
  }
  const completed = await completeSession(env, sessionId, "lootlabs", uniqueId);
  return json({ ok: completed.data.ok }, completed.data.ok ? 200 : completed.status);
}

async function verifyKeyRequest(request, env) {
  let body;
  try {
    body = await request.json();
  } catch {
    return json({ ok: false, error: "invalid_json" }, 400);
  }
  const key = String(body?.key || "").trim().toUpperCase();
  const lease = String(body?.lease || "").trim();
  const userId = normalizeUserId(body?.userId);
  const hasKey = /^NOTH-[A-Z0-9]{4}(?:-[A-Z0-9]{4}){4}$/.test(key);
  const hasLease = /^NLEASE-[a-f0-9]{64}$/i.test(lease);
  if ((!hasKey && !hasLease) || !userId) {
    return json({ ok: false, error: "invalid_key" }, 401);
  }
  const verified = await verifyIssuedKey(env, hasKey ? { key } : { lease }, userId);
  return json(verified.data, verified.status);
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
        record.lease = issuedLease;
        await this.storage.put(keyRecordKey, record);
        await this.storage.put(`lease:${leaseHash}`, { ...record, expiresAt: record.expiresAt });
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
      let startAfter;
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
      if ((await this.storage.list({ limit: 1 })).size > 0) {
        const delay = hasMore
          ? 60 * 1000
          : Math.max(60 * 1000, Math.min(interval, nextExpiry - now));
        await this.storage.setAlarm(now + (Number.isFinite(delay) ? delay : interval));
      }
    });
  }
}

export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") return new Response(null, { status: 204, headers: corsHeaders() });
    const url = new URL(request.url);

    if (url.pathname === "/" && request.method === "GET") return html(landingPage(url.origin));
    if (url.pathname === "/v1/nothrilo/key/health") return json({ ok: true, product: PRODUCT });
    if (url.pathname === "/v1/nothrilo/key/start" && request.method === "GET") return startProvider(request, env, url);
    if (url.pathname === "/v1/nothrilo/key/callback/workink" && request.method === "GET") return workinkCallback(env, url);
    if (url.pathname === "/v1/nothrilo/key/callback/linkvertise" && request.method === "GET") return linkvertiseCallback(request, env, url);
    if (url.pathname === "/v1/nothrilo/key/callback/lootlabs" && request.method === "GET") return pendingLootlabsPage();
    if (url.pathname === "/v1/nothrilo/key/postback/lootlabs" && request.method === "GET") return lootlabsPostback(env, url);
    if (url.pathname === "/v1/nothrilo/key/status" && request.method === "GET") {
      const sessionId = readCookie(request, SESSION_COOKIE);
      if (!sessionId) return json({ ok: false, error: "missing_session" }, 401);
      const result = await getSessionStatus(env, sessionId);
      return json(result.data, result.status);
    }
    if (url.pathname === "/v1/nothrilo/key/verify" && request.method === "POST") return verifyKeyRequest(request, env);
    return json({ ok: false, error: "not_found" }, 404);
  },
};
