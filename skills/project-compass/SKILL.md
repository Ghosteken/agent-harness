---
name: project-compass
description: Reads whatever documents and/or codebase exist for a project — even when incomplete or the feature set isn't decided yet — asks basic grounding questions in batched rounds to fill what the material doesn't answer, then produces one thorough, plain-language Project Overview (including a story-mode-style per-actor narrative, and a per-repo breakdown for multi-repo projects) plus two or more clearly-labeled Suggested Directions documents — speculative "you could do this" options with tradeoffs, not committed plans. Use when asked to "help me understand this project", "what am I even looking at", "give me the full picture from these docs", or "what could I do with this" before any feature or spec is confirmed.
---

# Project Compass

## Overview

Builds a thorough-but-accessible understanding of a project from whatever material actually exists — docs, notes, a codebase, or some mix — and turns it into two kinds of output: one detailed **Project Overview** written in plain language (with a story-mode-style narrative section woven in, not just dry facts), and several **Suggested Directions** documents that speculate on what could be built next, explicitly labeled as options rather than decisions. Like a compass, it doesn't hand back one path — it orients you and shows the directions actually available from where the project stands today.

This is for the stage before anything is confirmed: the feature set isn't known yet, so a PRD or spec would be premature. Distinct from `acquire-codebase-knowledge` (deep, evidence-dense technical reference docs meant for onboarding an agent into a codebase's conventions) and from `breakdown-feature-prd`/`breakdown-feature-implementation` (both require a specific, named feature already in scope).

## When to Use

- A pile of docs and/or a codebase exist for a project, and the ask is "help me understand what this is" — without knowing yet what to build
- A **thorough** overview is wanted, not a skimmable summary — detailed enough that reading it once leaves nothing major unexplained, while still being written in plain language rather than a dense technical reference
- Suggested, non-committal implementation directions are wanted — "if this happens, you could do X, or Y" — not a confirmed plan
- NOT when a specific feature is already known and a PM-facing requirements doc is wanted — use `breakdown-feature-prd`
- NOT when deep, evidence-dense technical reference docs are the goal (full codebase onboarding, conventions, integrations) — use `acquire-codebase-knowledge`
- NOT when one specific idea needs interrogating into a concrete, committed spec — use `deep-dive` or `idea-refine`

## Process

### 1. Gather everything available

Read every document pointed at, and explore the codebase if one exists — same grounding mandate as `acquire-codebase-knowledge`/`deep-dive`/`story-mode`: never invent what isn't actually there. If docs and code conflict (a README describing something the code doesn't do, or vice versa), note the conflict explicitly rather than silently picking one side.

Note whether the material spans **more than one repository** — separate git roots, or several codebases the user points at together (e.g. a frontend repo, a backend repo, a mobile app repo). This changes the shape of the output: see Step 4.

### 2. Confirm coverage

Before writing anything, tell the user what was actually found and ask whether anything else should be included — another document, a specific folder, someone's notes that weren't shared yet. Thoroughness built on a silently-partial set of material isn't real thoroughness.

### 3. Ask grounding questions, in rounds

Since nothing detailed about the project is known going in, expect real gaps the source material simply doesn't answer — purpose, intended audience, current stage (existing/greenfield/mid-build), hard constraints, explicit out-of-scope. Ask about these **before** drafting anything, not after, and note them as open questions in the doc only as a last resort.

Keep every question at a **basic, orienting level** — this is grounding, not interrogation. Deep, exhaustive, tree-shaped questioning belongs to `deep-dive`, once one direction has actually been chosen; asking that deeply here, before the project is even understood, is the wrong tool at the wrong stage.

Batch the questions using `grilling`'s frontier mechanic: ask everything currently answerable in one round (`AskUserQuestion`), then recompute what the answers newly unblock and ask that in the next round — rather than one question at a time, or one giant list upfront that ignores how later questions depend on earlier answers. Stop once the basic shape of the project is actually clear; don't manufacture additional rounds once grounding is sufficient.

### 4. Identify actors

