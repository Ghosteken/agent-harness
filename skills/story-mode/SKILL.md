---
name: story-mode
description: Writes a plain-prose, start-to-finish narrative of a feature's or project's flow, one throughline per actor (user, admin, buyer, supplier, etc.), grounded in real docs/code/session history — not an engineering spec or PRD, a story a non-technical stakeholder can read end to end. Use when asked to "explain the whole flow", "tell the story of how this works", "walk through this from the user's and admin's perspective", or for a narrative/human-readable walkthrough of a feature or project section.
---

# Story Mode

## Overview

Turns a feature or project into a story a non-technical stakeholder can read start to finish — one continuous prose throughline per actor (a supplier, a buyer, an admin), not a bulleted feature list or a requirements document. It exists alongside `breakdown-feature-prd` rather than replacing it: the PRD documents requirements, this documents the lived experience of using them.

## When to Use

- Asked to "explain the whole flow", "tell the story of X", "walk me through this like a story", or "explain this to a non-technical person"
- A feature or project section already has enough real material (docs, code, prior session context) to ground a narrative — not a from-scratch idea
- NOT when the deliverable is requirements, personas, or acceptance criteria — use `breakdown-feature-prd`
- NOT when the idea is still too fuzzy to describe a real flow from — use `deep-dive`, `interview-me`, or `idea-refine` first
- NOT for an engineering-facing architecture explanation — use `acquire-codebase-knowledge` or `documentation-and-adrs`

## Process

### 1. Determine scope

- **Single feature** — one feature or project section was named.
- **Whole project** — no single feature named, or the user explicitly asked for the whole thing.

### 2. Gather grounding context

Read whatever docs, specs, or PRDs exist for the scope; explore the codebase for the actual flow (routes, forms, state machines, permission checks); and pull in relevant context already established earlier in this session. Same mandate as `acquire-codebase-knowledge` and `breakdown-feature-prd`: never invent a step, a number, a timeline, or an edge case that isn't traceable to something read. Where the material genuinely doesn't say, mark it as a gap and ask rather than fill it in with a plausible guess.

### 3. Identify actors

Infer the distinct actors/roles from auth or permission logic, user/entity models, and doc mentions (e.g. admin vs. end user, buyer vs. supplier, organiser vs. attendee). List the candidate actors and confirm them with the user (`AskUserQuestion`, or an explicit listed confirmation) before drafting — don't silently decide who the story is about, the same way `breakdown-feature-prd` confirms its feature list before drafting.

### 4. Draft the narrative

For each confirmed actor, write one continuous prose section following them start to finish — registration/entry point, what they can do at each stage, what they wait on, what they receive at the end — in plain, simple language a non-technical reader can follow, translating any jargon as it's introduced rather than leaving it bare. Use a concrete example (a named example company or person) where it helps make the flow tangible, but only if the source material supports it — otherwise keep it generic.

Where a coordinating or admin actor ties the other actors' journeys together (approves, schedules, publishes, intervenes), give them a closing section that shows how the individual threads converge into the single end-to-end shape.

Include a contingency/edge-case beat (what happens when something goes wrong — a cancellation, a no-show, a rollback) only when the user asked for one, or when something surfaced during grounding is clearly load-bearing to the real flow. Don't manufacture drama that isn't backed by the material.

### 5. Save the doc

Save to `features/<feature-slug>/story.md` (whole-project scope: `features/story.md`) under the project's external output location (see `references/external-output-paths.md`) — never a path this project's own git tracks or ignores. Check whether a story doc for this scope already exists before writing; if so, confirm with the user whether to update it in place or start a new variant.

### 6. Update the index

Add or refresh this doc's line in `features/README.md` — the same index `breakdown-feature-prd` maintains — alongside any `prd.md`/`implementation-plan.md` entry that already exists for the feature.

### 7. Report back

Tell the user the full path written and which actors the story covers.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll just summarize the feature list, it covers the same ground" | A bullet list isn't a story — the whole value is a continuous prose throughline a non-technical reader can follow start to finish. |
| "I'll invent a plausible edge case, it makes the story more interesting" | A fabricated contingency reads as fact to a stakeholder who wasn't there to know it's invented — only narrate what the material actually supports. |
| "The actors are obvious, I don't need to confirm them" | An unconfirmed actor list can silently omit a real role (e.g. a secondary delegate, a coordinating admin) that the grounding material only mentions in passing. |
| "This is basically the PRD in prose form" | Different audience and purpose — the PRD documents requirements and acceptance criteria; this documents lived experience. Don't just reflow one into the other. |
| "I don't need to update the index, it's a one-off doc" | The index is what makes every story doc discoverable later — skipping it leaves this one orphaned next to the feature's other docs. |

## Red Flags

- A story drafted as bullet points or a feature checklist instead of continuous prose
- An actor list decided without user confirmation
- A timeline, number, or contingency in the story that isn't traceable to anything read
- A contingency beat invented purely for narrative color
- `features/README.md` left stale after a new story doc is written

## Verification

- [ ] Scope (single feature vs. whole project) was determined from the request, not assumed
- [ ] The actor list was confirmed with the user before drafting
- [ ] Every claim in the story traces back to grounding material, with genuine gaps marked and asked about rather than invented
- [ ] Each confirmed actor has one continuous prose section, not a bulleted list
- [ ] Any contingency/edge-case beat included was either requested or clearly load-bearing in the real flow — not manufactured
- [ ] The doc was saved to `features/<feature-slug>/story.md` (or `features/story.md` for whole-project scope), with the existing-file case handled if applicable
- [ ] `features/README.md` was created or updated to include this story doc
- [ ] The user was told the full path written and which actors were covered

## See Also

- `breakdown-feature-prd` — the structured, requirements-facing sibling for the same feature; produces `prd.md` in the same `features/<feature-slug>/` directory
- `acquire-codebase-knowledge` — grounding for whole-project scope when the codebase itself is the primary source
- `design-doc-diagramming` — pairs well when a visual flow diagram should accompany the prose
- `deep-dive` / `interview-me` / `idea-refine` — upstream, if the idea is still too fuzzy to narrate a real flow from
- `references/external-output-paths.md` — where this skill's output lives
