---
name: breakdown-feature-implementation
description: Turns a feature PRD into a technical implementation plan — system architecture across frontend/API/business-logic/data/infrastructure layers, database schema, API design, frontend component hierarchy, and security/performance considerations, carrying forward the PRD's Constraints and Business Rules as concrete technical invariants, in prose and plain-Markdown diagrams only (no Mermaid, no real code). Use when a feature PRD or spec exists and needs a technical design before task breakdown, or when asked for an "implementation plan", "technical design for this feature", or to "turn this PRD into an architecture doc".
---

# Breakdown Feature Implementation

## Overview

Assembles a per-feature technical design doc from an existing PRD — system architecture, database schema, API design, frontend architecture, and security/performance, in prose and plain-Markdown diagrams (ASCII boxes and trees, never Mermaid or an external tool). Delegates API contract conventions to `api-and-interface-design` rather than reimplementing them; this skill's job is assembling the feature-specific content into one coherent plan, grounded in the project's real stack — and making sure nothing the PRD called a Constraint or a Business Rule quietly disappears on the way to a technical plan.

## When to Use

- A feature PRD (from `breakdown-feature-prd`, or any existing PRD/spec) exists and needs a technical design before implementation tasks are cut
- NOT when only an ordered task list is needed — use `planning-and-task-breakdown`, downstream of this plan
- NOT when only one Mermaid diagram is needed for an existing Markdown doc — use `design-doc-diagramming` directly; this skill's own diagrams are plain Markdown, not Mermaid
- NOT when only general API contract principles are needed — use `api-and-interface-design` directly

## Process

### 1. Confirm the input

Locate one feature's `features/<feature-slug>/prd.md` (from `breakdown-feature-prd`), or any other spec the user points at — stop and ask if missing. Never infer requirements from the current implementation; that makes the plan circular instead of a reflection of intent. This skill always operates on one feature at a time, even if `breakdown-feature-prd` produced many.

Read the PRD's Constraints and Business Rules sections as closely as its Requirements — they carry forward into Step 3, not just the Requirements list. If the PRD predates these sections (an older doc without them) but the feature clearly has either — a regulatory limit, a precedence rule — use the `AskUserQuestion` tool to confirm what's actually there before drafting the plan, rather than silently assuming none exist.

