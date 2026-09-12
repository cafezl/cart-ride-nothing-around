import React from "react";
import { renderToStaticMarkup } from "react-dom/server.edge";

const h = React.createElement;

const STYLES = `
:root {
  color-scheme: dark;
  font-family: Inter, ui-sans-serif, system-ui, -apple-system, "Segoe UI", sans-serif;
  background: #07070a;
  color: #f8f8fb;
  font-synthesis: none;
}
* { box-sizing: border-box; }
html { min-width: 320px; background: #07070a; }
body {
  margin: 0;
  min-height: 100vh;
  display: grid;
  place-items: center;
  padding: 24px;
  overflow-x: hidden;
  background:
    radial-gradient(circle at 12% 18%, rgba(255, 21, 157, .20), transparent 32rem),
    radial-gradient(circle at 88% 82%, rgba(0, 216, 255, .16), transparent 34rem),
    #07070a;
}
body::before {
  content: "";
  position: fixed;
  inset: -45%;
  z-index: 0;
  pointer-events: none;
  background: conic-gradient(from 90deg, #ff159d, #7048ff, #00d8ff, #35ef86, #ffe047, #ff159d);
  filter: blur(130px);
  opacity: .10;
  animation: ambient-spin 18s linear infinite;
}
@keyframes ambient-spin { to { transform: rotate(360deg); } }
.shell {
  position: relative;
  z-index: 1;
  width: min(560px, 100%);
}
.card {
  overflow: hidden;
  border: 1px solid transparent;
  border-radius: 28px;
  padding: clamp(22px, 5vw, 34px);
  background:
    linear-gradient(145deg, rgba(20, 20, 27, .98), rgba(12, 12, 17, .98)) padding-box,
    linear-gradient(125deg, #ff159d, #7159ff 40%, #00dbff 75%, #6dff73) border-box;
  box-shadow: 0 28px 90px rgba(0, 0, 0, .62);
}
.brand-row { display: flex; align-items: center; justify-content: space-between; gap: 16px; }
.brand {
  color: #ff63bd;
  font-size: 13px;
  font-weight: 900;
  letter-spacing: .14em;
  text-transform: uppercase;
}
.tech {
  border: 1px solid #343440;
  border-radius: 999px;
  padding: 6px 9px;
  color: #a9a9b6;
  background: rgba(255, 255, 255, .025);
  font-size: 11px;
  font-weight: 750;
  white-space: nowrap;
}
.title {
  margin: 16px 0 10px;
  font-size: clamp(30px, 8vw, 46px);
  line-height: 1.02;
  letter-spacing: -.04em;
}
.muted { margin: 0; color: #b8b8c4; line-height: 1.62; }
.providers { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 10px; margin: 24px 0; }
.provider {
  min-width: 0;
  border: 1px solid #32323e;
  border-radius: 16px;
  padding: 14px 8px;
  background: linear-gradient(150deg, #1b1b23, #141419);
  color: #fff;
  font-size: 13px;
  font-weight: 850;
  text-align: center;
}
.provider::before {
  content: "";
  display: block;
  width: 7px;
  height: 7px;
  margin: 0 auto 8px;
  border-radius: 999px;
  background: #6dff99;
  box-shadow: 0 0 15px rgba(109, 255, 153, .7);
}
.key {
  width: 100%;
  margin-top: 22px;
  border: 1px solid #383845;
  border-radius: 15px;
  padding: 16px 12px;
  background: #09090c;
  color: #fff;
  font: 750 14px ui-monospace, SFMono-Regular, Consolas, monospace;
  letter-spacing: .02em;
  text-align: center;
}
.copy {
  width: 100%;
  margin-top: 10px;
  border: 0;
  border-radius: 15px;
  padding: 15px;
  background: linear-gradient(95deg, #ff159d, #8c4fff);
  color: #fff;
  font: inherit;
  font-weight: 900;
  cursor: pointer;
  transition: transform .16s ease, filter .16s ease;
}
.copy:hover { filter: brightness(1.08); transform: translateY(-1px); }
.copy:focus-visible { outline: 3px solid #8fdcff; outline-offset: 3px; }
.status {
  margin-top: 16px;
  border: 1px solid #2d2d37;
  border-radius: 14px;
  padding: 13px 14px;
  background: rgba(255, 255, 255, .035);
  color: #cfcfd8;
  overflow-wrap: anywhere;
}
.status strong, .ok { color: #76ffa2; }
.bad { color: #ff87a4; }
.small { margin: 18px 0 0; color: #8e8e9b; font-size: 12px; line-height: 1.55; }
.footer { margin-top: 13px; color: #666675; font-size: 11px; text-align: center; }
[hidden] { display: none !important; }
@media (max-width: 520px) {
  body { padding: 15px; }
  .card { border-radius: 23px; }
  .brand-row { align-items: flex-start; flex-direction: column; gap: 9px; }
  .providers { grid-template-columns: 1fr; }
  .provider { display: flex; align-items: center; justify-content: center; gap: 9px; padding: 12px; }
  .provider::before { display: inline-block; margin: 0; }
}
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after { scroll-behavior: auto !important; animation: none !important; transition: none !important; }
}
`;

