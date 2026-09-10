---
name: breakdown-feature-implementation
description: Turns a feature PRD into a technical implementation plan — system architecture across frontend/API/business-logic/data/infrastructure layers, database schema, API design, frontend component hierarchy, and security/performance considerations, in prose and diagrams only (no real code). Use when a feature PRD or spec exists and needs a technical design before task breakdown, or when asked for an "implementation plan", "technical design for this feature", or to "turn this PRD into an architecture doc".
---

# Breakdown Feature Implementation

## Overview

Assembles a per-feature technical design doc from an existing PRD — system architecture, database schema, API design, frontend architecture, and security/performance, in prose and diagrams. Delegates diagram mechanics to `design-doc-diagramming` and API contract conventions to `api-and-interface-design` rather than reimplementing either; this skill's job is assembling the feature-specific content into one coherent plan, grounded in the project's real stack.

## When to Use

- A feature PRD (from `breakdown-feature-prd`, or any existing PRD/spec) exists and needs a technical design before implementation tasks are cut
- NOT when only an ordered task list is needed — use `planning-and-task-breakdown`, downstream of this plan
- NOT when only one diagram is needed for an existing doc — use `design-doc-diagramming` directly
- NOT when only general API contract principles are needed — use `api-and-interface-design` directly

## Process

### 1. Confirm the input

Locate one feature's `features/<feature-slug>/prd.md` (from `breakdown-feature-prd`), or any other spec the user points at — stop and ask if missing. Never infer requirements from the current implementation; that makes the plan circular instead of a reflection of intent. This skill always operates on one feature at a time, even if `breakdown-feature-prd` produced many.

### 2. Ground in the real stack

Explore the codebase's actual stack and architecture before drafting anything. Layers, component trees, and type shapes must reflect what's really there — never an invented or example stack. Ask if the project's stack or conventions are unclear rather than assuming a default.

### 3. Draft the plan

**Goal** — 3-5 sentences.

**Requirements** — refined from the PRD's functional and non-functional requirements.

**Technical Considerations:**

- **System Architecture Overview** — invoke `design-doc-diagramming` to draft the Mermaid diagram, organized as subgraphs for Frontend, API, Business Logic, Data, and Infrastructure layers, with labeled data-flow arrows. This skill supplies the layer content; `design-doc-diagramming` owns diagram-type selection, drafting, and validation.
- **Database Schema Design** — an ER diagram (via `design-doc-diagramming`) plus table specs, indexing strategy, foreign-key relationships, and migration strategy in prose.
- **API Design** — a per-feature endpoint table (method, path, auth, request, response), following `api-and-interface-design`'s conventions (error envelope, naming, pagination, contract-first) rather than inventing new ones.
- **Frontend Architecture** — a component hierarchy tree genericized to the project's actual UI library (never hardcoded to a specific library the project doesn't use), its state-management approach, and key type/interface shapes.
- **Security & Performance** — cross-reference `security-and-hardening` and `performance-optimization` checklists rather than re-deriving them.

Pseudocode only — no real code blocks. Real implementation belongs to `incremental-implementation` and `test-driven-development`, later.

### 4. Save and hand off

Save to `features/<feature-slug>/implementation-plan.md` under the project's external output location (see `references/external-output-paths.md`), sibling to the feature's `prd.md`. Check whether a plan for this feature already exists before writing; if so, confirm with the user whether to update it in place or start a new one. Tell the user the full path, and suggest `planning-and-task-breakdown` as the next step to cut this into ordered tasks.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll reuse a generic example stack for the diagrams" | The diagrams and component trees must reflect this project's real stack — ground in the actual codebase, ask if unclear. |
| "I'll skip the diagrams, they're slow to get right" | Delegate to `design-doc-diagramming` rather than skipping — the diagrams are the section's whole point, not an optional extra. |
| "Real code is clearer than pseudocode here" | The no-code constraint is explicit — real code belongs downstream, in `incremental-implementation`/`test-driven-development`. |
| "I'll invent the API conventions for this feature" | `api-and-interface-design` already owns error envelope, naming, and pagination conventions — reuse them, don't reinvent. |

## Red Flags

- Architecture or stack details invented without checking the actual codebase
- API section reinvents conventions instead of using `api-and-interface-design`'s
- Real (non-pseudo) code blocks in the plan
- Missing Security & Performance section
- No confirmed input PRD/spec — requirements inferred from the current implementation instead

## Verification

- [ ] The input PRD or spec was confirmed to exist before drafting began
- [ ] The project's actual stack and architecture were explored, not assumed
- [ ] The System Architecture and Database Schema diagrams were drafted via `design-doc-diagramming`, not reimplemented from scratch
- [ ] The API Design section follows `api-and-interface-design`'s conventions
- [ ] No real code blocks — pseudocode only
- [ ] Security & Performance considerations are present and cross-reference the relevant checklists
- [ ] The plan was saved to `features/<feature-slug>/implementation-plan.md` in the project's external output location (see `references/external-output-paths.md`), with the existing-file case handled if applicable

## See Also

- `breakdown-feature-prd` — produces this skill's upstream input
- `design-doc-diagramming` — diagram type selection, drafting, and validation mechanics
- `api-and-interface-design` — API contract conventions this skill's endpoint table follows
- `planning-and-task-breakdown` — downstream, turns this plan into an ordered task list
- `security-and-hardening` / `performance-optimization` — checklists for the Security & Performance section
- `references/coding-patterns.md` — structural conventions worth encoding into the plan's pseudocode (clear main path, external systems behind a boundary, unrepresentable invalid states, decisions separated from actions, useful errors)
- `references/external-output-paths.md` — where this skill's output lives
