---
name: code-review-and-quality
description: Runs code review as a bounded finder-and-verify pipeline — parallel finder angles surface candidate issues across correctness, security, performance, architecture, and cleanup, then each candidate is independently verified before it's reported. Use before merging any change, after completing a feature or bug fix, or when evaluating code written by another agent or a human.
---

# Code Review and Quality

## Overview

Code review has two failure modes: rubber-stamping (a single pass that reads the diff once and finds nothing) and noise (every stylistic preference reported as if it blocks the merge). This skill avoids both by separating **finding** from **verifying**: multiple finder passes independently hunt for candidate issues across five axes, then every surviving candidate is checked before it's reported. A finding only reaches the author if it can be verified — a nameable input, state, or scenario that makes it real.

**The approval standard:** approve a change when it definitely improves overall code health, even if it isn't perfect. Don't block a change because it isn't exactly how you would have written it. If it follows the project's conventions and moves the codebase forward, approve it.

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

Treat the resulting diff (or file set, for a from-scratch read) as the full review scope. For each hunk, also read the enclosing function — a bug in an unchanged line of a touched function is in scope, since the change re-exposes it or fails to fix it.

### Phase 1 — Finder angles

Run each angle below as an independent pass — via the Agent tool when available, so angles run in parallel and don't share context; sequentially, in this context, when the Agent tool isn't available. Each angle surfaces **up to 6 candidates**, each with `file`, `line`, a one-line `summary`, and a concrete `failure_scenario` (what input/state/timing triggers it, and what breaks). Pass through every candidate with a nameable scenario, even a half-confident one — filtering happens in Phase 2, not here; a finder that quietly drops candidates bypasses verification entirely.

Scale the angle set to review effort:

| Effort | Angles run |
|---|---|
| Low (quick check) | Line-by-line scan + Security |
| Medium (default) | Line-by-line scan, Removed-behavior audit, Security, Performance, Reuse/Simplification |
| High (pre-merge, high-stakes) | All angles below |

**Correctness — line-by-line scan.** Read every hunk. For each line, ask what input, state, timing, or platform makes it wrong: inverted or wrong conditions, off-by-one, null/undefined deref, a missing `await`, a falsy-zero check, copy-paste with the wrong variable, an error swallowed in a catch, unescaped regex metacharacters, a wrong default.

**Correctness — removed-behavior audit.** For every line the diff deletes or replaces, name the invariant or behavior it enforced, then check whether the new code re-establishes it. A dropped guard, a narrowed validation, or a deleted test that covered a real case is a candidate.

**Correctness — cross-file tracer.** Grep for callers of every changed function and check whether the change breaks a call site: a new precondition, a changed return shape, a newly-thrown exception, a timing dependency. Check callees too — does a parallel change in the same diff make a call unsafe?

**Correctness — concurrency & idempotency.** Look for shared mutable state without locking, async operations that can interleave unsafely, non-atomic writes that need to be atomic. For handlers with external side effects (payments, emails, webhooks, writes) — are they safe against a retried or duplicated call, or does a repeat double-charge/double-send?

**Security.** Hardcoded secrets; unsanitized input reaching a query, shell command, or template; insecure direct object references (resource access by ID with no ownership/permission check); missing or bypassable auth checks; unsafe file operations (path traversal, unrestricted upload types); missing rate limiting on endpoints that accept user-controlled input. For deeper analysis on a specific finding, use the `security-and-hardening` skill.

**Performance.** N+1 query patterns; synchronous blocking calls on an async path; unbounded loops over data that can grow large; missing pagination on a collection endpoint; expensive computation repeated where it should be cached or hoisted; independent operations run sequentially that could run concurrently. For deeper analysis, use the `performance-optimization` skill.

**Reuse.** New code that re-implements something the codebase already has. Grep shared/utility modules and files adjacent to the change; name the existing helper to call instead.

**Simplification.** Unnecessary complexity the diff adds — redundant or derivable state, copy-paste with slight variation, deep nesting, dead code left behind, a named smell from `references/code-smells-checklist.md`. Name the simpler form that does the same job.

**Altitude.** Special cases layered onto shared infrastructure instead of a deeper fix. Prefer generalizing the underlying mechanism over adding another `if` for one more case.

**Conventions (CLAUDE.md).** Read the CLAUDE.md files that govern the changed code — user-level, repo-root, and any CLAUDE.md/CLAUDE.local.md in a directory that's an ancestor of a changed file. Flag only a clear violation you can quote: the exact rule, and the exact line that breaks it. No style preferences and no "spirit of the doc" inferences. If none apply, this angle returns nothing.

Correctness and security candidates outrank performance, cleanup, and conventions candidates whenever the output cap forces a cut.