Also read the PRD's Open Questions section. For each one that's actually relevant to this plan (touches the architecture, data model, API, or a security/performance decision — not every open question will), use `AskUserQuestion` to check whether it can be resolved now. If it can, treat the answer as settled input to Step 3. If it can't, it doesn't block the rest of the plan — carry it forward with a suggested workaround instead of silently picking an answer and drafting around it as if it were decided (see Step 3's Inherited Open Questions).

### 2. Ground in the real stack

Determine the real stack from whichever of these actually applies, in this order:

1. **Stated directly** — the user (or the PRD) already named a stack or framework (e.g. "use NestJS for the backend"). Take it as ground truth; no need to explore or ask further about that choice.
2. **Detected from the codebase** — code already exists. Explore it and reflect what's really there (e.g. a `nest-cli.json` and `@nestjs/*` packages mean NestJS conventions — modules, controllers, providers, DTOs, decorators — not a generic Express layout).
3. **Neither** — nothing was stated and there's no existing code to detect from (a greenfield project). Use the `AskUserQuestion` tool to ask rather than defaulting to whatever's most common.

Layers, component trees, and type shapes in the rest of this plan must reflect whichever of these actually resolved the stack — never an invented or example one. If something else about the project's conventions is unclear at any later step (not just the stack itself), the same rule applies: use `AskUserQuestion` rather than guessing.

### 3. Draft the plan

**Goal** — 3-5 sentences.

**Requirements** — refined from the PRD's Requirements, across whichever of its types apply (Business, Functional, Non-Functional, Data, Security, Reporting) — not narrowed back down to just functional/non-functional on the way in.

**Constraints** — restate each of the PRD's Constraints as a concrete technical constraint on this plan, not a copy-pasted sentence: a regulatory data-residency rule becomes a specific statement about which Infrastructure-layer region/deployment it rules out; a "must integrate with X as-is" constraint becomes a specific integration-point note in the Architecture Overview. A constraint that doesn't visibly shape some part of the plan below wasn't actually carried forward.

**Business Rules → Technical Invariants** — translate each of the PRD's Business Rules into an explicit, concrete rule tied to a specific place in this plan: a precedence rule becomes an explicit ordering step in the System Architecture Overview or API Design's request handling; a default-under-ambiguity rule becomes an explicit fallback branch, not an assumption left implicit in prose. Name which layer or endpoint enforces each one.

**Inherited Open Questions** — any of the PRD's Open Questions that Step 1 couldn't resolve, and that are actually relevant to this plan, get carried forward here — each tied to the specific section it affects (e.g. "API Design's retry policy assumes X, pending confirmation of Y"). This is not the same list as the Constraints/Business Rules above: those are settled and now translated; these are still genuinely open, and the plan has to say so rather than quietly resolving them by picking whichever answer was most convenient to draft around.

Don't let an unresolved one stall the rest of the plan, though. For each, give a **suggested workaround** — the simplest reasonable interim approach the plan actually uses so the affected section (Architecture, Schema, API, etc.) can still be drafted concretely, labeled clearly as provisional and pending confirmation, not silently folded in as if it were settled. This is what keeps the plan buildable in the meantime while still being honest about what's still open — the same posture as an Assumption in a spec, not a blocker that halts everything else. Omit this subsection only when there's genuinely nothing inherited — don't leave a stale placeholder.

**Technical Considerations:**

Before drafting the sections below, actually read `references/coding-patterns.md` — its five structural patterns (clear main path, external systems behind a boundary, unrepresentable invalid states, decisions separated from actions, useful errors) aren't optional background reading, they're what this step applies. Bake each one that genuinely applies into the specific section it shapes — don't cite the pattern by name in the document (see `references/no-internal-tooling-in-output.md`), just make the concrete decision it implies visible in the plan itself:

Also read `references/library-reuse.md` before drafting — it's language-agnostic, covering Node/TS, Python, C#/.NET, Go, and more, each category naming the library idiomatic to whichever ecosystem Step 2 actually resolved (never default to a JS/TS library out of habit on a Python or C# plan). Wherever the plan calls for logic that a proven library already solves — date math, schema validation, HTTP retries, auth, background jobs, and the rest of that reference's categories — name the specific library for this project's actual stack in the relevant section (e.g. "validated with `pydantic`" on a Python plan, "date range math via `NodaTime`" on a C# plan) instead of describing custom logic to hand-write. This applies most visibly in System Architecture Overview (which library backs each boundary/adapter), API Design (validation and auth libraries), and Database Schema Design (ORM choice).

- **System Architecture Overview** — draw the diagram directly, in plain Markdown: an ASCII box-and-arrow layout (`┌──┐`, `│`, `└──┘`, `─▶`) organized top-to-bottom or left-to-right as Frontend, API, Business Logic, Data, and Infrastructure layers, with labeled data-flow arrows. No Mermaid, no external tool, no delegation — this skill draws its own diagrams. Any third-party service (payment processor, email provider, external API) gets its own named boundary/adapter in the diagram — never drawn as if business logic talks to the vendor directly.
- **Database Schema Design** — a plain-Markdown entity/relationship layout (one block per table — name, fields with type, PK/FK markers — with relationships stated in prose or a simple `Orders 1──N LineItems` line, not a Mermaid ER diagram) plus indexing strategy, foreign-key relationships, migration strategy, and **data classification per table/column** (sensitivity class, and how sensitive ones are protected — e.g. separate encryption key) — mirroring the PRD's Data requirement type, not left as an afterthought. Model status/state fields as one closed-set field, not several independently-settable booleans/nullables that could combine into an invalid state.
- **API Design** — a per-feature endpoint table (method, path, auth, request, response), applying the `api-and-interface-design` skill's conventions (error envelope, naming, pagination, contract-first) rather than inventing new ones — apply the conventions, never name the skill in the saved document itself (see `references/no-internal-tooling-in-output.md`). Every error response names what failed and with what input, not a bare generic message; any decision logic behind an endpoint (validation, retries, pricing, permissions) gets named as its own step, separate from the action it triggers — this is also where each Business Rule's "Technical Invariant" from above actually lands.
- **Frontend Architecture** — a component hierarchy tree (plain-Markdown indented list, not a diagram file) genericized to the project's actual UI library (never hardcoded to a specific library the project doesn't use), its state-management approach, and key type/interface shapes.
- **Security & Performance** — apply the `security-and-hardening` and `performance-optimization` skills' checklists rather than re-deriving them from scratch — again, apply the thinking, never cite the skill name in the document.

