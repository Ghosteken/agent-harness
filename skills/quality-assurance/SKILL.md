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

1. Look for a spec (`docs/specs/<feature-slug>/SPEC.md`, or legacy `SPEC.md`), task description, acceptance criteria, issue description, or feature doc
2. If found — list the specific behaviours to confirm (one per scenario)
3. If not found — **stop and ask**: "What is the expected behaviour for [X]? I need a reference before I can verify."

> **Never infer expected behaviour from the current implementation.** That makes verification circular — you'd confirm the code matches itself, not that it matches intent.

### Step 2 — Plan Scenarios

Map expected behaviours to concrete verification scenarios:

| Type | What to check |
|---|---|
| Happy path | Core flow with valid inputs → expected output |
| Edge cases | Empty state, boundary values, optional fields absent |
| Error handling | Invalid input, network failure → correct error shown |
| Fix confirmation | Specific issue from bug report no longer occurs |
| Regression | Previously passing behaviour still works |

### Step 3 — Select Transport

Choose the right execution channel for each scenario. For full auth setup and Playwright MCP guidance, see [transport-and-auth.md](references/transport-and-auth.md).

| Scenario | Transport |
|---|---|
| UI behaviour, visual correctness | Headless Playwright MCP (default) |
| API contract, response shape | curl / HTTP tool |
| Requires user's existing browser session (Google SSO) | Bridge mode |

### Step 4 — Execute Scenarios

Drive each scenario to completion:
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

## Red Flags

- Producing a PASS verdict without observable evidence
- Starting execution before identifying expected behaviour
- Skipping regression scenarios because "only one thing changed"
- Using API-seeded state for a browser test (separate sessions)
- Retrying a failing step more than twice without stopping to report

## Verification

Exit criteria — all must be met before marking QA complete:

- [ ] Expected behaviour source is documented (spec file, issue link, or user confirmation)
- [ ] Every planned scenario has a recorded result (PASS / FAIL + evidence)
- [ ] Regression scenarios were run (at least the scenarios most likely affected by the change)
- [ ] Issues found are categorised by severity with reproduction steps
- [ ] Overall verdict (PASS / FAIL / PARTIAL) is stated explicitly
