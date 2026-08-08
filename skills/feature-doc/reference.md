# Reference: concepts and conventions used by feature-doc

Read this before filling in `implementation-guide.md`, or whenever a distinction below is unclear mid-draft.

## Use case vs. Workflow — these are not the same thing

A **use case** (in `feature-spec.md`) is the black-box interaction between an actor and the system, described in terms of the actor's goal: "Org admin signs in and reaches their dashboard." It says *what* happens from the outside. It has no opinion on services, tables, or call order.

A **workflow** (in `implementation-guide.md`) is the system's internal orchestration to fulfill that use case: "receive credentials → validate against identity provider → check MFA enrollment → challenge for MFA if enrolled → issue access + refresh tokens → write audit log entry → return session to client." It says *how* the system does it, step by step, naming the actual components involved.

The same feature produces exactly one (or a few, for alternate paths) use case, but its workflow can be arbitrarily more detailed — one use case can require a workflow with many steps, branches, and failure recovery paths. Never write internal orchestration detail into a use case, and never write user-facing narrative into a workflow step.

## DDD glossary

Use these terms consistently in every `implementation-guide.md`'s Domain Model section:

- **Bounded Context** — the named area of the domain this feature belongs to (e.g. "Identity & Access", "Config Backup"). One feature usually sits inside one bounded context, though it may touch others at its edges.
- **Aggregate** — a cluster of domain objects treated as a single unit for data changes, with one member as the Aggregate Root (e.g. a `User` aggregate root containing its `Sessions`).
- **Entity** — an object with a distinct identity that persists over time even as its attributes change (e.g. a `User`, a `Device`).
- **Value Object** — an object defined entirely by its attributes, with no identity of its own (e.g. an `EmailAddress`, a `TimeWindow`).
- **Domain Event** — something that happened in the domain that other parts of the system may care about (e.g. `UserSignedIn`, `MfaChallengeFailed`).
- **Domain Service** — domain logic that doesn't naturally belong to any single entity or value object (e.g. a `PasswordPolicy` checker spanning multiple fields).
- **Repository** — the abstraction used to load and persist aggregates (e.g. `UserRepository`).
- **Invariant** — a rule that must always hold true for an aggregate to be considered valid (e.g. "a `Tenant` must have at least one active admin").

If a feature is thin enough that some of these don't apply (no meaningful aggregate, no domain events worth naming), say so directly in that section rather than inventing one to fill space.

## Rule-tagging convention

Every validation rule gets an ID of the form `RULE-<feature-slug>-<n>`, where `<feature-slug>` matches the feature's folder name and `<n>` is a sequential integer starting at 1, shared across all actor variants of the same feature (don't restart numbering per actor — a rule that's actor-specific just gets a note saying which actor(s) it applies to).

A rule is tagged wherever it's enforced or referenced:
- Inline next to the workflow step that enforces it, e.g. `Step 3 — validate MFA code (RULE-auth-4)`.
- In the Alternate & Unhappy Paths table of `feature-spec.md`, whichever rule caused that path to trigger.
- In the Rules Summary table of `implementation-guide.md` — the single place listing every rule for the feature, with its enforcement point and failure behavior.
- As a tag on the Gherkin scenario(s) in `test-cases.md` that verify it, e.g. `@RULE-auth-4`.

A rule with no scenario tagged against it in `test-cases.md`'s traceability table is a gap — treat it as blocking before calling the doc set done.
