import assert from "node:assert/strict";
import test from "node:test";
import { readFile, readdir } from "node:fs/promises";
import { aliases, syncAliases } from "../scripts/sync-aliases.mjs";

const root = new URL("../", import.meta.url);

test("all compatibility URLs contain the complete maintained source", async () => {
  assert.deepEqual(await syncAliases(), [], "Run npm run sync:aliases before committing.");
  for (const { source, targets } of aliases) {
    const bytes = await readFile(new URL(source, root));
    assert.ok(bytes.length > 100000, `${source} unexpectedly lost most of its content`);
    for (const target of targets) assert.deepEqual(await readFile(new URL(target, root)), bytes);
  }
});

test("published Lua files contain code, not terminal transcripts or truncated answers", async () => {
  for (const path of (await readdir(root)).filter((name) => name.endsWith(".lua"))) {
    const source = await readFile(new URL(path, root), "utf8");
    assert.doesNotMatch(source, /^(?:Exit code:|Wall time:|Total output lines:|Output:|```)/m, path);
    assert.doesNotMatch(source, /\d+ tokens truncated|output truncated/i, path);
    assert.ok(source.trim().startsWith("--"), `${path}: missing source header`);
  }
});

test("the diagnostic loader targets maintained sources and bounds its error output", async () => {
  const source = await readFile(new URL("Cafezitos-teste.lua", root), "utf8");
  assert.doesNotMatch(source, /main\/Cafezitos-completo\.lua/);
  assert.match(source, /CafezlDiagnosticTarget/);
  assert.match(source, /CafezlDiagnosticRef/);
  assert.match(source, /pcall\(loadstring/);
  assert.match(source, /:sub\(1, 1600\)/);
});
