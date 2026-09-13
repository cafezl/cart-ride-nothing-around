import { readFile, writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { resolve } from "node:path";

export const aliases = [
  { source: "cafezitos/Cafezitos.lua", targets: ["cafezitos/Cafezitos-V2.lua", "cafezitos/Cafezitos-completo.lua"] },
];

export async function syncAliases({ write = false } = {}) {
  const root = fileURLToPath(new URL("../", import.meta.url));
  const changed = [];
  for (const { source, targets } of aliases) {
    const contents = await readFile(resolve(root, source));
    for (const target of targets) {
      const current = await readFile(resolve(root, target)).catch((error) => {
        if (error.code === "ENOENT") return Buffer.alloc(0);
        throw error;
      });
      if (contents.equals(current)) continue;
      changed.push(target);
      if (write) await writeFile(resolve(root, target), contents);
    }
  }
  return changed;
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const write = process.argv.includes("--write");
  const changed = await syncAliases({ write });
  if (changed.length) {
    console.log(`${write ? "Synchronized" : "Out-of-date aliases"}: ${changed.join(", ")}`);
    if (!write) process.exitCode = 1;
  } else {
    console.log("All public aliases match their maintained source.");
  }
}
