---
name: feature-doc
description: Interview the user and produce a structured pre-implementation doc set (feature spec, implementation guide, test cases) for one feature/actor, grounded in the project's own technical and product docs. Use before implementing any new feature, or any new actor-facing variant of an existing feature.
---

# feature-doc

Produces the documentation that must exist *before* a feature is implemented: what it's for, who it's for, how it behaves on every path, how the system carries it out internally, and how it will be tested. Nothing here is a substitute for writing code — this skill's output is a planning artifact that guides implementation, not implementation itself.

## Governing principle

**Never hardcode or assume anything feature-specific.** No default actor set, no default trigger types, no default data sources, no default business rules or specs — not even common-seeming ones like "admin/user". The project's own technical and product docs are the primary source of truth. Wherever those docs don't answer a question the draft needs, the job is to ask the user, not guess. This applies uniformly to every section of every template: actors, triggers, preconditions, data sources/APIs, specs, and validation rules alike. If you catch yourself about to write something into a draft that wasn't in the docs and wasn't confirmed by the user, stop and ask first.

## Output layout

Written to the project's external output location (see `references/external-output-paths.md`) — outside the project's own repo, never a path git in this project tracks or ignores:

```
features/<feature-slug>/<actor-slug>/
  feature-spec.md
  implementation-guide.md
  test-cases.md
features/README.md        # index of every feature/actor doc set, created if missing
```

If the feature behaves identically for every actor it applies to, use a single actor folder named `shared` instead of duplicating identical content across actor folders.

## Process

### 1. Identify the feature

Ask for the feature name or a short description of it. Nothing else yet — don't ask about actors, triggers, or scope before checking what the project's own docs already say.

### 2. Locate source docs

Look for a `docs/` folder in the current project — this is a read of the project's own existing documentation, unrelated to where this skill's output gets written (see Output layout above).

Search `docs/` (and its immediate subfolders) for files that look like a technical spec or product doc — by name (`*technical*spec*`, `*product*doc*`, `*architecture*`, `*prd*`, etc.) and by skimming headings if names are ambiguous. If more than one candidate is found, ask the user which is the technical doc (primary source of truth for architecture, data model, actors/roles, APIs) and which is the product doc (secondary source for personas, journeys, feature framing) — do not guess which is which.

If nothing is found, say so plainly and ask the user to point directly to the technical doc. State that the quality of the Domain Model and Specs sections depends on having one. Only fall back to codebase exploration plus user interview alone if the user confirms no such doc exists.

### 3. Read for context

Read the sections of the technical doc relevant to this feature: architecture, data model, existing actor/role model, related modules, existing API endpoints or vendor integrations. Read the product doc's relevant personas, journeys, and feature framing. Then check the codebase itself (grep for related routes, modules, pages, migrations) for whatever already exists, partially or fully — the draft must reflect current reality, including "this is currently a stub," not a hypothetical clean-room design.

Note everything the docs and code already establish. Do not ask the user about anything already answered here.

### 4. Interview

Ask as many clarifying questions as it takes to remove every material unknown before drafting — this step is not optional, and it exists precisely because step 3 will not cover everything. At minimum, resolve:

- **This project's own actor hierarchy** as it applies to this feature. Never suggest a default shape — a project's actors might be one flat role, a tiered/multi-tenant hierarchy, or include non-human system actors (a scheduler, a webhook consumer, an external system). Ask the user to state theirs. Then ask which of those actors this feature applies to, and whether its behavior differs by actor.
- **Triggers**: user-initiated action, scheduled/cron, webhook or event from another part of the system, or some combination.
- **Preconditions and boundaries**: what must already be true for this feature to be reachable, and what is explicitly out of scope.
- **Data sources / external APIs**: what's read or written, internally or externally.
- **Edge cases and failure modes** the user already has in mind.
- **Non-functional constraints**: security, performance, compliance — only if applicable to this feature.
- **Any conflict between the docs and what the user now describes** (e.g. the docs model something one way, but the user's answer implies a different shape). Surface the conflict and ask which should win, rather than silently picking one.

Use AskUserQuestion for discrete choices with a small option set; use plain follow-up questions for open-ended items. It's fine for this to take multiple turns — keep going until there's nothing material left to guess at.

### 5. Draft

Copy the three templates from `templates/` into `features/<feature-slug>/<actor-slug>/` under the project's external output location and fill every section. No placeholder text, no `TODO`, no bracketed `[...]` left anywhere in the output — if something is still genuinely unresolved after the interview, say so explicitly in the "Open Questions / Assumptions" section of `implementation-guide.md` rather than leaving a blank.

Three rules that make the three files cohere as one set:
- Every step under **Workflow & Lifecycle** in `implementation-guide.md` carries at least one tagged rule, `RULE-<feature-slug>-<n>` (see `reference.md` for the convention).
- Every rule that appears anywhere (workflow steps, alternate/unhappy paths, specs) must be covered by at least one Gherkin scenario in `test-cases.md`, tracked in that file's traceability table.
- Every rule also gets a unit test named in `implementation-guide.md`'s Rules Summary table, at the enforcement point — the Gherkin scenario proves the behavior end to end; the unit test proves the rule in isolation. Neither substitutes for the other.

Read `reference.md` before drafting `implementation-guide.md` for the first time in a session — it defines the use-case-vs-workflow distinction and the DDD vocabulary the template expects, and getting this wrong is the most common way these docs end up confused with each other.

### 6. Update the index

Add or update the corresponding row(s) in `features/README.md` under the project's external output location (create it from scratch, with just a header and table, if this is the first feature documented in the project).

### 7. Present and iterate

Summarize what was created and ask if anything needs correcting. Keep revising until the user gives an explicit confirmation. Don't treat silence, or a message about something unrelated, as approval to call the doc set final.

### 8. State the boundary

Make clear that this output is a planning artifact — implementing the feature is a separate, later step.

## Interaction with other skills

- **`interview-me`** — upstream. If the feature request itself is underspecified ("build something for X"), resolve intent with `interview-me` first; `feature-doc` then documents a feature that's already been identified, not extracts what to build.
- **`idea-refine`** — upstream. For a vague concept that hasn't been shaped into a concrete feature yet, run ideation there first; `feature-doc` assumes the feature is already concrete enough to interview about and document.
- **`spec-driven-development`** — a lighter alternative, not a prerequisite. It produces a single `SPEC.md` PRD; `feature-doc` produces three cross-referenced, per-actor artifacts grounded in existing project docs. Reach for `feature-doc` when a feature needs that level of structure (multiple actors, traceable rules, Gherkin test cases); reach for `spec-driven-development` when a single PRD is enough.
- **`planning-and-task-breakdown`** — downstream. Once a feature's doc set exists, break `implementation-guide.md`'s workflow steps into tasks the normal way.