const COPY_SCRIPT = `
(() => {
  const field = document.getElementById('key');
  const button = document.getElementById('copy');
  const status = document.getElementById('copy-status');
  if (!field || !button) return;
  button.addEventListener('click', async () => {
    let copied = false;
    try {
      await navigator.clipboard.writeText(field.value);
      copied = true;
    } catch {
      field.focus();
      field.select();
      copied = typeof document.execCommand === 'function' && document.execCommand('copy');
    }
    button.textContent = copied ? 'Copiada ✓' : 'Selecione e copie a key';
    if (status) status.textContent = copied ? 'Key copiada para a área de transferência.' : 'Não foi possível copiar automaticamente.';
  });
})();`;

const PENDING_SCRIPT = `
(() => {
  const status = document.getElementById('status');
  const result = document.getElementById('result');
  const field = document.getElementById('key');
  const button = document.getElementById('copy');
  let attempts = 0;

  async function copyKey() {
    if (!field || !button) return;
    let copied = false;
    try {
      await navigator.clipboard.writeText(field.value);
      copied = true;
    } catch {
      field.focus();
      field.select();
      copied = typeof document.execCommand === 'function' && document.execCommand('copy');
    }
    button.textContent = copied ? 'Copiada ✓' : 'Selecione e copie a key';
  }

  if (button) button.addEventListener('click', copyKey);

  async function poll() {
    attempts += 1;
    try {
      const response = await fetch('/v1/nothrilo/key/status', {
        cache: 'no-store',
        credentials: 'same-origin',
        headers: { Accept: 'application/json' },
      });
      const data = await response.json();
      if (data.ok && data.status === 'complete' && typeof data.key === 'string') {
        status.className = 'status ok';
        status.textContent = 'Key liberada!';
        field.value = data.key;
        result.hidden = false;
        field.focus();
        return;
      }
      if (!data.ok && data.error !== 'pending') throw new Error('invalid-status');
    } catch {}
    if (attempts >= 40) {
      status.className = 'status bad';
      status.textContent = 'A confirmação demorou demais. Volte ao menu e tente novamente.';
      return;
    }
    setTimeout(poll, 1500);
  }

  poll();
})();`;

function BrandRow() {
  return h(
    "div",
    { className: "brand-row" },
    h("div", { className: "brand" }, "Nothrilo 🇧🇷"),
    h("div", { className: "tech" }, "React + JavaScript"),
  );
}

function Footer() {
  return h("div", { className: "footer" }, "API protegida por Cloudflare Workers");
}

