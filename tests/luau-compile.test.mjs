import assert from "node:assert/strict";
import test from "node:test";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { listPublishedLuaSources } from "../scripts/menu-sources.mjs";

const root = fileURLToPath(new URL("../", import.meta.url));
const compiler = process.env.LUAU_COMPILE_BIN || "luau-compile";
const sources = await listPublishedLuaSources();

for (const level of [0, 1, 2]) {
  test(`all ${sources.length} published Lua files compile at O${level}`, () => {
    const result = spawnSync(compiler, ["--null", `-O${level}`, ...sources], {
      cwd: root, encoding: "utf8", timeout: 20000, maxBuffer: 2 * 1024 * 1024,
    });
    assert.equal(result.status, 0, result.error?.message || result.stderr || result.stdout);
  });
}