Pseudocode only — no real code blocks. Real implementation belongs to `incremental-implementation` and `test-driven-development`, later.

### 4. Save and hand off

Save to `features/<feature-slug>/implementation-plan.md` under the project's external output location (see `references/external-output-paths.md`), sibling to the feature's `prd.md`. Check whether a plan for this feature already exists before writing; if so, confirm with the user whether to update it in place or start a new one. Tell the user the full path, and suggest `planning-and-task-breakdown` as the next step to cut this into ordered tasks — that suggestion belongs in this chat reply, never written into the saved document itself (see `references/no-internal-tooling-in-output.md`).

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll reuse a generic example stack for the diagrams" | The diagrams and component trees must reflect this project's real stack — stated, detected, or asked about, never a generic default. |
| "No stack was mentioned, I'll just pick the most common one" | Defaulting to a popular framework is still guessing — on a greenfield project with nothing stated or detectable, use `AskUserQuestion` instead. |
| "I'll skip the diagrams, they're slow to get right" | An ASCII box-and-arrow layout takes minutes to draw directly in Markdown — the diagrams are the section's whole point, not an optional extra. |
| "Mermaid would render cleaner, I'll use it anyway" | This skill's diagrams are plain Markdown only — no Mermaid, no external renderer dependency. If a polished Mermaid version is wanted for a separate design doc later, that's `design-doc-diagramming`'s job, not this plan's. |
| "Real code is clearer than pseudocode here" | The no-code constraint is explicit — real code belongs downstream, in `incremental-implementation`/`test-driven-development`. |
| "I'll invent the API conventions for this feature" | `api-and-interface-design` already owns error envelope, naming, and pagination conventions — reuse them, don't reinvent. |
| "I'll copy the PRD's Constraints and Business Rules text in as-is" | Copying the sentence isn't carrying it forward — each one needs to visibly shape a specific part of the plan (a layer, an endpoint, a fallback branch), or it wasn't actually translated. |
| "The PRD didn't have Constraints or Business Rules sections, so there aren't any" | An older PRD predating those sections can still have a real regulatory limit or precedence rule buried in its Requirements — ask rather than assume none exist. |
| "I'll just pick the most likely answer to this Open Question and draft around it" | That's the same guessing this skill refuses to do for the stack — if it can't be resolved via `AskUserQuestion`, carry it forward explicitly as an Inherited Open Question instead of quietly deciding it. |
| "The PRD's Open Questions are its problem, not this plan's" | Some of them are directly about this plan's architecture, data model, or API — checking which ones apply is what keeps the technical design honest about what's actually still undecided. |
| "I'll leave that section vague until the open question is answered" | Vagueness isn't neutral — it leaves the next person nothing to build from. Give a labeled, provisional workaround so the plan stays concrete, without pretending the question is actually settled. |
| "`references/coding-patterns.md` is in See Also, I don't need to read it to draft this" | See Also isn't optional further reading here — the patterns are what Technical Considerations is supposed to apply. A plan drafted without them is generic, not grounded in this feature's actual boundaries and decisions. |
| "I'll describe the date/validation/auth logic in prose, the implementer can pick a library" | Naming the library is the plan's job — `references/library-reuse.md` exists so a senior engineer's default choices are visible in the plan itself, not deferred to whoever implements it. |

## Red Flags

