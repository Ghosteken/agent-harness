---
name: playwright-e2e-testing
description: Builds and maintains a persistent, CI-integrated Playwright end-to-end test suite for critical user journeys — page objects, fixtures, network mocking, visual regression, cross-browser coverage, and flake-resistant waiting strategies. Use when a feature needs a lasting, repeatable browser test (not a one-off manual check), when setting up E2E testing for a project, when tests are flaky or slow, or when asked to "write Playwright tests", "set up E2E testing", or "add visual regression tests".
---

# Playwright E2E Testing

## Overview

Writes real, checked-into-the-repo Playwright tests that run in CI on every change — a regression safety net, distinct from a one-off manual verification pass. Consolidates what were three overlapping, bulk-import skills (`e2e-testing`, `e2e-testing-patterns`, and a chunk of `playwright-skill`'s scope) into one, because a persistent test suite and a live debugging session are different jobs with different lifecycles.

## When to Use

- A feature or flow needs a lasting, repeatable browser test — not a one-time check of "does this work right now"
- Setting up Playwright for a project that doesn't have E2E coverage yet
- Existing E2E tests are flaky, slow, or hard to maintain
- Visual regression, cross-browser, or CI integration is needed for browser-facing behavior
- NOT for a one-off "check if this works right now" pass during development — use `browser-testing-with-devtools` (live DOM/console/network inspection) for that, or `playwright-skill` for a disposable automation script
- NOT for unit or integration tests with no real browser involved — use `test-driven-development`
- NOT for accessibility auditing as its own goal — use `ui-a11y`/`wcag-audit-patterns`, though an axe scan can live inside this suite (see Step 5)

## Process

### 1. Identify the critical journeys, not everything

List the user journeys that actually justify E2E cost (login, checkout, signup, any multi-step flow where a regression would be a real incident) — not every possible interaction. E2E tests are slow and comparatively expensive to maintain; reserve them for what unit/integration tests can't cover (real browser rendering, real navigation, real cross-component wiring).

### 2. Set up the project (first time only)

Install `@playwright/test` and configure `playwright.config.ts`: `testDir`, per-environment `retries`/`workers` (`CI` env-gated), `trace: 'on-first-retry'`, `screenshot: 'only-on-failure'`, `video: 'retain-on-failure'`, and the browser projects actually needed (Chromium always; Firefox/WebKit/mobile viewports only if cross-browser or responsive coverage is in scope). See `patterns.md` for a working config. Skip this step if the project already has Playwright configured — extend the existing config, don't replace it.

### 3. Use stable selectors

Prefer `getByRole`, `getByLabel`, and `data-testid` over CSS classes or DOM position (`nth-child`, class chains). A selector coupled to styling or structure breaks on every unrelated refactor; a role/label/testid selector breaks only when the actual user-facing contract changes.

### 4. Structure with Page Objects and fixtures

Encapsulate each page's locators and actions in a Page Object class; use fixtures for test data setup/teardown (create in the fixture, clean up after, never leave orphaned test data). This is what keeps tests maintainable past the first handful — see `patterns.md` for the Page Object and fixture patterns.

### 5. Wait on conditions, never on fixed timeouts

`waitForTimeout(3000)` is a red flag by itself — it's simultaneously slower than necessary (always waits the full duration) and flakier than necessary (still races real load times). Use `waitForURL`, `waitForSelector`, `waitForLoadState`, `waitForResponse`, or an auto-waiting `expect(...).toBeVisible()`/`toBeEnabled()` instead. Mock network responses (`page.route`) for external/third-party dependencies (payment providers, etc.) so tests don't depend on a live third party's uptime or state.

### 6. Add visual regression and cross-browser coverage, only where it earns its cost

Visual regression (`toHaveScreenshot`) is worth it for pages/components where a pixel-level regression is a real risk (marketing pages, design-system components) — not blanket-applied to every test, since it adds maintenance overhead (baseline updates) for every deliberate visual change. Cross-browser projects (Firefox, WebKit, mobile emulation) are worth it when the product actually needs that coverage — not by default for an internal tool that only ever runs in Chromium.

### 7. Wire into CI

Run headless in CI (`retries: 2`, `workers: 1` typical for CI stability), capture trace/video/screenshot artifacts on failure, and shard for parallelism once the suite is large enough to benefit. Hand off to `ci-cd-and-automation` for the actual pipeline wiring — this skill owns the test suite, not the CI infrastructure around it.

### 8. Debug failures with the trace, not guesswork

On a failing test: run `--headed` or `--debug` locally to watch it, or open the CI-captured trace (`npx playwright show-trace`) rather than staring at a stack trace and guessing. Add `test.step(...)` around logical phases of a long test so a failure report shows which phase broke, not just which test.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll E2E-test everything to be safe" | E2E tests are slow and comparatively expensive to maintain — reserve them for journeys where a regression is a real incident; push everything else down to unit/integration tests. |
| "A fixed `waitForTimeout` is simpler" | It's simultaneously slower (always waits the full duration) and flakier (still races real load) than waiting on an actual condition — never the simpler choice once a suite has more than a couple of tests. |
| "CSS class selectors are fine, they're already there" | A selector coupled to styling breaks on any unrelated refactor — `getByRole`/`getByLabel`/`data-testid` only break when the user-facing contract changes, which is the failure you actually want to catch. |
| "I'll add visual regression to every test for thoroughness" | Blanket visual regression means updating baselines on every deliberate visual change — apply it where a pixel regression is a real risk, not everywhere. |
| "Cross-browser coverage can't hurt" | Every additional browser project multiplies CI time and flake surface — add it because the product needs that coverage, not as a default. |
| "I'll skip Page Objects for this small suite" | The suite that stays small never needed this skill's process in the first place — if it's growing past a handful of tests, encapsulate now, not after the duplication is already everywhere. |
| "I'll hit the real third-party API in this test" | A test that depends on a live third party's uptime/state is flaky by construction — mock it with `page.route`. |

## Red Flags

- `waitForTimeout` used as the primary wait strategy instead of a condition-based wait
- Selectors built from CSS classes or DOM position (`nth-child`) instead of role/label/testid
- A growing suite with no Page Object or fixture structure — logic and locators duplicated across test files
- A test that hits a live third-party service instead of a mock
- Visual regression or cross-browser projects added everywhere rather than where they're actually needed
- E2E tests written for logic that unit/integration tests already cover better and faster
- CI runs with no failure artifacts (trace/video/screenshot) captured, making a CI-only failure unreproducible locally
- A failing test re-run repeatedly hoping it passes, instead of opening the trace to see why it actually failed

## Verification

- [ ] Tests cover the identified critical journeys, not an exhaustive interaction list
- [ ] Selectors use `getByRole`/`getByLabel`/`data-testid`, not CSS classes or DOM position
- [ ] Page Objects and/or fixtures back any suite beyond a handful of tests
- [ ] No `waitForTimeout` as a primary wait strategy — condition-based waits throughout
- [ ] External/third-party dependencies are mocked, not hit live
- [ ] Visual regression and cross-browser projects are present only where they earn their cost
- [ ] CI runs headless with trace/video/screenshot capture on failure
- [ ] The suite actually passes locally and in CI before being called done

## See Also

- `browser-testing-with-devtools` — a live, interactive verification pass in the current session; use that for "does this work right now", this skill for a lasting regression test
- `playwright-skill` — a disposable, one-off Playwright automation script (screenshot, quick check); use that instead of this skill when nothing needs to persist as a checked-in test
- `test-driven-development` — for logic that doesn't need a real browser
- `ci-cd-and-automation` — wires this suite into the actual CI pipeline
- `ui-a11y` / `wcag-audit-patterns` — accessibility auditing as its own goal, beyond an axe scan folded into this suite
- `patterns.md` — Playwright config, Page Object, fixture, waiting-strategy, network-mocking, visual-regression, sharding, and debugging code patterns referenced above
