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

**Technical Considerations:**

- **System Architecture Overview** — draw the diagram directly, in plain Markdown: an ASCII box-and-arrow layout (`┌──┐`, `│`, `└──┘`, `─▶`) organized top-to-bottom or left-to-right as Frontend, API, Business Logic, Data, and Infrastructure layers, with labeled data-flow arrows. No Mermaid, no external tool, no delegation — this skill draws its own diagrams.
- **Database Schema Design** — a plain-Markdown entity/relationship layout (one block per table — name, fields with type, PK/FK markers — with relationships stated in prose or a simple `Orders 1──N LineItems` line, not a Mermaid ER diagram) plus indexing strategy, foreign-key relationships, migration strategy, and **data classification per table/column** (sensitivity class, and how sensitive ones are protected — e.g. separate encryption key) — mirroring the PRD's Data requirement type, not left as an afterthought.
- **API Design** — a per-feature endpoint table (method, path, auth, request, response), following `api-and-interface-design`'s conventions (error envelope, naming, pagination, contract-first) rather than inventing new ones.
- **Frontend Architecture** — a component hierarchy tree (plain-Markdown indented list, not a diagram file) genericized to the project's actual UI library (never hardcoded to a specific library the project doesn't use), its state-management approach, and key type/interface shapes.
- **Security & Performance** — cross-reference `security-and-hardening` and `performance-optimization` checklists rather than re-deriving them.

Pseudocode only — no real code blocks. Real implementation belongs to `incremental-implementation` and `test-driven-development`, later.

### 4. Save and hand off

Save to `features/<feature-slug>/implementation-plan.md` under the project's external output location (see `references/external-output-paths.md`), sibling to the feature's `prd.md`. Check whether a plan for this feature already exists before writing; if so, confirm with the user whether to update it in place or start a new one. Tell the user the full path, and suggest `planning-and-task-breakdown` as the next step to cut this into ordered tasks.

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

## Verification

- [ ] The input PRD or spec was confirmed to exist before drafting began
- [ ] The stack was resolved via one of the three cases (stated directly, detected from the codebase, or asked about via `AskUserQuestion`) — never assumed or defaulted
- [ ] The System Architecture and Database Schema diagrams were drawn directly in plain Markdown (ASCII boxes/trees) — no Mermaid, no delegation to `design-doc-diagramming`
- [ ] The API Design section follows `api-and-interface-design`'s conventions
- [ ] No real code blocks — pseudocode only
- [ ] Security & Performance considerations are present and cross-reference the relevant checklists
- [ ] Every Constraint and Business Rule from the input PRD is reflected somewhere concrete in this plan, not just copied as prose
- [ ] Database Schema Design states each table/column's data classification and how sensitive ones are protected
- [ ] The plan was saved to `features/<feature-slug>/implementation-plan.md` in the project's external output location (see `references/external-output-paths.md`), with the existing-file case handled if applicable

## See Also

- `breakdown-feature-prd` — produces this skill's upstream input, including the Constraints and Business Rules this skill carries forward
- `design-doc-diagramming` — for a polished Mermaid version of a diagram in a separate design doc; not used by this skill's own plain-Markdown diagrams
- `api-and-interface-design` — API contract conventions this skill's endpoint table follows
- `planning-and-task-breakdown` — downstream, turns this plan into an ordered task list
- `security-and-hardening` / `performance-optimization` — checklists for the Security & Performance section
- `references/coding-patterns.md` — structural conventions worth encoding into the plan's pseudocode (clear main path, external systems behind a boundary, unrepresentable invalid states, decisions separated from actions, useful errors)
- `references/external-output-paths.md` — where this skill's output lives
