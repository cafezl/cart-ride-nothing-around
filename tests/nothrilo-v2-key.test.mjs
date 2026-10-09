import assert from "node:assert/strict";
import test from "node:test";
import { readFile } from "node:fs/promises";

const root = new URL("../", import.meta.url);

test("Nothrilo V2 delegates its key screen and menu to the published JNKIE source", async () => {
  const source = await readFile(new URL("nothrilov2/nothrilov2", root), "utf8");
  const expected = "https://api.jnkie.com/api/v1/luascripts/public/500cf49497956113c8fecf4df89e45df90c17c72f7ca25b13eebac9e39881937/download";
  assert.match(source, new RegExp(`loadstring\\(game:HttpGet\\(\"${expected}\"\\)\\)\\(\\)`));
});