- Architecture or stack details invented without checking whether a stack was stated, detected from the codebase, or actually needed to be asked about
- A default framework/stack assumed on a greenfield project instead of using `AskUserQuestion`
- API section reinvents conventions instead of using `api-and-interface-design`'s
- Real (non-pseudo) code blocks in the plan
- Missing Security & Performance section
- No confirmed input PRD/spec — requirements inferred from the current implementation instead
- A Mermaid code fence anywhere in the plan
- A PRD Constraint or Business Rule that doesn't visibly shape any specific part of the plan
- Database Schema Design with no data classification noted for sensitive tables/columns
- A relevant Open Question from the PRD silently resolved instead of carried forward or asked about
- The plan reads as fully settled when a real Inherited Open Question was quietly dropped
- An Inherited Open Question with no suggested workaround, leaving the section it affects vague instead of concrete
- A workaround presented without being clearly labeled as provisional/pending confirmation
- Third-party services drawn as if business logic talks to them directly, with no named boundary/adapter
- Status/state modeled as several independent booleans/nullables instead of one closed-set field
- A decision (validation, retry, pricing, permission) buried inline in an endpoint's action instead of named as its own step
- Errors in the API Design with no indication of what failed or with what input
- Logic described in prose for a category `references/library-reuse.md` covers (date math, validation, auth, HTTP retries, etc.) with no library named
- A library recommended from the wrong ecosystem (e.g. a JS/TS default named on a Python or C# plan) because Step 2's stack resolution wasn't actually checked against `references/library-reuse.md`'s per-ecosystem columns

## Verification

- [ ] The input PRD or spec was confirmed to exist before drafting began
- [ ] The stack was resolved via one of the three cases (stated directly, detected from the codebase, or asked about via `AskUserQuestion`) — never assumed or defaulted
- [ ] The System Architecture and Database Schema diagrams were drawn directly in plain Markdown (ASCII boxes/trees) — no Mermaid, no delegation to `design-doc-diagramming`
- [ ] The API Design section follows `api-and-interface-design`'s conventions
- [ ] No real code blocks — pseudocode only
- [ ] Security & Performance considerations are present and cross-reference the relevant checklists
- [ ] `references/coding-patterns.md` was actually read and applied — external services have a named boundary, state is modeled to exclude invalid combinations, decisions are separated from actions, and errors carry real context
- [ ] `references/library-reuse.md` was actually read and applied — every category it covers that the feature touches names a specific library rather than describing custom logic
- [ ] Every Constraint and Business Rule from the input PRD is reflected somewhere concrete in this plan, not just copied as prose
- [ ] Database Schema Design states each table/column's data classification and how sensitive ones are protected
- [ ] The PRD's Open Questions were checked for relevance to this plan; the relevant ones were either resolved via `AskUserQuestion` or carried forward as Inherited Open Questions, never silently picked
- [ ] Every unresolved Inherited Open Question has a labeled, provisional workaround so its affected section stays concrete rather than vague
- [ ] The plan was saved to `features/<feature-slug>/implementation-plan.md` in the project's external output location (see `references/external-output-paths.md`), with the existing-file case handled if applicable

## See Also

- `breakdown-feature-prd` — produces this skill's upstream input, including the Constraints and Business Rules this skill carries forward
- `design-doc-diagramming` — for a polished Mermaid version of a diagram in a separate design doc; not used by this skill's own plain-Markdown diagrams
- `api-and-interface-design` — API contract conventions this skill's endpoint table follows
- `planning-and-task-breakdown` — downstream, turns this plan into an ordered task list
- `security-and-hardening` / `performance-optimization` — checklists for the Security & Performance section
- `references/coding-patterns.md` — structural conventions worth encoding into the plan's pseudocode (clear main path, external systems behind a boundary, unrepresentable invalid states, decisions separated from actions, useful errors)
- `references/library-reuse.md` — which proven library to name for a given category (date/time, validation, auth, HTTP, ORM, etc.) instead of describing custom logic
- `references/external-output-paths.md` — where this skill's output lives
- `references/no-internal-tooling-in-output.md` — why the saved plan never names a skill, even where the plan applies that skill's conventions
