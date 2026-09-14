import assert from "node:assert/strict";
import test from "node:test";
import { readFile } from "node:fs/promises";
import { listPublishedLuaSources } from "../scripts/menu-sources.mjs";

const root = new URL("../", import.meta.url);

test("published Lua files contain code, not terminal transcripts or truncated answers", async () => {
  for (const path of await listPublishedLuaSources()) {
    const source = await readFile(new URL(path, root), "utf8");
    assert.doesNotMatch(source, /^(?:Exit code:|Wall time:|Total output lines:|Output:|```)/m, path);
    assert.doesNotMatch(source, /\d+ tokens truncated|output truncated/i, path);
    assert.ok(source.trim().startsWith("--"), `${path}: missing source header`);
  }
});

test("the Nothrilo V2 public entrypoint loads the maintained JNKIE source", async () => {
  const source = await readFile(new URL("nothrilov2/nothrilov2", root), "utf8");
  const expected = "https://api.jnkie.com/api/v1/luascripts/public/500cf49497956113c8fecf4df89e45df90c17c72f7ca25b13eebac9e39881937/download";
  assert.match(source, new RegExp(`loadstring\\(game:HttpGet\\(\"${expected}\"\\)\\)\\(\\)`));
  assert.equal((source.match(/loadstring\s*\(/g) || []).length, 1, "entrypoint must contain exactly one loader");
});
