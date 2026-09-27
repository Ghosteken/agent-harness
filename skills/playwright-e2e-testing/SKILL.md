---
name: playwright-e2e-testing
description: Builds and maintains a persistent, CI-integrated Playwright end-to-end test suite for critical user journeys — page objects, fixtures, API-based auth/data setup, network and WebSocket mocking, visual regression, cross-browser coverage, and flake-resistant waiting strategies, scaled to handle complex multi-step and real-time features. Use when a feature needs a lasting, repeatable browser test (not a one-off manual check), when setting up E2E testing for a project, when tests are flaky or slow, or when asked to "write Playwright tests", "set up E2E testing", or "add visual regression tests".
---

# Playwright E2E Testing

## Overview

Writes real, checked-into-the-repo Playwright tests that run in CI on every change — a regression safety net, distinct from a one-off manual verification pass. Consolidates what were three overlapping, bulk-import skills (`e2e-testing`, `e2e-testing-patterns`, and a chunk of `playwright-skill`'s scope) into one, because a persistent test suite and a live debugging session are different jobs with different lifecycles.

## When to Use

- A feature or flow needs a lasting, repeatable browser test — not a one-time check of "does this work right now"
- Setting up Playwright for a project that doesn't have E2E coverage yet
- Existing E2E tests are flaky, slow, or hard to maintain
- A complex feature (multi-step flow, an authenticated precondition, real-time/WebSocket updates) needs test coverage that a naive script-per-test approach would make slow or brittle
- Visual regression, cross-browser, or CI integration is needed for browser-facing behavior
- NOT for a one-off "check if this works right now" pass during development — use `browser-testing-with-devtools` (live DOM/console/network inspection) for that, or `playwright-skill` for a disposable automation script
- NOT for unit or integration tests with no real browser involved — use `test-driven-development`
- NOT for accessibility auditing as its own goal — use `ui-a11y`/`wcag-audit-patterns`, though an axe scan can live inside this suite (see Step 9)

## Process

### 1. Identify the critical journeys, not everything

List the user journeys that actually justify E2E cost (login, checkout, signup, any multi-step flow where a regression would be a real incident) — not every possible interaction. E2E tests are slow and comparatively expensive to maintain; reserve them for what unit/integration tests can't cover (real browser rendering, real navigation, real cross-component wiring).

### 2. Set up the project (first time only)

Install `@playwright/test` and configure `playwright.config.ts`: `testDir`, per-environment `retries`/`workers` (`CI` env-gated), `trace: 'on-first-retry'`, `screenshot: 'only-on-failure'`, `video: 'retain-on-failure'`, and the browser projects actually needed (Chromium always; Firefox/WebKit/mobile viewports only if cross-browser or responsive coverage is in scope). For a setup that needs its own steps (seeding, auth), prefer a `setup` project with `dependencies` over `globalSetup` — a plain global function runs outside the test runner, so it can't use fixtures, doesn't support retries, and produces no trace on failure. See `patterns.md` for a working config. Skip this step if the project already has Playwright configured — extend the existing config, don't replace it.

### 3. Reuse authentication instead of re-logging in every test

Log in once, save the session via `storageState`, and reuse it across every test that needs an authenticated session — this alone typically cuts total login time by 60-80% across a suite and removes a whole class of login-flow flakiness from tests that aren't actually about login. Prefer authenticating via a direct API call over driving the login form through the UI — it's faster and isolates "is the user logged in" from "does the login form work" (which gets its own dedicated test). Fall back to UI login only when the app's auth uses tokens/challenges too complex to replicate via a simple API call. See `patterns.md` for the setup-project pattern.

### 4. Seed complex preconditions via API, never by driving the UI through them

This is the single highest-leverage technique for a complex feature: never reach a complex precondition (a multi-step wizard half-completed, a specific account state, a populated dataset) by scripting the UI through every step first. Seed it directly — a guarded, non-production-only `/api/test/seed`-style endpoint that bulk-creates the scenario in one atomic call, or a direct DB write. This makes the test about the feature under test, not a slow, brittle re-enactment of getting there. Give every seeded record an identifier no other test can produce, and delete it in teardown (`afterEach`/fixture teardown) so parallel tests never collide or leak state.

If a feature touches a genuinely shared, unisolatable resource (a global account setting, a rate-limited sandbox credential, a singleton external service) rather than per-test data, isolating via a unique identifier isn't possible — declare a named `lock` on those tests instead (`test('...', { lock: 'shared-resource-name' }, ...)`). Locked tests never run concurrently with each other, across files or workers, while everything else keeps running in parallel — this is the correct tool for that specific problem, not a reason to disable parallelism for the whole suite.

### 5. Use stable selectors

Prefer, in order: `getByRole` (also doubles as an accessibility check), then `getByLabel`, `getByText`, or `data-testid` — over CSS classes or DOM position (`nth-child`, class chains). A selector coupled to styling or structure breaks on every unrelated refactor; a role/label/testid selector breaks only when the actual user-facing contract changes. For a feature embedding third-party content (a payment widget, an embedded iframe), `page.frameLocator()` called with no selector searches every frame in the page automatically — locate the target directly instead of first locating the iframe.

### 6. Structure with Page Objects and fixtures

Encapsulate each page's locators and actions in a Page Object class; use fixtures for test data setup/teardown (create in the fixture, clean up after, never leave orphaned test data). This is what keeps tests maintainable past the first handful — see `patterns.md` for the Page Object and fixture patterns.

### 7. Wait on conditions, never on fixed timeouts — including WebSocket/real-time updates

`waitForTimeout(3000)` is a red flag by itself — it's simultaneously slower than necessary (always waits the full duration) and flakier than necessary (still races real load times). Use `waitForURL`, `waitForSelector`, `waitForLoadState`, `waitForResponse`, or an auto-waiting `expect(...).toBeVisible()`/`toBeEnabled()` instead. For a feature with WebSocket or SSE-driven UI, mock the socket/stream directly (Playwright supports bidirectional WebSocket mocking) rather than waiting on a fixed delay for a real-time update to arrive — this is both faster and deterministic. Mock network responses (`page.route`) for external/third-party dependencies (payment providers, etc.) so tests don't depend on a live third party's uptime or state. Disable CSS animations/transitions in the test environment — they're a common, easily-removed source of flakiness in "element not stable" failures.

### 8. Use `test.step` and soft assertions for complex, multi-part workflows

Wrap each logical phase of a long or multi-step test in `test.step(...)` — it names the phase in reports and traces, so a failure points at which phase broke, not just which test. For verification-heavy assertions that are genuinely independent of each other (every field in a rendered form, every row in a table, every item in a summary panel), use `expect.soft(...)` so a failure in one doesn't hide failures in the rest — you see the whole picture in one run instead of fix-rerun-fix-rerun. Never use soft assertions when later steps in the same test depend on an earlier one having passed.

### 9. Add visual regression and cross-browser coverage, only where it earns its cost

Visual regression (`toHaveScreenshot`) is worth it for pages/components where a pixel-level regression is a real risk (marketing pages, design-system components) — not blanket-applied to every test, since it adds maintenance overhead (baseline updates) for every deliberate visual change. Cross-browser projects (Firefox, WebKit, mobile emulation) are worth it when the product actually needs that coverage — not by default for an internal tool that only ever runs in Chromium. If a complex component needs assertions a full page load can't cheaply give you (isolated prop/state combinations), consider Playwright component testing for that piece specifically rather than routing everything through a full E2E page.

### 10. Wire into CI

Run headless in CI (`retries: 2`, `workers: 1` typical for CI stability), capture trace/video/screenshot artifacts on failure, and shard for parallelism once the suite is large enough to benefit. Hand off to `ci-cd-and-automation` for the actual pipeline wiring — this skill owns the test suite, not the CI infrastructure around it.

### 11. Debug failures with the trace, not guesswork

On a failing test: run `--headed` or `--debug` locally to watch it, or open the CI-captured trace (`npx playwright show-trace`) rather than staring at a stack trace and guessing. Enable aria and screenshot snapshots in trace config (`trace: { mode: 'on', snapshots: { dom: true, aria: true, screen: true } }`) so the trace viewer's Aria mode shows the action's screenshot next to its accessibility tree — a fast way to tell "wrong element" from "element not visible yet" apart. If a test is flaky rather than reliably failing, check the root causes in order before adding a retry as a band-aid: a race condition (missing condition-based wait), a brittle selector, polluted state from a prior test (missing teardown), or cross-environment rendering variance (uncontrolled animation).

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll E2E-test everything to be safe" | E2E tests are slow and comparatively expensive to maintain — reserve them for journeys where a regression is a real incident; push everything else down to unit/integration tests. |
| "A fixed `waitForTimeout` is simpler" | It's simultaneously slower (always waits the full duration) and flakier (still races real load) than waiting on an actual condition — never the simpler choice once a suite has more than a couple of tests. |
| "CSS class selectors are fine, they're already there" | A selector coupled to styling breaks on any unrelated refactor — `getByRole`/`getByLabel`/`data-testid` only break when the user-facing contract changes, which is the failure you actually want to catch. |
| "I'll just log in through the UI at the start of every test" | Reusing a saved `storageState` cuts total login time 60-80% across a suite and removes login-flow flakiness from tests that aren't about login — reserve UI login for the login test itself. |
| "I'll click through the UI to get to this complex precondition" | Seeding the precondition via API/DB is faster, atomic, and isolates the feature under test from the steps needed to reach it — UI-driven setup is itself a source of flakiness for the thing you're not even testing. |
| "I'll add visual regression to every test for thoroughness" | Blanket visual regression means updating baselines on every deliberate visual change — apply it where a pixel regression is a real risk, not everywhere. |
| "Cross-browser coverage can't hurt" | Every additional browser project multiplies CI time and flake surface — add it because the product needs that coverage, not as a default. |
| "I'll skip Page Objects for this small suite" | The suite that stays small never needed this skill's process in the first place — if it's growing past a handful of tests, encapsulate now, not after the duplication is already everywhere. |
| "I'll hit the real third-party API in this test" | A test that depends on a live third party's uptime/state is flaky by construction — mock it with `page.route`. |
| "This test keeps flaking, I'll just add a retry" | A retry hides the actual cause (race condition, brittle selector, leftover state, uncontrolled animation) instead of fixing it — diagnose first, retry only as a last resort for genuine environment variance. |
| "This test touches a shared resource, I'll disable parallelism for the whole suite" | A named `lock` serializes only the tests that actually share that resource — everything else keeps running in parallel; disabling parallelism suite-wide throws away the speed of every unrelated test. |
| "I'll use `expect.soft` everywhere so the test doesn't stop early" | Soft assertions are for genuinely independent checks (every field in a form) — if a later step depends on an earlier one passing, a soft assertion lets the test continue on a false premise. |

## Red Flags

- `waitForTimeout` used as the primary wait strategy instead of a condition-based wait
- Selectors built from CSS classes or DOM position (`nth-child`) instead of role/label/testid
- A test logs in through the UI when it isn't the login test itself, instead of reusing `storageState`
- A complex precondition reached by scripting the UI through every step instead of seeding it via API/DB
- A growing suite with no Page Object or fixture structure — logic and locators duplicated across test files
- A test that hits a live third-party service instead of a mock
- Real-time/WebSocket-driven UI tested with a fixed wait instead of mocking the socket
- Visual regression or cross-browser projects added everywhere rather than where they're actually needed
- E2E tests written for logic that unit/integration tests already cover better and faster
- CI runs with no failure artifacts (trace/video/screenshot) captured, making a CI-only failure unreproducible locally
- A failing or flaky test re-run repeatedly hoping it passes, instead of diagnosing the actual cause

## Verification

- [ ] Tests cover the identified critical journeys, not an exhaustive interaction list
- [ ] Authenticated tests reuse a saved `storageState` rather than logging in through the UI each time
- [ ] Complex preconditions are seeded via API/DB, not reached by driving the UI through every step
- [ ] Selectors use `getByRole`/`getByLabel`/`data-testid`, not CSS classes or DOM position
- [ ] Page Objects and/or fixtures back any suite beyond a handful of tests
- [ ] No `waitForTimeout` as a primary wait strategy — condition-based waits throughout, including for WebSocket/real-time updates
- [ ] External/third-party dependencies (and WebSocket/SSE streams, where applicable) are mocked, not hit live
- [ ] Long or multi-step tests use `test.step`; soft assertions are used only for genuinely independent checks
- [ ] Visual regression and cross-browser projects are present only where they earn their cost
- [ ] CI runs headless with trace/video/screenshot capture on failure
- [ ] Test data is uniquely identified and cleaned up in teardown — no cross-test leakage
- [ ] The suite actually passes locally and in CI before being called done

## See Also

- `browser-testing-with-devtools` — a live, interactive verification pass in the current session; use that for "does this work right now", this skill for a lasting regression test
- `playwright-skill` — a disposable, one-off Playwright automation script (screenshot, quick check); use that instead of this skill when nothing needs to persist as a checked-in test
- `test-driven-development` — for logic that doesn't need a real browser
- `ci-cd-and-automation` — wires this suite into the actual CI pipeline
- `ui-a11y` / `wcag-audit-patterns` — accessibility auditing as its own goal, beyond an axe scan folded into this suite
- `patterns.md` — Playwright config, auth-reuse, API seeding, Page Object, fixture, waiting-strategy, network/WebSocket-mocking, `test.step`/soft-assertion, visual-regression, sharding, and debugging code patterns referenced above
