# Code Review Checklist: Correctness, Regression & Risk

Work through this against every hunk in the diff, plus the enclosing function for each one (a bug in an unchanged line of a touched function is still in scope — the change re-exposes it or fails to fix it).

**This checklist is not the whole of Phase 1 on its own.** The `code-review` skill also requires, in the same pass, actually reading `references/code-smells-checklist.md` and `references/coding-patterns.md` (the latter specifically for the Altitude judgment call — §3a's module-boundary question is a direct application of its "external systems/domains behind a boundary" pattern) and every CLAUDE.md/AGENTS.md file governing the changed code, in full — not recalled from a previous review, and not satisfied by grepping a convention file for keywords, which misses anything not stated in the exact words searched for. A review that worked through only this file, and reports no finding on module boundaries, Altitude, or conventions, hasn't actually cleared those sections — it's skipped them.

## 1. Correctness

For each line, ask what input, state, timing, or platform makes it wrong: inverted or wrong conditions, off-by-one, a null/undefined dereference, a missing `await`, a falsy-zero check, copy-paste with the wrong variable, an error swallowed in a catch, unescaped regex metacharacters, a wrong default. Does every code path produce the right result, or only the happy path?

## 2. Removed-behavior audit

For every line the diff deletes or replaces, name the invariant or behavior it enforced, then check whether the new code re-establishes it. A dropped guard, a narrowed validation, or a deleted test that covered a real case is a finding.

**If the diff presents itself as a pure refactor (no behavior change intended) over anything with an observable output** (rendered markup, an API response, a computed value), "the tests still pass" is not sufficient evidence on its own — check whether the PR/commit shows an actual before/after diff of that output. If it doesn't, and coverage for the affected path is thin, that absence of evidence is itself a finding (Warning-tier): the claim of "no behavior change" wasn't actually verified, only asserted. See `code-simplification`'s own verification step for what this looks like when producing the refactor.

## 3. Cross-file impact

Grep for callers of every changed function and check whether the change breaks a call site: a new precondition, a changed return shape, a newly-thrown exception, a timing dependency. Check callees too — does a parallel change in the same diff make a call unsafe? Changes to shared code are checked against *all* their consumers, not just the new one.

## 3a. Module/domain boundaries

A module should access another domain's data only through that domain's own exposed interface (its service, reader, repository, or equivalent) — never by reaching directly into the owning domain's internal storage (its table, model, or collection) from outside. A new import that reaches past another domain's public interface into its internals is a finding, independent of language or ORM: it's what later shows up as a circular dependency, and it means the owning domain can no longer change its internal representation without hunting down every outside reader. The fix is always the same shape: the owning domain exposes a narrow accessor for what's actually needed, and the caller imports that instead.

## 3b. Schema/migration changes

If the project uses a migration system, a change to a table/collection's shape or its indexes belongs in a migration, not in the inline model/schema/entity definition — so it's tracked, reviewable, and reversible independent of the next deploy. An index (or a uniqueness constraint) added or removed only in the schema file, with no corresponding migration, is a finding: it works today against today's database but produces nothing against a fresh one, or against a doc/row inserted before the index existed. **Once a migration has been applied (merged, deployed, run against a real environment), it is never edited** — a later change is always a new migration, never a rewrite of an old one; editing an applied migration silently diverges from what already ran in every environment that already has it.

## 4. Concurrency & idempotency

Shared mutable state without locking; async operations that can interleave unsafely; non-atomic writes that need to be atomic. For handlers with external side effects (payments, emails, webhooks, writes) — are they safe against a retried or duplicated call, or does a repeat double-charge/double-send?

**Redundant state, one writer.** When two fields, columns, or stores represent overlapping facts (a status enum and a legacy boolean flag meaning roughly the same thing, a cached count and the rows it's derived from), every write to that state goes through one function/path — not independently at each call site that happens to need to update it. Two or more places independently setting both halves of what's supposed to be the same fact is a finding: they will eventually drift, and the drift is usually silent until something downstream reads the wrong half.

## 5. Security

Hardcoded secrets; unsanitized input reaching a query, shell command, or template (including a value interpolated unescaped into a regular expression — that's both a correctness bug, since regex metacharacters in the input change what it matches, and a potential ReDoS vector); insecure direct object references (resource access by ID with no ownership/permission check); missing or bypassable auth checks; unsafe file operations (path traversal, unrestricted upload types); missing rate limiting on endpoints that accept user-controlled input. A third-party integration (OAuth, an API key, a service account) requesting a broader permission scope than the feature actually needs is a finding — least privilege, not "ask for everything in case it's needed later." For deeper analysis on a specific finding, use `references/security-checklist.md` or the `security-and-hardening` skill.

**PII and sensitive values in logs, exports, and audit trails.** A field classified as sensitive (name, raw contact info, a document ID, anything a data-protection policy would flag) that appears unmasked in an export, a log line, or an audit-trail entry is a finding, independent of whether the surrounding access was otherwise authorized — logging *that* a sensitive field was accessed (the field's name, and a reason if one was given) is fine; logging the value itself usually isn't.

## 6. Performance

N+1 query patterns; synchronous blocking calls on an async path; unbounded loops over data that can grow large; missing pagination on a collection endpoint; expensive computation repeated where it should be cached or hoisted; independent operations run sequentially that could run concurrently. When a computation (an aggregate, a median, a count grouped by some key) is expressed as "load the matching rows into memory, then loop" instead of pushing the aggregation into the database/query layer itself, that's a finding once the underlying collection can grow — the in-memory version gets slower (and the server's memory use larger) in direct proportion to data no one intended to bound. For deeper analysis, use `references/performance-checklist.md` or the `performance-optimization` skill.

## 6a. Object construction safety

Where the project uses a persistence layer with a typed schema (an ORM/ODM model, an entity class, a typed record), a write path that builds the record from a raw literal object/dict passed straight into the create/insert call — rather than constructing (or validating) it through the typed path first — is a finding: it silently accepts extra fields the schema doesn't know about and silently omits required ones no compiler or validator ever checked. The fix shape is always the same regardless of language or ORM: construct/validate the typed object first, assign or merge the intended fields onto it, then persist that — never persist the raw literal directly.

## 6b. Entry-point responsibility

The layer that receives the request (a controller, route handler, resolver, CLI command handler) should delegate to the owning service/use-case and shape the response — not hold business logic, orchestrate multiple services, or branch on domain rules itself. A handler that's grown its own `if`-chain of domain logic, or that reaches into two or three services and stitches their results together, is a finding: that orchestration belongs in a service that owns the use-case, where it can be tested without spinning up the transport layer.

## 7. Test quality (when the diff touches tests)

Do tests assert on outcomes (return values, thrown errors) rather than implementation details (which methods were called, in what order)? Do they cover real edge cases rather than just the happy path? Would they actually catch a regression if the implementation changed?

**Mock only what's actually external** — a third-party API, real network I/O, a payment gateway — not the system under test's own internal collaborators; over-mocking internal code means the test proves the mocks cooperate, not that the code does. Where a mock has to stand in for a write/save call, prefer one that records what was actually passed (so the test can assert on it) over one that just echoes back whatever argument it received — an echo-mock can make a test pass even when the code under test builds the wrong object, since the mock never actually checked what it was given.

**Test file placement, for any file-based-routing or file-based-serving framework** (a `pages/`/`app/` directory that maps files to routes, a static-site generator that serves anything under its content root, etc.): a test file placed inside that directory doesn't just risk being skipped by the test runner — it can become a live, publicly reachable route or page. This is a Blocker-tier finding, not a style nit, whenever the framework in use works this way.

## What's worth raising

Not everything technically true belongs in the report. A finding earns a place only if it's a real risk (something breaks, is insecure, or regresses) or a genuine, non-obvious improvement — not a minor stylistic nit on an otherwise-fine line, or a hypothetical that needs contrived conditions to ever matter. When in doubt, ask: would a senior engineer actually stop and say something here, or just keep scrolling?
