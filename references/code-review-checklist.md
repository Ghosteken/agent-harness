# Code Review Checklist: Correctness, Regression & Risk

Work through this against every hunk in the diff, plus the enclosing function for each one (a bug in an unchanged line of a touched function is still in scope — the change re-exposes it or fails to fix it).

## 1. Correctness

For each line, ask what input, state, timing, or platform makes it wrong: inverted or wrong conditions, off-by-one, a null/undefined dereference, a missing `await`, a falsy-zero check, copy-paste with the wrong variable, an error swallowed in a catch, unescaped regex metacharacters, a wrong default. Does every code path produce the right result, or only the happy path?

## 2. Removed-behavior audit

For every line the diff deletes or replaces, name the invariant or behavior it enforced, then check whether the new code re-establishes it. A dropped guard, a narrowed validation, or a deleted test that covered a real case is a finding.

## 3. Cross-file impact

Grep for callers of every changed function and check whether the change breaks a call site: a new precondition, a changed return shape, a newly-thrown exception, a timing dependency. Check callees too — does a parallel change in the same diff make a call unsafe? Changes to shared code are checked against *all* their consumers, not just the new one.

## 4. Concurrency & idempotency

Shared mutable state without locking; async operations that can interleave unsafely; non-atomic writes that need to be atomic. For handlers with external side effects (payments, emails, webhooks, writes) — are they safe against a retried or duplicated call, or does a repeat double-charge/double-send?

## 5. Security

Hardcoded secrets; unsanitized input reaching a query, shell command, or template; insecure direct object references (resource access by ID with no ownership/permission check); missing or bypassable auth checks; unsafe file operations (path traversal, unrestricted upload types); missing rate limiting on endpoints that accept user-controlled input. For deeper analysis on a specific finding, use `references/security-checklist.md` or the `security-and-hardening` skill.

## 6. Performance

N+1 query patterns; synchronous blocking calls on an async path; unbounded loops over data that can grow large; missing pagination on a collection endpoint; expensive computation repeated where it should be cached or hoisted; independent operations run sequentially that could run concurrently. For deeper analysis, use `references/performance-checklist.md` or the `performance-optimization` skill.

## 7. Test quality (when the diff touches tests)

Do tests assert on outcomes (return values, thrown errors) rather than implementation details (which methods were called, in what order)? Do they cover real edge cases rather than just the happy path? Would they actually catch a regression if the implementation changed?

## What's worth raising

Not everything technically true belongs in the report. A finding earns a place only if it's a real risk (something breaks, is insecure, or regresses) or a genuine, non-obvious improvement — not a minor stylistic nit on an otherwise-fine line, or a hypothetical that needs contrived conditions to ever matter. When in doubt, ask: would a senior engineer actually stop and say something here, or just keep scrolling?