Using `story-mode`'s method: infer the distinct actors/roles from auth or permission logic, user/entity models, and doc mentions (e.g. admin vs. end user, buyer vs. supplier). List the candidates and confirm them with the user (`AskUserQuestion`, or an explicit listed confirmation) before drafting — don't silently decide who the project is for.

### 5. Per-repo breakdown (multi-repo projects only)

When more than one repository is involved, give each one its own dedicated breakdown before writing the main Overview — don't blend several codebases into one narrative and lose which fact came from which repo. For each repository: identify its own actors/roles where they differ from the project-wide list (a backend repo might only be relevant to an admin/API-consumer, not an end user), and write one `story-mode`-style document — purpose of this specific repo, how it fits into the larger project, and a continuous-prose per-actor narrative scoped to just this codebase. Save each as `briefings/repos/<repo-slug>.md`.

Skip this step entirely for a single-repo (or docs-only) project — it exists specifically for the multi-repo case, not as a mandatory extra layer on every run.

### 6. Write the Project Overview

One document, detailed and plain-language — thorough enough that a reader comes away with nothing major unexplained, but written so someone unfamiliar with the domain's jargon can still follow it, translating jargon as it's introduced rather than leaving it bare. It has two parts, both in the same document:

- **What this is** — the project's purpose, current state, stack/domain at a level a non-specialist grasps, and what's genuinely unclear or unresolved. No implementation detail here, only "what is this and where does it stand."
- **How it actually works, actor by actor** — following `story-mode`'s technique, one continuous prose section per confirmed actor: their entry point, what they can do at each stage, what they wait on, what they receive at the end. This is what makes the overview *thorough* rather than a dry summary — a reader should be able to follow a real actor's journey through the project, not just read a bullet list of facts about it.

When Step 5 produced per-repo docs, add a **"Repositories in This Project"** section: a short paragraph per repo — what it is, its role in the larger system, how it relates to the others — with a link to its full `briefings/repos/<repo-slug>.md` breakdown. This is a condensed pointer, not a duplicate of the per-repo doc's content; the point is enough context to orient the reader before they follow a link, not to reproduce what's already written there.

Every claim in both parts traces back to something actually read or found — mark genuine gaps as gaps and ask, rather than filling them with a plausible guess.

### 7. Identify possible directions

From what was actually found — never invented — surface the natural branches: distinct problems this project could solve, or distinct ways it could reasonably be built or extended next. Frame each as a genuine option with a real tradeoff, not a foregone conclusion dressed up as a question.

### 8. Write the Suggested Directions documents

Produce **at least two, typically two or three** — more if the project's real size and complexity actually supports more distinct directions, never padded just to hit a count. One document per direction. Each covers: what pursuing this direction would involve, at the level of a suggestion (the shape of an approach and its key considerations/tradeoffs), and what would still need to be confirmed before it became a real plan. Every one of these is explicitly labeled as a suggestion, not a decision — the reader should come away with options to consider, not a plan to execute.

### 9. Save and index

Save the Overview, every per-repo breakdown, and every Suggested Directions doc to the project's external output location (see `references/external-output-paths.md`). Maintain an index linking the Overview, every repo breakdown, and every direction together so they're easy to navigate as a set.

### 10. Report back and point to the next step

