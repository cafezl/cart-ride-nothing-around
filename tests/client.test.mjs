import assert from "node:assert/strict";
import test from "node:test";
import { mkdtemp, readFile, readdir, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

const root = fileURLToPath(new URL("../", import.meta.url));
const compiler = process.env.LUAU_COMPILE_BIN || "luau-compile";
const interpreter = process.env.LUAU_BIN || "luau";
const harness = await readFile(new URL("./client-harness.lua", import.meta.url), "utf8");
const sources = (await readdir(root)).filter((name) => name.endsWith(".lua"));

function longString(value) {
  let fence = "=";
  while (value.includes(`]${fence}]`)) fence += "=";
  return `[${fence}[${value}]${fence}]`;
}

for (const level of [0, 1, 2]) {
  test(`all ${sources.length} published Lua files compile at O${level}`, () => {
    const result = spawnSync(compiler, ["--null", `-O${level}`, ...sources], {
      cwd: root, encoding: "utf8", timeout: 20000, maxBuffer: 2 * 1024 * 1024,
    });
    assert.equal(result.status, 0, result.error?.message || result.stderr || result.stdout);
  });
}

async function fixture(name, options, checks) {
  const directory = await mkdtemp(join(tmpdir(), "cafezl-client-test-"));
  try {
    const source = await readFile(join(root, name), "utf8");
    const fields = Object.entries({ name, ...options }).map(([key, value]) => (
      `${key}=${typeof value === "string" ? longString(value) : String(value)}`
    )).join(",");
    const path = join(directory, "bootstrap.lua");
    await writeFile(path, `${harness}\nlocal result = runFixture(${longString(source)}, {${fields}})\n${checks}\n`);
    const result = spawnSync(interpreter, [path], {
      cwd: root, encoding: "utf8", timeout: 20000, maxBuffer: 2 * 1024 * 1024,
    });
    assert.equal(result.status, 0, result.error?.message || result.stderr || result.stdout);
  } finally {
    await rm(directory, { recursive: true, force: true });
  }
}

for (const [name, window] of [
  ["Cafezitos.lua", "CafezitosV2UI"],
  ["Nothrilo.lua", "NothriloClassicUI"],
  ["Nothrilo-classico-funcoes-corrigidas.lua", "NothriloClassicUI"],
]) {
  const visible = `
    assert(#result.failures == 0, table.concat(result.failures, "\\n"))
    assert(result.finished, "main bootstrap did not finish")
    local gui = result.core:FindFirstChild("${window}") or result.playerGui:FindFirstChild("${window}")
    assert(gui and gui.Enabled, "main window did not become visible")
    assert(#gui:GetDescendants() > 100, "menu lost its content")
    assert(gui:FindFirstChild("ComandosTabButton", true), "commands tab was lost")
  `;
  test(`${name}: builds a visible menu in the bootstrap model`, () => fixture(name, {}, visible));
  test(`${name}: waits for the player/GUI and falls back from an unusable gethui/CoreGui`, () => (
    fixture(name, { playerDelay: 0.2, guiDelay: 0.4, blockCore: true, badHui: true }, `${visible}
      assert(gui.Parent == result.playerGui, "expected PlayerGui fallback")
    `)
  ));
}

test("Nothrilo keeps the key gate closed when verification is unavailable", () => fixture(
  "Nothrilo.lua", { networkFailure: true, maxTime: 1 }, `
    assert(#result.failures == 0, table.concat(result.failures, "\\n"))
    assert(not result.finished, "the menu must not skip failed verification")
    assert(result.core:FindFirstChild("NothriloKeyGate"), "the key UI disappeared")
    assert(not result.core:FindFirstChild("NothriloClassicUI"), "unverified menu was created")
  `,
));

test("Nothrilo discovers an inherited request function when client HttpService is unavailable", () => fixture(
  "Nothrilo.lua", { inheritedRequest: true }, `
    assert(#result.failures == 0, table.concat(result.failures, "\\n"))
    assert(result.finished, "inherited request function was ignored")
    local gui = result.core:FindFirstChild("NothriloClassicUI")
    assert(gui and gui.Enabled, "verified menu did not open")
  `,
));

for (const name of ["Cafezitos.lua", "Nothrilo.lua"]) {
  test(`${name}: reports a missing local player after a bounded wait`, () => fixture(name, { noPlayer: true }, `
    assert(result.finished, "missing-player wait did not end")
    assert(#result.failures == 1, "expected one descriptive client-context error")
    assert(result.failures[1]:find("jogador local", 1, true), result.failures[1])
    assert(result.elapsed >= 10 and result.elapsed < 10.2, "unexpected wait budget")
  `));
}

test("diagnostic loader shows a closable error instead of failing silently", () => fixture(
  "Cafezitos-teste.lua", {}, `
    assert(#result.failures == 0, table.concat(result.failures, "\\n"))
    assert(result.finished)
    local gui = result.core:FindFirstChild("CafezitosDiagnostic")
    assert(gui and gui.Enabled, "missing diagnostic UI")
    assert(#result.warnings == 1, "missing console diagnostic")
  `,
));