### Phase 2 — Verify

Dedup candidates that point at the same line or mechanism, keeping the one with the most concrete `failure_scenario`. For each remaining candidate, run one independent verification pass — via the Agent tool when available — that has access to the diff and the relevant file(s) but not the finder's reasoning, and returns exactly one of:

- **CONFIRMED** — names the inputs/state that trigger it and the resulting wrong output or crash. Quotes the line.
- **PLAUSIBLE** — the mechanism is real but the trigger is uncertain (timing, environment, config). States what would confirm it.
- **REFUTED** — factually wrong (the code doesn't say that) or already guarded elsewhere. Quotes the line that proves it.

Keep CONFIRMED and PLAUSIBLE candidates; drop REFUTED ones. This is the step that keeps a "senior engineer would act on this" bar instead of reporting everything a first pass noticed.

### Phase 3 — Report

Rank surviving findings most-severe first, cap at 8, and label each with a severity:

- **Critical** — blocks merge: security vulnerability, data loss, broken functionality, a correctness bug with a confirmed trigger.
- **Important** — should be fixed but doesn't necessarily block: a PLAUSIBLE correctness/security finding, a performance issue with real but not certain impact, an architecture concern.
- **Suggestion** — optional: cleanup, simplification, altitude, and convention findings.

Each finding states the file:line, the problem, the concrete failure scenario, and — where there's an obvious one — the fix. End with a verdict: **Approve** or **Request changes** (request changes if any Critical finding remains unaddressed).

If the review tooling exposes a structured findings reporter, call it once with the ranked list instead of writing the findings as prose — a structured report is what lets the cap and severities actually be enforced downstream, rather than re-litigated in freeform text.

### Phase 4 — Record findings for future implementation

If any Critical or Important finding survived Phase 2 (Suggestions are too routine to log), append each one as a dated entry to `review-findings.md` in the project's external output location (see `references/external-output-paths.md`) — a single running log for the project, always appended to, never overwritten or replaced per review:

```markdown
## <YYYY-MM-DD> — <what was reviewed: file/PR/branch/feature>
- **Axis:** Correctness | Security | Architecture | Performance | Readability
- **Finding:** <the specific bad pattern or problem observed, one line>
- **Avoid by:** <concrete guidance for next time — what to do instead, not just what was wrong>
```

Create the file (with a one-line header explaining its purpose) if this is the first entry for the project. Skip this step entirely on a clean review with nothing above Suggestion severity — an empty review doesn't need a log entry. Tell the user the entry was recorded and where, the same as any other external-output artifact.

This log exists so `incremental-implementation`, `test-driven-development`, `executing-plans`, `subagent-driven-development`, and code-writing agent personas can check it before starting new work and avoid repeating a mistake this project has already made once.

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
| "AI-generated code is probably fine" | AI code is confident and plausible even when wrong — it needs the verify step applied, not skipped. |
| "The tests pass, so it's good" | Tests are necessary but not sufficient — they don't catch architecture, security, or readability problems by themselves. |
| "This finding felt right, I'll report it without checking" | Skipping Phase 2 is exactly how a review pipeline degrades into noise; an unverified candidate stays a candidate. |
| "The author already knows about this finding, no need to log it" | The log isn't for this author in this session — it's for whoever writes the next similar code, possibly a different agent with no memory of this conversation. |

## Red Flags

- A review that only checks whether tests pass, ignoring the other axes
- Findings reported without ever being verified (no CONFIRMED/PLAUSIBLE/REFUTED pass)
- More than 8 findings dumped on the author at once instead of ranked and capped
- "LGTM" without evidence of actual review
- Security-sensitive changes reviewed without the Security angle run
- A large diff that's "too big to review properly" — ask the author to split it instead of skimming
- No regression test accompanying a bug-fix PR

## Verification

- [ ] Scope was gathered correctly (diff, working tree, or named target — not guessed)
- [ ] Every finder angle appropriate to the effort level ran
- [ ] Every reported finding passed an independent verify step (CONFIRMED or PLAUSIBLE)
- [ ] Findings are ranked, severity-labeled, and capped at 8
- [ ] The report ends with an explicit Approve / Request changes verdict
- [ ] Any Critical/Important finding was appended to `review-findings.md` at the external output location (or the review had none, and this step was correctly skipped)

## See Also

- `references/code-smells-checklist.md` — named smells for the Reuse/Simplification/Altitude angles
- `references/security-checklist.md` — deeper security review guidance
- `references/performance-checklist.md` — deeper performance review guidance
- `references/coding-patterns.md` — structural patterns to check for on the Architecture axis (boundaries, decision/action separation, unrepresentable invalid states, useful errors)
