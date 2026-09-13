import assert from "node:assert/strict";
import test from "node:test";
import { mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

// Runs the real client in a deterministic Luau model. Layout checks cover the
// declared dimensions and parentage, not Roblox text shaping or actual rendering.
const root = fileURLToPath(new URL("../", import.meta.url));
const interpreter = process.env.LUAU_BIN || "luau";
const harness = await readFile(new URL("./client-harness.lua", import.meta.url), "utf8");

function longString(value) {
  let fence = "=";
  while (value.includes(`]${fence}]`)) fence += "=";
  return `[${fence}[${value}]${fence}]`;
}

async function fixture(options, actions, checks) {
  const directory = await mkdtemp(join(tmpdir(), "nothrilo-v2-key-test-"));
  try {
    const source = await readFile(join(root, "nothrilov2/nothrilov2"), "utf8");
    const fields = Object.entries({ authorize: false, maxTime: 8, ...options }).map(([key, value]) => (
      `${key}=${typeof value === "string" ? longString(value) : String(value)}`
    ));
    if (actions) fields.push(`onGate=function(gate, env) ${actions} end`);
    const path = join(directory, "key-gate.lua");
    await writeFile(path, `${harness}
local result = runFixture(${longString(source)}, {${fields.join(",")}})
assert(#result.failures == 0, table.concat(result.failures, "\\n"))
${checks}
`);
    const result = spawnSync(interpreter, [path], {
      cwd: root, encoding: "utf8", timeout: 20000, maxBuffer: 2 * 1024 * 1024,
    });
    assert.equal(result.status, 0, result.error?.message || result.stderr || result.stdout);
  } finally {
    await rm(directory, { recursive: true, force: true });
  }
}

const gateVisible = `
  local gate = result.core:FindFirstChild("NothriloKeyGate")
  assert(gate, "key gate disappeared before validation")
  assert(not result.finished, "bootstrap skipped key validation")
  assert(not result.core:FindFirstChild("NothriloClassicUI"), "main menu opened before validation")
`;

const submit = `
  assert(not env.game:GetService("CoreGui"):FindFirstChild("NothriloClassicUI"), "menu appeared before submit")
  gate:FindFirstChild("KeyInput", true).Text = "  fixture-valid-key  "
  gate:FindFirstChild("Verify", true).Activated:Fire()
`;

test("Nothrilo V2 opens its actual menu only after the JNKIE SDK accepts a key", () => fixture(
  { sdk: true, sdkDelay: 0.1, maxTime: 15 }, submit, `
    assert(result.finished, "verified bootstrap did not finish")
    assert(not result.core:FindFirstChild("NothriloKeyGate"), "verified key gate leaked")
    local menu = result.core:FindFirstChild("NothriloClassicUI")
    assert(menu and menu.Enabled and #menu:GetDescendants() > 100, "verified menu was not built")
    assert(#result.sdkCalls == 1, "unexpected SDK calls")
    local call = result.sdkCalls[1]
    assert(call.name == "check_key" and call.key == "fixture-valid-key", "key was not normalized before checking")
    assert(call.service == "NothriloV2" and call.identifier == "1177853" and call.provider == "Linkvertise", "display rename changed the live JNKIE configuration")
    assert(result.env.SCRIPT_KEY == "fixture-valid-key", "accepted session key was not retained")
  `,
));

test("Nothrilo V2 rejects an invalid SDK result and keeps controls usable", () => fixture(
  { sdk: true, sdkValid: false }, submit, `${gateVisible}
    assert(#result.sdkCalls == 1, "invalid key was not sent once")
    assert(gate:FindFirstChild("Verify", true).Active, "verify remained disabled after invalid key")
    assert(gate:FindFirstChild("KeyInput", true).TextEditable, "key input remained locked")
    assert(result.env.SCRIPT_KEY == nil, "invalid key was saved")
    local explained = false
    for _, item in ipairs(gate:GetDescendants()) do
      if item:IsA("TextLabel") and item.Text:find("não foi encontrada", 1, true) then explained = true end
    end
    assert(explained, "invalid key error was not explained")
  `,
));

test("Nothrilo V2 fails closed when the JNKIE SDK cannot be downloaded", () => fixture(
  {}, submit, `${gateVisible}
    assert(#result.sdkCalls == 0, "unavailable SDK was called")
    assert(gate:FindFirstChild("Verify", true).Active, "SDK failure left verify disabled")
    local explained = false
    for _, item in ipairs(gate:GetDescendants()) do
      if item:IsA("TextLabel") and item.Text:find("carregar a biblioteca", 1, true) then explained = true end
    end
    assert(explained, "SDK failure has no visible explanation")
  `,
));

test("Nothrilo V2 prefills a cached session key without treating it as validated", () => fixture(
  { sdk: true, sessionKey: "fixture-session-key" }, "", `${gateVisible}
    assert(gate:FindFirstChild("KeyInput", true).Text == "fixture-session-key", "session key was not prefilled")
    assert(#result.sdkCalls == 0, "prefill unexpectedly submitted the key")
  `,
));

test("Nothrilo V2 generates and copies the SDK link without exposing the menu", () => fixture(
  { sdk: true, sdkDelay: 0.1 }, `
    gate:FindFirstChild("linkvertise", true).Activated:Fire()
    env.task.wait(0.2)
    gate:FindFirstChild("CopyLink", true).Activated:Fire()
  `, `${gateVisible}
    local link = "https://jnkie.com/get-key/nothrilov2"
    assert(gate:FindFirstChild("KeyLink", true).Text == link, "SDK link was not displayed")
    assert(#result.sdkCalls == 1 and result.sdkCalls[1].name == "get_key_link", "unexpected link calls")
    assert(result.sdkCalls[1].service == "NothriloV2" and result.sdkCalls[1].identifier == "1177853", "link used renamed authentication identifiers")
    assert(#result.copiedText == 2 and result.copiedText[2] == link, "copy button did not copy the generated link")
  `,
));

test("Nothrilo V2 ignores double click and Enter while one SDK check is pending", () => fixture(
  { sdk: true, sdkValid: false, sdkDelay: 0.5 }, `${submit}
    gate:FindFirstChild("Verify", true).Activated:Fire()
    gate:FindFirstChild("KeyInput", true).FocusLost:Fire(true)
  `, `${gateVisible}
    assert(#result.sdkCalls == 1, "duplicate key requests ran while validation was busy: " .. #result.sdkCalls)
  `,
));

test("Nothrilo V2 does not submit a key while link generation is pending", () => fixture(
  { sdk: true, sdkDelay: 0.5 }, `
    gate:FindFirstChild("KeyInput", true).Text = "fixture-valid-key"
    gate:FindFirstChild("linkvertise", true).Activated:Fire()
    gate:FindFirstChild("Verify", true).Activated:Fire()
    gate:FindFirstChild("KeyInput", true).FocusLost:Fire(true)
  `, `${gateVisible}
    assert(#result.sdkCalls == 1 and result.sdkCalls[1].name == "get_key_link", "key check raced link generation")
  `,
));

test("Nothrilo V2 close cancels a pending check and disconnects key UI callbacks", () => fixture(
  { sdk: true, sdkDelay: 0.5, drainAfterMain: true }, `${submit}
    env.fixtureVerify = gate:FindFirstChild("Verify", true)
    env.fixtureClose = gate:FindFirstChild("Close", true)
    env.fixtureInput = gate:FindFirstChild("KeyInput", true)
    env.task.wait(0.1)
    env.fixtureClose.Activated:Fire()
  `, `
    assert(result.finished, "closed gate kept the bootstrap waiting")
    assert(not result.core:FindFirstChild("NothriloKeyGate"), "closed key gate leaked")
    assert(not result.core:FindFirstChild("NothriloRuntime"), "cancelled runtime leaked")
    assert(not result.core:FindFirstChild("NothriloClassicUI"), "closing a pending validation opened the menu")
    assert(result.env.SCRIPT_KEY == nil, "late response accepted a key after close")
    assert(result.env.fixtureVerify.Activated.ListenerCount() == 0, "verify connection leaked")
    assert(result.env.fixtureClose.Activated.ListenerCount() == 0, "close connection leaked")
    assert(result.env.fixtureInput.FocusLost.ListenerCount() == 0, "input connection leaked")
  `,
));

const inspectLayout = `
  local card = gate:FindFirstChild("Card", true)
  local promo = gate:FindFirstChild("PromoPanel", true)
  local panel = gate:FindFirstChild("ValidationPanel", true)
  assert(card and promo and panel, "two-panel key layout is missing")
  assert(promo.Parent == card and panel.Parent == card, "panels do not share the card")
  for _, name in ipairs({ "KeyInput", "KeyLink", "Verify", "linkvertise", "CopyLink", "Close" }) do
    local control = gate:FindFirstChild(name, true)
    assert(control and control:IsDescendantOf(panel), name .. " is outside the validation panel")
  end
  local scale = card:FindFirstChildOfClass("UIScale")
  assert(scale and scale.Scale > 0 and scale.Scale <= 1, "missing or invalid responsive scale")
  local viewport = result.env.workspace.CurrentCamera.ViewportSize
  local width = (card.Size.X.Scale * viewport.X + card.Size.X.Offset) * scale.Scale
  local height = (card.Size.Y.Scale * viewport.Y + card.Size.Y.Offset) * scale.Scale
  assert(width <= viewport.X - 15, "key card exceeds viewport width: " .. width)
  assert(height <= viewport.Y - 15, "key card exceeds viewport height: " .. height)
`;

for (const [width, height] of [[1366, 768], [390, 844], [844, 390]]) {
  test(`Nothrilo V2 key card fits the modeled ${width}x${height} viewport and groups its controls`, () => fixture(
    { viewportWidth: width, viewportHeight: height }, "", `${gateVisible}${inspectLayout}`,
  ));
}

test("Nothrilo V2 recomputes the key card fit after viewport rotation", () => fixture(
  { viewportWidth: 390, viewportHeight: 844 }, `
    local camera = env.workspace.CurrentCamera
    camera.ViewportSize = env.Vector2.new(844, 390)
    camera:GetPropertyChangedSignal("ViewportSize"):Fire()
  `, `${gateVisible}${inspectLayout}`,
));
