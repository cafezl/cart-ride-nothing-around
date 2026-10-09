import { fileURLToPath } from "node:url";
import { resolve } from "node:path";

// Compatibility copies were intentionally removed. Keep this helper harmless
// for anyone who still invokes it from an older local checkout.
export const aliases = [];

export async function syncAliases() {
  return [];
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  console.log("No compatibility aliases are configured.");
}
