#!/usr/bin/env node
// Pixel-diff helper for UI validation. Self-contained: resolves pngjs/pixelmatch
// from whatever the runtime provides, else installs them once into a shared /tmp
// dir. Usage:
//   node pixel-diff.mjs <impl.png> <ref.png> <out-mask.png> [threshold=0.15]
// Prints JSON: { numDiff, pct, width, height } and writes the diff mask to <out>.

import { readFileSync, writeFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { execFileSync } from 'node:child_process';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';

const depsDir = '/tmp/qa-pixel-diff'; // shared across runs in a session; cleared with /tmp

// Load { PNG, pixelmatch } using a require rooted at `base`.
// pngjs is CJS (require), pixelmatch@7 is ESM (resolve path, then import as URL).
async function loadFrom(base) {
  const req = createRequire(base);
  const { PNG } = req('pngjs');
  const pixelmatch = (await import(pathToFileURL(req.resolve('pixelmatch')).href)).default;
  return { PNG, pixelmatch };
}

async function getDeps() {
  const depsBase = pathToFileURL(join(depsDir, 'index.js')).href;

  // 1. Whatever the runtime already provides (provisioned sandbox, or a
  //    node_modules at/above this script). No network, no side effects.
  try {
    return await loadFrom(import.meta.url);
  } catch {
    /* fall through */
  }

  // 2. A previous run's install in the shared /tmp dir. Skips npm entirely,
  //    so it works offline once the first run of the session has bootstrapped.
  try {
    return await loadFrom(depsBase);
  } catch {
    /* fall through */
  }

  // 3. First run of the session: install once into the shared /tmp dir.
  execFileSync('npm', ['i', '--prefix', depsDir, 'pngjs@^7', 'pixelmatch@^7'], {
    stdio: 'inherit',
  });
  return await loadFrom(depsBase);
}

// Nearest-neighbour resize (no `canvas`); pixelmatch requires identical dimensions.
function resizeTo(PNG, src, w, h) {
  if (src.width === w && src.height === h) return src;
  const out = new PNG({ width: w, height: h });
  for (let y = 0; y < h; y++) {
    const sy = Math.min(src.height - 1, Math.floor((y / h) * src.height));
    for (let x = 0; x < w; x++) {
      const sx = Math.min(src.width - 1, Math.floor((x / w) * src.width));
      const si = (sy * src.width + sx) * 4;
      const di = (y * w + x) * 4;
      out.data[di] = src.data[si];
      out.data[di + 1] = src.data[si + 1];
      out.data[di + 2] = src.data[si + 2];
      out.data[di + 3] = src.data[si + 3];
    }
  }
  return out;
}

async function main() {
  const [implPath, refPath, outPath, thresholdArg] = process.argv.slice(2);
  if (!implPath || !refPath || !outPath) {
    console.error('usage: node pixel-diff.mjs <impl.png> <ref.png> <out-mask.png> [threshold=0.15]');
    process.exit(2);
  }
  const threshold = Number(thresholdArg ?? 0.15);

  const { PNG, pixelmatch } = await getDeps();

  const ref = PNG.sync.read(readFileSync(refPath)); // Figma frame is canonical
  const { width, height } = ref;
  const impl = resizeTo(PNG, PNG.sync.read(readFileSync(implPath)), width, height);
  const diff = new PNG({ width, height });

  const numDiff = pixelmatch(impl.data, ref.data, diff.data, width, height, { threshold });
  writeFileSync(outPath, PNG.sync.write(diff));

  const pct = Number(((numDiff / (width * height)) * 100).toFixed(2));
  console.log(JSON.stringify({ numDiff, pct, width, height }));
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
