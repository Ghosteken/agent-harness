---
name: quality-assurance
description: Guides agents through feature verification and fix validation — executing test scenarios against a spec, driving a browser or API, and producing a clear PASS/FAIL/PARTIAL verdict. Use when: verifying a feature works, confirming a fix resolved an issue, checking for regressions after changes, running a smoke test, executing a functional test plan, or any task where the goal is to confirm behaviour matches expected rather than to write new tests.
---

# Quality Assurance

## Overview

This skill executes verification scenarios against a known expected behaviour (spec, acceptance criteria, or task description) and produces an evidence-backed verdict. It covers browser UI flows, API verification, and regression checks — always starting from a spec anchor, never from the current implementation.

## When to Use

**Use this skill when:**
- Verifying that a new feature works end to end
- Confirming a bug fix resolved the reported issue
- Running a regression check after any code change
- Executing a functional test plan for a feature
- Performing a smoke test before or after deployment

**Do not use this skill when:**
- Writing new tests or designing test coverage → use `test-driven-development`
- Isolating a bug's root cause → use `debugging-and-error-recovery`
- Doing a visual/design audit → use `browser-testing-with-devtools`

## Core Process

### Step 1 — Establish Expected Behaviour (mandatory)

Before executing anything:

1. Look for a spec, under the project's external output location (see `references/external-output-paths.md`) — `specs/<feature-slug>/SPEC.md`'s Success Criteria section — or a legacy in-repo `SPEC.md`, task description, acceptance criteria, or issue description
2. If found — list the specific behaviours to confirm (one per scenario)
3. If not found — **stop and ask**: "What is the expected behaviour for [X]? I need a reference before I can verify."

> **Never infer expected behaviour from the current implementation.** That makes verification circular — you'd confirm the code matches itself, not that it matches intent.

### Step 2 — Plan Scenarios

If a Gherkin `test-cases.md` already exists for the feature, its scenarios are already concrete verification scenarios — execute those directly rather than re-deriving them from the feature spec. Otherwise, map expected behaviours to concrete verification scenarios:

| Type | What to check |
|---|---|
| Happy path | Core flow with valid inputs → expected output |
| Edge cases | Empty state, boundary values, optional fields absent |
| Error handling | Invalid input, network failure → correct error shown |
| Fix confirmation | Specific issue from bug report no longer occurs |
| Regression | Previously passing behaviour still works |

**Don't stop once one scenario type is covered.** Checking that all 6 endpoints reject unauthenticated requests is a real result, but it's one type (error handling) — it says nothing about whether the happy path actually works, whether validation rejects bad input, or whether the specific fix/edge case this feature exists for behaves correctly. Every scenario type that genuinely applies to this feature needs at least one concrete check before the verdict is reported — not just whichever type was easiest or fastest to exercise.

### Step 3 — Select Transport

Choose the right execution channel for each scenario. For full auth setup and Playwright MCP guidance, see [transport-and-auth.md](references/transport-and-auth.md).

| Scenario | Transport |
|---|---|
| UI behaviour, visual correctness | Headless Playwright MCP (default) |
| API contract, response shape | curl / HTTP tool |
| Requires user's existing browser session (Google SSO) | Bridge mode |

**Every transport here means a real, running instance — not a mocked stand-in.** This skill's whole value is proving the feature works against real dependencies (a real server process, a real database, a real authenticated user), not a client double standing in for one. A project's own test suite naming isn't proof of this: a suite called "e2e" can still run fully mocked, or can hit a real server but have an earlier guard/middleware reject the request before the code under test ever runs — verify the request actually reached and exercised the target logic, don't take the suite's name at face value.

If genuine live verification needs something not currently available — a real signed-in user's access token, a live database connection, an API key, test account credentials — don't silently substitute a mocked check, and don't rigidly block on the heaviest option either. Assembling full live access can genuinely be tedious; when it is, use `AskUserQuestion` to offer the real tradeoff instead of deciding unilaterally:

- **Full live verification** — real credentials/access, the most complete option, when it's not much friction to set up
- **A minimal live check via curl/CLI** — against the real running dev server (real process, real database) but a narrower surface, e.g. without a fully authenticated session if that's the specific friction point
- **An automated test that boots/hits the real dev server and database** — still genuinely live (real dependencies, not mocked), just run through the test framework rather than a manual browser/API session

All three are live in the sense this skill requires — none of them is a mocked substitute. Let the user pick the tradeoff; don't downgrade to mocks on your own, and don't insist on the full option when a lighter live check would do. If even the lightest live option isn't currently possible, say so explicitly in the report (Step 5) — "not verified live: requires X" is honest; a PASS verdict resting on mocks presented as equivalent is not.