function Document({ title, nonce, children, script }) {
  return h(
    "html",
    { lang: "pt-BR" },
    h(
      "head",
      null,
      h("meta", { charSet: "utf-8" }),
      h("meta", { name: "viewport", content: "width=device-width,initial-scale=1" }),
      h("meta", { name: "theme-color", content: "#07070a" }),
      h("meta", { name: "application-name", content: "Nothrilo Key" }),
      h("title", null, title),
      h("style", { nonce }, STYLES),
    ),
    h(
      "body",
      { "data-ui": "react" },
      h("div", { className: "shell" }, h("main", { className: "card" }, children), h(Footer)),
      script
        ? h("script", { nonce, dangerouslySetInnerHTML: { __html: script } })
        : null,
    ),
  );
}

function renderDocument(title, nonce, content, script = "") {
  return {
    markup: `<!doctype html>${renderToStaticMarkup(h(Document, { title, nonce, script }, content))}`,
    nonce,
  };
}

export function renderLandingPage(origin, nonce) {
  return renderDocument(
    "Nothrilo Key",
    nonce,
    h(
      React.Fragment,
      null,
      h(BrandRow),
      h("h1", { className: "title" }, "Key grátis"),
      h(
        "p",
        { className: "muted" },
        "Abra o Nothrilo, escolha um provedor e conclua uma das opções. Todas liberam o menu inteiro por 24 horas.",
      ),
      h(
        "div",
        { className: "providers", "aria-label": "Provedores disponíveis" },
        h("div", { className: "provider" }, "Work.ink"),
        h("div", { className: "provider" }, "LootLabs"),
        h("div", { className: "provider" }, "Linkvertise"),
      ),
      h(
        "div",
        { className: "status" },
        "Servidor online em ",
        h("strong", null, origin),
        ".",
      ),
      h("p", { className: "small" }, "Nenhuma função é Premium. A key serve somente para liberar o menu completo."),
    ),
  );
}

export function renderErrorPage(message, nonce) {
  return renderDocument(
    "Erro — Nothrilo Key",
    nonce,
    h(
      React.Fragment,
      null,
      h(BrandRow),
      h("h1", { className: "title" }, "Não deu certo"),
      h("p", { className: "muted" }, message),
      h("div", { className: "status bad", role: "alert" }, "Volte ao menu e tente novamente."),
    ),
  );
}

export function renderKeyPage({ key, expiry, provider, nonce }) {
  return renderDocument(
    "Key liberada — Nothrilo",
    nonce,
    h(
      React.Fragment,
      null,
      h(BrandRow),
      h("h1", { className: "title" }, "Key liberada ✨"),
      h("p", { className: "muted" }, "Você concluiu pela opção ", provider, ". Copie a key e cole no Nothrilo."),
      h("input", {
        id: "key",
        className: "key",
        readOnly: true,
        value: key,
        "aria-label": "Sua key",
        autoComplete: "off",
        spellCheck: false,
      }),
      h("button", { id: "copy", className: "copy", type: "button" }, "Copiar key"),
      h("div", { id: "copy-status", className: "small", "aria-live": "polite" }),
      h("div", { className: "status ok" }, "Válida até ", expiry, "."),
      h("p", { className: "small" }, "A key é vinculada ao seu usuário do Roblox e libera todas as funções."),
    ),
    COPY_SCRIPT,
  );
}

export function renderPendingPage(nonce) {
  return renderDocument(
    "Confirmando — Nothrilo Key",
    nonce,
    h(
      React.Fragment,
      null,
      h(BrandRow),
      h("h1", { className: "title" }, "Confirmando…"),
      h("p", { className: "muted" }, "Aguardando o postback do LootLabs. Normalmente leva poucos segundos."),
      h("div", { id: "status", className: "status", role: "status", "aria-live": "polite" }, "Verificando conclusão…"),
      h(
        "section",
        { id: "result", hidden: true },
        h("input", {
          id: "key",
          className: "key",
          readOnly: true,
          defaultValue: "",
          "aria-label": "Sua key",
          autoComplete: "off",
          spellCheck: false,
        }),
        h("button", { id: "copy", className: "copy", type: "button" }, "Copiar key"),
      ),
    ),
    PENDING_SCRIPT,
  );
}
