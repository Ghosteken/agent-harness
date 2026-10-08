---
name: code-review
description: Reviews code changes for correctness, security, and quality against a concrete checklist, verifying each Blocker/Warning candidate before it's reported so the review stays focused on what actually matters rather than padded with minor nits. Produces a Blocker/Warning/Suggestion report with a PASS/FAIL verdict. Use before merging any change, after completing a feature or bug fix, or when evaluating code written by another agent or a human.
---

# Code Review

## Overview

Code review has two failure modes: rubber-stamping (a single pass that reads the diff once and finds nothing) and noise (every technically-true observation reported as if it matters, burying the real issues under minor nits). This skill avoids both: work the diff against a concrete checklist, then verify every Blocker/Warning candidate before it reaches the report — a finding only earns its place if it's a real risk or a genuinely useful callout, not just something that happened to be true.

**The approval standard:** pass a change when it definitely improves overall code health, even if it isn't perfect. Don't fail a change because it isn't exactly how you would have written it. If it follows the project's conventions and moves the codebase forward, it passes.

## When to Use

- Before merging any PR or change
- After completing a feature implementation or a bug fix (review both the fix and its regression test)
- When another agent or model produced code you need to evaluate
- When refactoring existing code
- NOT for exploratory/prototype code the user has explicitly marked as throwaway

## Process

### Phase 0 — Gather scope

Determine what's under review, in order of preference:
1. A PR number, branch, or file path the user named — review that target.
2. `git diff @{upstream}...HEAD` (or `git diff main...HEAD` / `git diff HEAD~1` with no upstream) — the committed range.
3. If there are uncommitted changes, or the range diff is empty, also run `git diff HEAD` and fold the working-tree changes into scope — review often runs before the commit exists.

Treat the resulting diff (or file set, for a from-scratch read) as the full review scope.

### Phase 1 — Review against the checklist

Read every hunk once, working it against two checklists:

- **Correctness, regression & risk** — `references/code-review-checklist.md` (correctness, removed-behavior/regression, cross-file impact, concurrency/idempotency, security, performance, test quality)
- **Code quality** — `references/code-smells-checklist.md` (Fowler-style smells, dead code, type safety, discriminated unions)