### Step 4 — Execute Scenarios

Drive each scenario to completion, against the real instance selected above:
- Use role+name locators for browser interactions, not positional refs
- Seed test state through the same channel as the test (browser state ≠ API session)
- Apply the two-strikes rule: if a step fails twice with the same error, stop and report — do not iterate

### Step 5 — Produce Verification Report

```markdown
## Verification Report

**Feature / Fix:** [Name or issue reference]
**Spec reference:** [Source of expected behaviour]

### Summary
**Overall verdict:** PASS | FAIL | PARTIAL

### Scenario Results

| Scenario | Expected | Observed | Verdict |
|---|---|---|---|
| [Name] | [Spec says] | [What happened] | PASS / FAIL |

### Issues Found
- **[Critical / High / Medium]** — [Description + evidence]

### Regressions
- [Any previously passing behaviour that now fails]

### Evidence
- [Screenshots, response bodies, console output]
```

## Common Rationalizations

| Excuse | Reality |
|---|---|
| "I'll just check it looks right" | Looking right is not a verdict. Run the scenario against the spec. |
| "The fix is obvious, I don't need a spec" | Every obvious fix has a different interpretation. Get the spec first. |
| "I'll try a few things until it works" | Two strikes and stop. Iteration without a baseline is guessing, not verification. |
| "The tests pass so it works" | Passing tests confirm what tests check — not that the feature works. Execute the scenarios. |
| "I can infer the expected behaviour from the code" | That makes verification circular. Spec or ask. |
| "I checked that all the endpoints reject bad requests, that's a solid check" | It's a real check of one scenario type — it says nothing about whether the happy path, validation, or the specific fix under test actually work. Cover every scenario type that applies, not just the one that was fastest to verify. |
| "The existing test suite is called 'e2e', running it counts as live verification" | A suite's name isn't proof — it can still run against a mocked client, or hit a real server while an earlier guard rejects the request before the code under test ever runs. Confirm the target logic was actually reached and exercised. |
| "I don't have a real token/test account, I'll just run the mocked unit tests instead and report what I have" | Silently substituting a mocked check misrepresents what was verified. Offer the lighter-but-still-live options (curl/CLI against the real server, or an automated test hitting real dependencies) via `AskUserQuestion` before falling back to mocks or state plainly that live verification didn't happen. |
| "Full live verification is too tedious to set up, I'll just skip straight to mocks" | Tedious doesn't mean impossible — a curl/CLI check or an automated test against the real dev server is still genuinely live and usually much less setup than a full authenticated session. Ask which live option to use; don't jump straight to a mocked substitute. |

## Red Flags

- Producing a PASS verdict without observable evidence
- Starting execution before identifying expected behaviour
- Skipping regression scenarios because "only one thing changed"
- Reporting a verdict having exercised only one scenario type (e.g., only that requests get rejected) when happy-path, validation, or fix-specific scenarios genuinely applied too
- A verdict resting on mocked/unit-level tests, or a suite merely labeled "e2e"/"integration", presented as if it were live verification
- Missing credentials or test access led to silently running a mocked check instead of offering the lighter live options first
- Full live verification assumed to be the only acceptable option, with no `AskUserQuestion` offering the curl/CLI or real-dev-server-test alternatives when the full setup was genuinely tedious
- Using API-seeded state for a browser test (separate sessions)
- Retrying a failing step more than twice without stopping to report

## Verification

Exit criteria — all must be met before marking QA complete:

- [ ] Expected behaviour source is documented (spec file, issue link, or user confirmation)
- [ ] Every planned scenario has a recorded result (PASS / FAIL + evidence)
- [ ] Every scenario type that genuinely applies (happy path, edge cases, error handling, fix confirmation, regression) was actually exercised — not just one type
- [ ] Verification actually ran against a real, live instance (real server, real database, real authenticated user) — not a mocked client, and not just a suite that happens to be named "e2e"/"integration"
- [ ] If full live verification was genuinely tedious to set up, graduated live alternatives (curl/CLI against the real dev server, or an automated test hitting real dependencies) were offered via `AskUserQuestion` rather than downgrading straight to mocks
- [ ] If no live option was possible at all, that was stated explicitly in the report — never silently substituted with a mocked check reported as if equivalent
- [ ] Regression scenarios were run (at least the scenarios most likely affected by the change)
- [ ] Issues found are categorised by severity with reproduction steps
- [ ] Overall verdict (PASS / FAIL / PARTIAL) is stated explicitly
