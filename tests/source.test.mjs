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

test("production deploy keeps only Linkvertise configured and runs a smoke test", async () => {
  const config = JSON.parse(await readFile(new URL("key-server/wrangler.jsonc", root), "utf8"));
  const value = config.vars?.LINKVERTISE_URL;
  assert.equal(typeof value, "string", "LINKVERTISE_URL is missing");
  assert.doesNotMatch(value, /REPLACE/i, "LINKVERTISE_URL still contains a placeholder");
  const url = new URL(value);
  assert.equal(url.protocol, "https:", "LINKVERTISE_URL must use HTTPS");
  assert.equal(url.hostname, "direct-link.net", "LINKVERTISE_URL uses an unexpected host");
  assert.equal(url.username, "", "LINKVERTISE_URL must not contain credentials");
  assert.equal(url.password, "", "LINKVERTISE_URL must not contain credentials");
  assert.equal(config.vars?.WORKINK_URL, undefined);
  assert.equal(config.vars?.WORKINK_LINK_ID, undefined);
  assert.equal(config.vars?.LOOTLABS_URL, undefined);

  const workflow = await readFile(new URL(".github/workflows/deploy-key-server.yml", root), "utf8");
  assert.match(workflow, /push:\s*\n\s+branches:\s*\n\s+- main/);
  assert.match(workflow, /pnpm run smoke:production/);
  const worker = await readFile(new URL("key-server/src/index.js", root), "utf8");
  assert.doesNotMatch(worker, /callback\/(?:workink|lootlabs)|WORKINK_|LOOTLABS_|work\.ink|loot-link/i);
});
