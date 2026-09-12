import assert from "node:assert/strict";

const DEFAULT_ORIGIN = "https://nothrilo-key.urielcafe01.workers.dev";
const REQUEST_TIMEOUT_MS = 20_000;
const READY_ATTEMPTS = 8;
const READY_DELAY_MS = 3_000;

const providerHosts = {
  linkvertise: new Set(["linkvertise.com", "link-to.net", "direct-link.net"]),
};

function productionOrigin() {
  const url = new URL(process.env.KEY_SERVER_ORIGIN || DEFAULT_ORIGIN);
  assert.equal(url.protocol, "https:", "KEY_SERVER_ORIGIN must use HTTPS");
  assert.equal(url.username, "", "KEY_SERVER_ORIGIN must not contain credentials");
  assert.equal(url.password, "", "KEY_SERVER_ORIGIN must not contain credentials");
  assert.equal(url.search, "", "KEY_SERVER_ORIGIN must not contain a query");
  assert.equal(url.hash, "", "KEY_SERVER_ORIGIN must not contain a fragment");
  return url.origin;
}

function request(path, init = {}) {
  return fetch(`${origin}${path}`, {
    ...init,
    cache: "no-store",
    signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
    headers: {
      Accept: "application/json, text/html;q=0.9",
      "User-Agent": "Nothrilo-Production-Smoke/1.0",
      ...init.headers,
    },
  });
}

function wait(milliseconds) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

async function waitForDeployment() {
  let lastError;
  for (let attempt = 1; attempt <= READY_ATTEMPTS; attempt += 1) {
    try {
      const [pageResponse, healthResponse] = await Promise.all([
        request("/"),
        request("/v1/nothrilo/key/health"),
      ]);
      assert.equal(pageResponse.status, 200, "portal did not return HTTP 200");
      assert.equal(healthResponse.status, 200, "health endpoint did not return HTTP 200");

      const [markup, health] = await Promise.all([
        pageResponse.text(),
        healthResponse.json(),
      ]);
      assert.match(markup, /data-ui="react"/, "production is not serving the React interface");
      assert.equal(health.ok, true, "health endpoint did not report ok");
      assert.equal(health.product, "nothrilo", "health endpoint reported another product");
      return;
    } catch (error) {
      lastError = error;
      if (attempt < READY_ATTEMPTS) await wait(READY_DELAY_MS);
    }
  }
  throw lastError;
}

function sessionCookie(response) {
  const setCookie = response.headers.get("set-cookie") || "";
  assert.match(setCookie, /(?:^|;\s*)nothrilo_key_session=[a-f0-9]{32}(?:;|$)/i, "session cookie is missing");
  assert.match(setCookie, /;\s*HttpOnly(?:;|$)/i, "session cookie is not HttpOnly");
  assert.match(setCookie, /;\s*Secure(?:;|$)/i, "session cookie is not Secure");
  assert.match(setCookie, /;\s*SameSite=Lax(?:;|$)/i, "session cookie has an unsafe SameSite policy");
  return setCookie.split(";", 1)[0];
}

async function checkProvider(provider, index) {
  const userId = String(8_700_000_000 + (Date.now() % 100_000_000) + index);
  const start = await request(
    `/v1/nothrilo/key/start?provider=${encodeURIComponent(provider)}&userId=${encodeURIComponent(userId)}`,
    { redirect: "manual" },
  );
  assert.equal(start.status, 302, `${provider} did not return a redirect`);

  const location = new URL(start.headers.get("location") || "", origin);
  assert.equal(location.protocol, "https:", `${provider} redirect is not HTTPS`);
  assert.equal(providerHosts[provider].has(location.hostname), true, `${provider} redirected to an unexpected host`);

  const cookie = sessionCookie(start);
  const status = await request("/v1/nothrilo/key/status", {
    headers: { Cookie: cookie },
  });
  assert.equal(status.status, 202, `${provider} session did not remain pending`);
  const body = await status.json();
  assert.equal(body.ok, false, `${provider} pending status unexpectedly reported completion`);
  assert.equal(body.error, "pending", `${provider} pending status did not report the expected error`);
  assert.equal(body.status, "pending", `${provider} session has an unexpected state`);

  console.log(`PASS ${provider}: secure pending session and expected redirect`);
}

const origin = productionOrigin();

await waitForDeployment();
console.log("PASS portal: React interface and health endpoint are live");

for (const [index, provider] of Object.keys(providerHosts).entries()) {
  await checkProvider(provider, index);
}