Tell the user the full paths written, which actors the Overview covers, and (for a multi-repo project) which repos got their own breakdown. For whichever direction they want to pursue for real, name the natural next skill: `deep-dive` if it still needs interrogating into specifics, or `breakdown-feature-prd`/`spec-driven-development` once it's concrete enough to commit to.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll fill the gaps with reasonable, industry-standard assumptions" | An assumption presented as fact in an overview reads as confirmed when it isn't — flag gaps as gaps, or ask, rather than smoothing over them. |
| "I should just recommend the one best direction" | The point of this skill is multiple labeled options, not a single confirmed recommendation — picking one is `spec-driven-development`'s job, after the user chooses. |
| "A short summary counts as thorough" | The Overview is explicitly meant to be detailed — a reader should come away with nothing major unexplained, not a one-paragraph gist. |
| "I'll just describe the actors instead of narrating their journeys" | A bulleted actor list isn't the story-mode technique this skill borrows — write one continuous prose section per actor, following them start to finish. |
| "Two directions is always enough" | Two is the floor, not a ceiling — a large or complex project can genuinely support more distinct directions; don't stop early just because the minimum was hit. |
| "This suggested direction is basically decided already" | Every direction stays labeled as an option with open considerations — writing it as settled misrepresents how confirmed it actually is. |
| "I'll blend all the repos into one narrative, it's simpler" | Blending loses which fact belongs to which codebase — give each repo its own breakdown doc, then summarize and link from the Overview. |
| "I'll just note the gaps in the doc instead of asking" | Basic grounding questions belong before drafting, not as a list of caveats after the fact — ask what's genuinely unclear, don't defer it to a footnote. |
| "I'll ask every possible question in one giant list upfront" | Some questions only make sense once earlier ones are answered — batch what's answerable now, recompute, and ask the next round, the same frontier mechanic `grilling` uses. |
| "I should interrogate this as thoroughly as deep-dive would" | Keep questions basic and orienting — the project isn't understood yet, so exhaustive tree-shaped interrogation is premature; that's `deep-dive`'s job once a direction is chosen. |

## Red Flags

- A Project Overview that's short on detail, or that uses domain jargon without explaining it
- An Overview with no per-actor narrative section, or one written as bullet points instead of continuous prose
- An actor list decided without user confirmation
- A Suggested Direction written as if it were already decided, with no tradeoffs or open considerations named
- Only one Suggested Direction produced for a project clearly large enough to support more
- Content in either document that traces to an assumption rather than something actually found in the source material
- Coverage never confirmed with the user before writing started
- A multi-repo project written as one blended narrative with no per-repo breakdown
- The Overview's repo summaries duplicating a per-repo doc's full content instead of pointing to it
- Drafting started with no grounding-question round, on a project that was never actually understood at even a basic level
- Grounding questions phrased as deep, exhaustive interrogation instead of basic orientation
- All questions dumped in one giant list instead of batched rounds that adapt to earlier answers

## Verification

- [ ] Every available document was read, and the codebase was explored if one exists — nothing invented
- [ ] Coverage was confirmed with the user before drafting began
- [ ] Basic grounding questions (purpose, audience, stage, constraints, out-of-scope) were asked in batched rounds before any drafting, using `grilling`'s frontier mechanic — not skipped, not exhaustive/deep-dive-level, not dumped in one giant list
- [ ] The actor list was confirmed with the user before drafting the narrative section
- [ ] The Project Overview is detailed and plain-language, and includes a continuous-prose, per-actor narrative section (not just factual bullets)
- [ ] At least two Suggested Directions were produced, scaled up if the project's real size supports more
- [ ] Every Suggested Direction traces to something found in the source material, not invented
- [ ] Each Suggested Direction is clearly labeled as an option, with tradeoffs and open considerations, not a committed plan
- [ ] Gaps and unknowns are called out explicitly rather than silently filled in
- [ ] For a multi-repo project, each repository got its own `story-mode`-style breakdown doc before the Overview was written
- [ ] The Overview's repo summaries (if any) point to the per-repo docs rather than duplicating their content
- [ ] The Overview, all per-repo breakdowns, and all Suggested Directions were saved to the project's external output location (see `references/external-output-paths.md`), with an index linking them
- [ ] The user was told the full paths written, which actors were covered, which repos got their own breakdown, and the natural next skill for whichever direction they choose

## See Also

- `story-mode` — the per-actor narrative technique this skill borrows for the Overview's second half and for each per-repo breakdown
- `grilling` — the batched-frontier questioning mechanic this skill borrows for basic grounding rounds, kept shallow rather than exhaustive
- `acquire-codebase-knowledge` — deeper, evidence-dense technical reference docs, once full codebase onboarding depth is actually wanted
- `breakdown-feature-prd` — once a specific feature is confirmed and a PM-facing requirements doc is wanted
- `deep-dive` — to interrogate one chosen direction into a concrete, committed spec
- `idea-refine` — companion for early-stage single-idea exploration, as opposed to this skill's whole-project, multiple-directions scope
- `spec-driven-development` — once a direction is confirmed and ready to become an engineering spec
- `references/external-output-paths.md` — where this skill's output lives
