---
name: breakdown-feature-prd
description: Writes product-facing feature PRDs grounded in project context or docs you provide — Problem/Solution/Impact framing, user personas, user stories with Given/When/Then acceptance criteria, functional and non-functional requirements, and explicit out-of-scope — either for every feature it identifies in that context, or for one named feature, always keeping a single index of every feature doc produced. Use when asked to "write a PRD for this feature", "break down this project/doc into feature PRDs", or "product requirements" for a feature, before an engineering spec exists.
---

# Breakdown Feature PRD

## Overview

Writes PM/stakeholder-facing requirements documents, one per feature — upstream of and distinct from `spec-driven-development`'s engineering `SPEC.md`. Project-based rather than Epic-based: driven by whatever context or docs the user hands it (a product brief, existing docs, a README, or the codebase itself), not a pre-existing Epic hierarchy. Two entry points — sweep a whole project's context into a PRD per feature, or produce just one feature's PRD on request — and either way, maintains one running index (`features/README.md`) linking every feature doc produced so far.

## When to Use

- Project or product context/docs exist (or the user names one feature) and PM-facing requirements are needed before an engineering spec
- The user wants a PRD covering Problem/Solution/Impact, personas, user stories, and Given/When/Then acceptance criteria — not an engineering-facing spec
- NOT when the engineering spec itself is needed — use `spec-driven-development`, typically downstream of one of these PRDs
- NOT when only a GitHub Issues hierarchy is needed from an existing PRD — use `github-issue-planning`
- NOT when the idea or context is still too fuzzy to enumerate personas and stories from — use `deep-dive`, `interview-me`, or `idea-refine` first, then feed the result in as context

## Process

### 1. Determine mode

- **Whole-project sweep** — context/docs (or "the codebase") were given with no single feature named.
- **Single feature** — one feature was named directly.

### 2. Gather grounding context

Read whatever docs or context the user pointed at. For a whole-project sweep, also explore the codebase — same grounding mandate as `deep-dive` and `acquire-codebase-knowledge`: never invent a feature list from assumption. For a whole-project sweep, enumerate the candidate feature list and confirm it with the user (`AskUserQuestion`, or an explicit listed confirmation) before drafting any individual doc — don't silently decide scope.

### 3. Draft each feature's PRD

For each feature being documented, draft in order:

