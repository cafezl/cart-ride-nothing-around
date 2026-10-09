import { readdir } from "node:fs/promises";

const root = new URL("../", import.meta.url);
const directories = ["cafezitos", "nothrilov2"];
const requiredSources = [
  "cafezitos/Cafezitos.lua",
  "nothrilov2/nothrilov2",
];

export async function listPublishedLuaSources() {
  const sources = [];
  async function visit(directory) {
    for (const entry of await readdir(new URL(`${directory}/`, root), { withFileTypes: true })) {
      const path = `${directory}/${entry.name}`;
      if (entry.isDirectory()) await visit(path);
      else if (entry.isFile() && (path.endsWith(".lua") || path === "nothrilov2/nothrilov2")) sources.push(path);
    }
  }
  for (const directory of directories) await visit(directory);
  for (const path of requiredSources) {
    if (!sources.includes(path)) throw new Error(`Published menu source is missing: ${path}`);
  }
  return sources.sort();
}
