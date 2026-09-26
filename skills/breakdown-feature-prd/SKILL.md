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

### 3. Check whether this is a refinement, not a fresh draft

Before drafting, check whether a `prd.md` already exists for this feature (single-feature mode, or a feature a prior sweep already covered) and whether it has an Open Questions section. If it does, and what was just gathered in Step 2 answers one or more of them, use the `AskUserQuestion` tool to confirm: refine the existing PRD with these answers, or proceed some other way (a fresh variant, or drafting a different feature instead) — the same "confirm before proceeding" gate `project-compass` uses when offered extra information partway through.

If refining: resolve each newly-answered Open Question by removing it from that section and propagating the answer into whichever section it actually affects — a Requirement becomes more specific, a Constraint gets confirmed as settled, a Business Rule gets its precedence clarified, an Acceptance Criterion gets added — not just noted inline as a comment. Leave any Open Questions that are still genuinely unanswered in place. This is a specific case of the existing-file convention in Step 5 below, driven by resolved questions rather than a generic re-run.

### 4. Draft each feature's PRD

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
10. **Open Questions** — genuinely unresolved items for this feature, drawn from four sources, never invented from nothing:
    - The source material's own admitted gaps, filtered to this feature — a "PROPOSED" marker, a placeholder, a decision the material itself defers to a future spec, anything the context flags as not yet settled.
    - The source material's own consolidated open-questions/risks section (if it has one), filtered to whichever items actually apply to this feature.
    - Ambiguity that only surfaces while drafting this feature's own Requirements, Constraints, Business Rules, or Acceptance Criteria — writing a real Given/When/Then often exposes a case the source's prose never resolved, even when the source is otherwise detailed. This doesn't require more material than what's already there; it's a product of being specific.
    - A cross-feature dependency — this feature's behavior depends on a decision that actually belongs to a different feature or section not yet finalized. Name the dependency explicitly rather than assuming it'll resolve itself.

    This is not a dumping ground for anything answerable by just asking the user now — that's the "ask rather than invent" rule below, applied during drafting. Open Questions is for what's still unresolved after that, or genuinely belongs to someone else to decide later. Leave it empty (or omit it) when a feature genuinely has nothing left open — don't manufacture one to fill the section.

Everything traces back to the provided context. Ask rather than invent when the context doesn't say.

### 5. Save the feature doc

Save to `features/<feature-slug>/prd.md` under the project's external output location (see `references/external-output-paths.md`) — outside the project's own repo, never a path git in this project tracks or ignores. Check whether a doc for this feature already exists before writing; if so, confirm with the user whether to update it in place or start a new one (Step 3 already covers the specific case of refining with newly-answered Open Questions).

### 6. Update the index

Create or update `features/README.md` — one line per feature (name, link to its `prd.md`, one-sentence summary) — so it always reflects every feature doc that exists. Create it on first use.

If the feature's PRD has an Open Questions section, add its open items to that feature's index entry too, condensed into one or two sentences — not the full bulleted list copied verbatim. The point is a reader can tell at a glance whether a feature still has unresolved items without opening its `prd.md`. Omit this from the entry when the feature has no Open Questions section (or it's empty).

### 7. Report back

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
| "The source material was detailed, there's nothing left to flag as an open question" | A detailed source still has scattered gaps — PROPOSED markers, deferred decisions, cross-feature dependencies — and writing a real Given/When/Then often surfaces ambiguity the prose glossed over. Detailed isn't the same as fully resolved. |
| "I'll leave the Open Questions section out entirely to keep the doc clean" | Only skip it when a feature genuinely has nothing unresolved — check the four sources first; an empty section from a real check is fine, an omitted section from skipping the check isn't. |
| "I'll just re-draft the whole PRD from scratch since I have new answers" | Refining resolves the specific Open Questions the new information answers and propagates them into the sections they affect — it doesn't discard everything already confirmed. A full re-draft risks silently losing content that was already agreed. |
| "The index just needs the summary, Open Questions are in the prd.md if anyone needs them" | A reader scanning the index to decide what to work on next can't see that without opening every linked doc — a one- or two-sentence hint of what's still open is what makes the index actually useful for prioritizing, not just for navigation. |

## Red Flags

- A feature list enumerated and drafted without user confirmation
- Stories with no acceptance criteria
- Vague requirements ("fast", "secure") with no specifics
- Every requirement dumped into Functional/Non-Functional with no Data or Security requirement considered, on a feature that clearly touches either
- A decision rule (precedence, default-under-ambiguity, override) buried inside one story instead of stated as its own Business Rule
- A regulatory, technical, or resourcing constraint described as if it were a Non-Functional Requirement the team chose
- Invented Impact metrics not traceable to the provided context
- `features/README.md` left stale after a new feature doc is written
- A feature with real Open Questions has no hint of that in its `features/README.md` entry
- A feature's Open Questions copied into `features/README.md` as the full bulleted list instead of a one- or two-sentence condensation
- No Open Questions section, and no evidence the four sources were actually checked
- An Open Questions item that's really just something the user could have been asked directly during drafting
- A PRD re-drafted from scratch when the actual need was refining specific answered Open Questions
- Refinement proceeded without confirming via `AskUserQuestion` first

## Verification

- [ ] Mode (whole-project sweep vs. single feature) was determined from the request, not assumed
- [ ] For a sweep, the feature list was confirmed with the user before any doc was drafted
- [ ] Every section (Goal, Personas, Stories, Requirements, Acceptance Criteria, Out of Scope) traces back to the provided context, with gaps asked about rather than invented
- [ ] Every user story has at least one Given/When/Then acceptance criterion
- [ ] Requirements were checked against all six types (Business, Functional, Non-Functional, Data, Security, Reporting), not defaulted to just Functional/Non-Functional
- [ ] Externally imposed limits are captured as Constraints, not folded into Non-Functional Requirements
- [ ] Cross-story decision logic (precedence, defaults, overrides) is captured as its own Business Rule, not buried in one story's acceptance criteria
- [ ] Open Questions were checked against all four sources (source's own admitted gaps, source's own open-questions section, ambiguity surfaced while drafting, cross-feature dependencies) — not invented, and not skipped without checking
- [ ] When new information answered an existing feature's Open Questions, refinement was confirmed via `AskUserQuestion` before updating, and only the resolved questions plus their downstream effects changed
- [ ] Each feature's PRD was saved to `features/<feature-slug>/prd.md` in the project's external output location (see `references/external-output-paths.md`), with the existing-file case handled if applicable
- [ ] `features/README.md` was created or updated to reflect every feature doc that exists
- [ ] Any feature with a non-empty Open Questions section has those items summarized in one or two sentences in its `features/README.md` entry — not omitted, and not pasted verbatim
- [ ] The user was told the full path(s) written

## See Also

- `spec-driven-development` — the downstream engineering spec this PRD typically feeds
- `github-issue-planning` — turns a PRD into a GitHub Issues hierarchy
- `deep-dive` / `interview-me` / `idea-refine` — upstream, if the idea or context is still too fuzzy to enumerate personas and stories from
- `acquire-codebase-knowledge` — grounding for a whole-project sweep when the codebase itself is the context
- `breakdown-feature-implementation` — sibling skill that turns one feature's PRD into a technical implementation plan
- `references/external-output-paths.md` — where this skill's output lives