1. **Feature Name**
2. **Goal** — Problem / Solution / Impact, 3-5 sentences each. Ask for real impact signals from the provided context; never invent metrics.
3. **User Personas** — who, and their goals/context.
4. **User Stories** — `As a <persona>, I want to <action> so I can <benefit>`. Cover primary paths and edge cases.
5. **Requirements** — specific, unambiguous bullets, each tagged with its type: **Business** (why this matters commercially/strategically), **Functional** (what the feature does), **Non-Functional** (performance, accessibility, usability), **Data** (what's collected, its sensitivity class, retention/residency), **Security** (access control, encryption, isolation), **Reporting** (what gets measured or logged, and what must never be — e.g. no raw sensitive content in analytics). Not every feature needs all six — a simple UI tweak may only have Functional and Non-Functional — but check each type rather than defaulting to just Functional/Non-Functional, since Data and Security requirements in particular tend to get silently dropped when only two buckets are offered.
6. **Constraints** — externally imposed limits the feature has to work within, not chosen by the team: regulatory (e.g. a jurisdiction's data-residency rule), technical (a system it must integrate with as-is), timeline, or resourcing. Distinct from Non-Functional Requirements (system qualities the team designs for) and from Out of Scope (a boundary the team drew) — a constraint is imposed from outside.
7. **Business Rules** — invariant decision logic the feature must enforce across every story, not just one: precedence between conflicting conditions, default behavior under ambiguity, override rules. These rarely fit inside a single story's Given/When/Then and get silently dropped if there's no dedicated place for them — write each as a standalone declarative rule (e.g. "X always overrides Y," "when uncertain, default to the stricter option"), not folded into a story.
8. **Acceptance Criteria** — Given/When/Then per story or major requirement.
9. **Out of Scope** — what this feature explicitly does not include.

Everything traces back to the provided context. Ask rather than invent when the context doesn't say.

### 4. Save the feature doc

Save to `features/<feature-slug>/prd.md` under the project's external output location (see `references/external-output-paths.md`) — outside the project's own repo, never a path git in this project tracks or ignores. Check whether a doc for this feature already exists before writing; if so, confirm with the user whether to update it in place or start a new one.

### 5. Update the index

Create or update `features/README.md` — one line per feature (name, link to its `prd.md`, one-sentence summary) — so it always reflects every feature doc that exists. Create it on first use.

### 6. Report back

Tell the user the full path(s) written, including the index. Note that each `prd.md` is ready to hand directly to `breakdown-feature-implementation`, `spec-driven-development`'s downstream steps, `/build`, or any other spec-consuming skill or command.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll skip personas, it's obvious who the user is" | A story without a named persona hides assumptions the engineering spec will silently inherit. |
| "I can infer the feature list without asking" | An unconfirmed feature list turns a scoping decision into a silent one — confirm it first. |
| "spec-driven-development already covers this" | Different artifact and audience — a PM-facing PRD, not an engineering spec — not a replacement for it. |
| "I don't need to update the index, just the one doc" | The index is the whole point of a multi-feature project sweep — skipping it leaves later docs undiscoverable. |
| "I'll fill in the Impact numbers, they sound about right" | An invented metric reads as confirmed data to everyone downstream — ask for the real signal, or leave it as an open question. |
| "Functional and Non-Functional cover everything, I don't need the other types" | Data and Security requirements in particular tend to vanish inside a generic Non-Functional bucket — checking each type explicitly is what catches "what's the retention period" or "who can see this" before the engineering spec inherits the gap. |
| "I'll fold this decision rule into whichever story it came up in" | A rule like "X overrides Y" or "default to the stricter option under uncertainty" governs every story it applies to, not just the one where it was noticed — burying it in one story's acceptance criteria means every other story silently relies on unwritten logic. |
| "Constraints are basically the same as Non-Functional Requirements" | A constraint is imposed from outside (a regulation, a system you must integrate with as-is) — the team doesn't choose it and can't trade it off; a Non-Functional Requirement is a quality the team designs for. Conflating them hides which ones are actually non-negotiable. |

## Red Flags

- A feature list enumerated and drafted without user confirmation
- Stories with no acceptance criteria
- Vague requirements ("fast", "secure") with no specifics
- Every requirement dumped into Functional/Non-Functional with no Data or Security requirement considered, on a feature that clearly touches either
- A decision rule (precedence, default-under-ambiguity, override) buried inside one story instead of stated as its own Business Rule
- A regulatory, technical, or resourcing constraint described as if it were a Non-Functional Requirement the team chose
- Invented Impact metrics not traceable to the provided context
- `features/README.md` left stale after a new feature doc is written

## Verification

- [ ] Mode (whole-project sweep vs. single feature) was determined from the request, not assumed
- [ ] For a sweep, the feature list was confirmed with the user before any doc was drafted
- [ ] Every section (Goal, Personas, Stories, Requirements, Acceptance Criteria, Out of Scope) traces back to the provided context, with gaps asked about rather than invented
- [ ] Every user story has at least one Given/When/Then acceptance criterion
- [ ] Requirements were checked against all six types (Business, Functional, Non-Functional, Data, Security, Reporting), not defaulted to just Functional/Non-Functional
- [ ] Externally imposed limits are captured as Constraints, not folded into Non-Functional Requirements
- [ ] Cross-story decision logic (precedence, defaults, overrides) is captured as its own Business Rule, not buried in one story's acceptance criteria
- [ ] Each feature's PRD was saved to `features/<feature-slug>/prd.md` in the project's external output location (see `references/external-output-paths.md`), with the existing-file case handled if applicable
- [ ] `features/README.md` was created or updated to reflect every feature doc that exists
- [ ] The user was told the full path(s) written

## See Also

- `spec-driven-development` — the downstream engineering spec this PRD typically feeds
- `github-issue-planning` — turns a PRD into a GitHub Issues hierarchy
- `deep-dive` / `interview-me` / `idea-refine` — upstream, if the idea or context is still too fuzzy to enumerate personas and stories from
- `acquire-codebase-knowledge` — grounding for a whole-project sweep when the codebase itself is the context
- `breakdown-feature-implementation` — sibling skill that turns one feature's PRD into a technical implementation plan
- `references/external-output-paths.md` — where this skill's output lives