Plus two quick judgment calls that aren't fixed checklists:
- **Altitude** — a special case layered onto shared infrastructure instead of a deeper fix. Prefer generalizing the underlying mechanism over adding another `if` for one more case.
- **Conventions (CLAUDE.md)** — read the CLAUDE.md files that govern the changed code (user-level, repo-root, any ancestor directory's CLAUDE.md/CLAUDE.local.md). Flag only a clear violation you can quote: the exact rule, and the exact line that breaks it. No style preferences, no "spirit of the doc" inferences.

**Raise a candidate only if it clears the bar in `references/code-review-checklist.md`'s "What's worth raising" section** — a real risk, or a genuinely useful callout, not a minor nit that happens to be technically true. This is the main thing that keeps the report short and worth reading instead of padded with trivia. For each candidate that clears the bar, note `file`, `line`, a one-line `summary`, and — for anything in the Correctness/Regression/Risk checklist — a concrete `failure_scenario` (what input/state/timing triggers it, and what breaks).

### Phase 2 — Verify Blockers and Warnings

Dedup candidates pointing at the same line or mechanism, keeping the one with the most concrete detail. For every candidate that would be reported as a **Blocker** or **Warning**, run one independent verification pass — via the Agent tool when available, with access to the diff and relevant files but not the Phase 1 reasoning — returning exactly one of:

- **CONFIRMED** — names the inputs/state that trigger it and the resulting wrong output or crash. Quotes the line.
- **PLAUSIBLE** — the mechanism is real but the trigger is uncertain (timing, environment, config). States what would confirm it.
- **REFUTED** — factually wrong (the code doesn't say that) or already guarded elsewhere. Quotes the line that proves it.

Keep CONFIRMED and PLAUSIBLE; drop REFUTED. **Suggestions skip this step** — they're optional by nature, so a wrong one costs the reader a glance, not a blocked merge; verifying them would just add process overhead for low-stakes findings.

### Phase 3 — Report

Always produce the report in this exact structure:

```
## Code Review Report

### Blockers
- <file>:<line> — <description>

### Warnings
- <file>:<line> — <description>

### Suggestions
- <file>:<line> — <description>

### Verdict
PASS / FAIL  (FAIL if any Blocker remains)
```

If a section has no findings, write `None` under it — don't omit sections. Each finding states the file:line, the problem, the concrete failure scenario (for Blockers/Warnings), and — where there's an obvious one — the fix.

- **Blocker** — must be fixed before the review passes: security vulnerability, data loss, broken functionality, a correctness bug with a confirmed or plausible trigger.
- **Warning** — should be fixed but won't block: a real but lower-stakes correctness/security/performance concern, an architecture issue worth raising.
- **Suggestion** — optional improvement: cleanup, simplification, altitude, convention findings that cleared the "worth raising" bar but aren't risks.

If the review tooling exposes a structured findings reporter, call it once with the ranked list instead of writing the findings as prose.

### Phase 4 — Record findings for future implementation

If any Blocker or Warning survived Phase 2 (Suggestions are too routine to log), append each one as a dated entry to `review-findings.md` in the project's external output location (see `references/external-output-paths.md`) — a single running log for the project, always appended to, never overwritten or replaced per review:

```markdown
## <YYYY-MM-DD> — <what was reviewed: file/PR/branch/feature>
- **Category:** Correctness | Security | Performance | Concurrency | Quality
- **Finding:** <the specific bad pattern or problem observed, one line>
- **Avoid by:** <concrete guidance for next time — what to do instead, not just what was wrong>
```

Create the file (with a one-line header explaining its purpose) if this is the first entry for the project. Skip this step entirely on a clean review with nothing above Suggestion severity. Tell the user the entry was recorded and where, the same as any other external-output artifact.

This log exists so `incremental-implementation`, `test-driven-development`, `subagent-driven-development`, and code-writing agent personas can check it before starting new work and avoid repeating a mistake this project has already made once.

## Dead Code Hygiene

After any refactor or implementation change, check for now-orphaned code: an old helper replaced by a new one, a component nothing renders anymore, a constant with no remaining references. List it explicitly and ask before deleting — don't leave it lying around, but don't silently remove something you're not sure is unused either.

## Honesty in Review

- Don't rubber-stamp — "LGTM" without evidence of review helps no one.
- Don't soften a real issue — "this might be a minor concern" when it's a bug that will hit production is dishonest.
- Quantify problems when you can — "this N+1 adds ~50ms per item in the list" beats "this could be slow."
- Push back on approaches with clear problems; sycophancy is a review failure mode. Comment on the code, not the author.
- If the author has full context and disagrees after hearing the pushback, defer to their judgment — the goal is a better change, not a won argument.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It works, that's good enough" | Working code that's unreadable, insecure, or architecturally wrong creates debt that compounds. |
| "I wrote it, so I know it's correct" | Authors are blind to their own assumptions. A second pass — especially an independently verified one — catches what a single read misses. |
| "We'll clean it up later" | Later rarely comes. Require cleanup before merge unless it's a genuine emergency. |
| "AI-generated code is probably fine" | AI code is confident and plausible even when wrong — Blockers and Warnings still need the verify step, not a skip. |
| "The tests pass, so it's good" | Tests are necessary but not sufficient — they don't catch architecture, security, or readability problems by themselves. |
| "This is technically true, I'll report it" | Technically true isn't the bar — `references/code-review-checklist.md`'s "What's worth raising" is. A report padded with nits a senior engineer wouldn't mention is noise, not thoroughness. |
| "This finding felt right, I'll report it without checking" | Skipping Phase 2 for a Blocker/Warning is exactly how a review degrades into noise; an unverified candidate at that severity stays a candidate. |
| "The author already knows about this finding, no need to log it" | The log isn't for this author in this session — it's for whoever writes the next similar code, possibly a different agent with no memory of this conversation. |

## Red Flags

- A review that only checks whether tests pass, ignoring correctness/security/quality
- A Blocker or Warning reported without an independent verify pass (no CONFIRMED/PLAUSIBLE/REFUTED)
- A report padded with Suggestions that don't clear the "worth raising" bar — technically true but not something a senior engineer would actually say
- "LGTM" without evidence of actual review
- Security-sensitive changes reviewed without working through the Security section of the checklist
- A large diff that's "too big to review properly" — ask the author to split it instead of skimming
- No regression test accompanying a bug-fix PR
- The report missing the PASS/FAIL verdict, or a FAIL verdict with no Blocker listed

## Verification

- [ ] Scope was gathered correctly (diff, working tree, or named target — not guessed)
- [ ] The diff was worked against both checklists (`code-review-checklist.md` and `code-smells-checklist.md`), plus the Altitude and Conventions judgment calls
- [ ] Every reported candidate clears the "worth raising" bar — no padding with technically-true-but-irrelevant nits
- [ ] Every Blocker/Warning passed an independent verify step (CONFIRMED or PLAUSIBLE); Suggestions were not required to
- [ ] The report follows the exact Blockers/Warnings/Suggestions structure, with `None` where a section is empty
- [ ] The report ends with an explicit PASS/FAIL verdict (FAIL only if a Blocker remains)
- [ ] Any Blocker/Warning was appended to `review-findings.md` at the external output location (or the review had none, and this step was correctly skipped)

## See Also

- `references/code-review-checklist.md` — the Correctness, regression & risk checklist this skill's Phase 1 works through
- `references/code-smells-checklist.md` — the Code quality checklist (Fowler-style smells, dead code, type safety)
- `references/security-checklist.md` — deeper security review guidance, for a specific finding worth a closer look
- `references/performance-checklist.md` — deeper performance review guidance, for a specific finding worth a closer look
- `references/coding-patterns.md` — structural patterns worth checking for on the Altitude judgment call (boundaries, decision/action separation, unrepresentable invalid states, useful errors)
