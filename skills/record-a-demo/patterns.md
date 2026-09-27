# Record-a-Demo Patterns

Code patterns referenced by `SKILL.md`. Adapt to the project's actual conventions.

## Recording with the built-in action annotation (prefer this first)

```typescript
const DIR = 'demos/<feature-slug>'; // under the project's external output location

await page.goto('https://app.example.com/login');
await page.getByRole('textbox', { name: 'Email' }).waitFor({ state: 'visible' }); // settle before recording

await page.screencast.start({ path: `${DIR}/<scenario-slug>.webm`, size: { width: 1280, height: 800 } });
await page.screencast.showActions({ cursor: 'pointer' }); // built-in cursor/click visualization

await page.getByRole('textbox', { name: 'Email' }).pressSequentially('user@example.com', { delay: 60 });
await page.getByRole('textbox', { name: 'Password' }).pressSequentially('secret', { delay: 60 });
await page.getByRole('button', { name: 'Sign in' }).click();
await page.waitForURL('**/dashboard');

await page.screenshot({ path: `${DIR}/<scenario-slug>__post-login.png` }); // key-beat verification shot

const box = await page.getByText('Welcome back').boundingBox();
await page.screencast.showOverlay(
  `<div style="position:absolute;top:${box.y - 34}px;left:${box.x}px;padding:8px 14px;
    border-radius:10px;background:rgba(17,24,39,0.85);color:#fff;font-size:13px;
    box-shadow:0 4px 14px rgba(0,0,0,0.25);">Your dashboard</div>`,
  { duration: 1800 }
);

await page.screencast.stop();
```

`showActions()` and `showOverlay()` both return a `Disposable` when no `duration` is given — dispose explicitly if you need the annotation to end before the next one starts.

## Fallback: custom synthetic cursor (only if `showActions()` isn't enough)

```javascript
await page.addInitScript(() => {
  window.__cursor = window.__cursor || { x: 0, y: 0 };
  const ensure = () => {
    if (document.getElementById('__demo_cursor') || !document.body) return;
    const dot = document.createElement('div');
    dot.id = '__demo_cursor';
    Object.assign(dot.style, {
      position: 'fixed', left: window.__cursor.x + 'px', top: window.__cursor.y + 'px',
      width: '22px', height: '22px', marginLeft: '-11px', marginTop: '-11px',
      borderRadius: '50%', background: 'rgba(20,20,20,0.35)',
      border: '2px solid rgba(255,255,255,0.95)', boxShadow: '0 1px 4px rgba(0,0,0,0.4)',
      zIndex: '2147483647', pointerEvents: 'none',
      transition: 'left 40ms linear, top 40ms linear',
    });
    document.body.appendChild(dot);
  };
  const start = () => {
    ensure();
    new MutationObserver(ensure).observe(document.documentElement, { childList: true, subtree: true });
  };
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start);
  else start();
  window.__moveCursor = (x, y) => {
    window.__cursor = { x, y };
    const dot = document.getElementById('__demo_cursor');
    if (dot) { dot.style.left = x + 'px'; dot.style.top = y + 'px'; }
  };
  window.__ripple = (x, y) => {
    const r = document.createElement('div');
    Object.assign(r.style, {
      position: 'fixed', left: x + 'px', top: y + 'px', width: '8px', height: '8px',
      marginLeft: '-4px', marginTop: '-4px', borderRadius: '50%',
      border: '2px solid rgba(60,130,255,0.9)', zIndex: '2147483646',
      pointerEvents: 'none', transition: 'all 350ms ease-out',
    });
    document.body.appendChild(r);
    requestAnimationFrame(() => {
      r.style.width = '44px'; r.style.height = '44px';
      r.style.marginLeft = '-22px'; r.style.marginTop = '-22px';
      r.style.opacity = '0';
    });
    setTimeout(() => r.remove(), 400);
  };
});

const pause = (ms) => page.waitForTimeout(ms);

async function glide(x, y, steps = 24) {
  const from = await page.evaluate(() => window.__cursor || { x: 0, y: 0 });
  for (let i = 1; i <= steps; i++) {
    const nx = from.x + (x - from.x) * (i / steps);
    const ny = from.y + (y - from.y) * (i / steps);
    await page.mouse.move(nx, ny);
    await page.evaluate(([nx, ny]) => window.__moveCursor(nx, ny), [nx, ny]);
    await page.waitForTimeout(16);
  }
}

async function show(locator) {
  await locator.scrollIntoViewIfNeeded();
  const box = await locator.boundingBox();
  const x = box.x + box.width / 2, y = box.y + box.height / 2;
  await glide(x, y);
  await pause(250);
  await page.evaluate(([x, y]) => window.__ripple(x, y), [x, y]);
  await locator.click();
}
```

## Waiting for a stream to actually finish (never network-idle)

```typescript
// Bad: blocks until timeout — the streaming connection never goes idle
await page.waitForLoadState('networkidle');

// Good: poll for the response text holding steady across consecutive checks
async function waitForStreamToSettle(page, locator, { pollMs = 400, stableChecks = 3, timeoutMs = 60000 }) {
  const start = Date.now();
  let lastText = '';
  let stableCount = 0;
  while (Date.now() - start < timeoutMs) {
    const text = (await locator.textContent()) ?? '';
    if (text === lastText && text.length > 0) {
      stableCount++;
      if (stableCount >= stableChecks) return text;
    } else {
      stableCount = 0;
    }
    lastText = text;
    await page.waitForTimeout(pollMs);
  }
  throw new Error('Stream did not settle within timeout');
}
```

## Extracting a frame to inspect a webm's actual content

```bash
# Locate Playwright's bundled ffmpeg rather than assuming a fixed path — it
# varies by OS/environment (e.g. under the Playwright browsers cache dir).
FFM=$(find "$(node -e "console.log(require('playwright-core').registry?.markAsRequired ? '' : '')" 2>/dev/null; echo "${PLAYWRIGHT_BROWSERS_PATH:-$HOME/.cache/ms-playwright}")" -iname 'ffmpeg*' -type f 2>/dev/null | head -1)
# Fall back to a system ffmpeg if Playwright's bundled one isn't found
FFM="${FFM:-$(command -v ffmpeg)}"

"$FFM" -y -i clip.webm -ss 4 -frames:v 1 frame.png   # accurate seek: -ss AFTER -i
"$FFM" -y -i clip.webm -update 1 last.png            # last frame
```
