---
name: deep-dive
description: Turns a one-line feature idea into a decision tree, interrogates it in batched rounds scaled to how many real sub-decisions it has (not a fixed count), then produces a 2-3 paragraph ready-to-use prompt plus a detailed branch-organized spec file. Use for a short idea that implies a whole feature domain with independent sub-decisions — role-based access, multi-tenancy, notifications, payments, search, a workflow engine. NOT for a single narrow ambiguity (use `interview-me`) or light product ideation (use `idea-refine`).
---

# Deep Dive

## Overview

Some ideas are one sentence but many decisions: "I want role-based access on this app" implies a role model, a permission granularity, an enforcement layer, a migration path, an audit trail, and a dozen edge cases — all independent, all needed before the idea is buildable. Asking about these one at a time (`interview-me`) is too slow for this many questions. Treating it as light ideation (`idea-refine`) undersamples it on purpose — that skill explicitly caps at 5-8 questions. `grilling` has the right mechanic — map a decision tree, interrogate a full round of unblocked questions at once — but it assumes the tree already exists as a drafted plan.

This skill is the missing first step: **build** the tree from a bare idea, grounded in what the codebase actually looks like, then hand it to `grilling`'s own frontier-batching mechanic to interrogate. The output is two things — a short prompt crystallizing every decision, and a spec file with the full trail of reasoning behind it.

## When to Use

- A short idea implies a whole feature domain with independent sub-decisions (auth/access control, multi-tenancy, notifications, payments, search, a workflow or approval engine, an integration with real edge cases)
- You want the idea turned into both something immediately usable (a prompt) and something durable (a spec) in one pass
- The user says "deep dive on this", "go deep on requirements", "ask me everything before we build this", "cover every angle", or "fully spec this before building"

**When NOT to use:**

- A single underspecified ask with no internal branching → `interview-me`
- The idea itself is still too vague to even name a feature ("something to help with onboarding") → `idea-refine` first
- A plan or design already exists in drafted form → `grilling` directly, no tree-building needed
- Trivial, self-contained changes → no Define-phase skill needed at all

## Process

### 1. Map the coverage tree

Before asking anything, explore the codebase. Dispatch sub-agents for anything discoverable — existing auth/user models, the ORM and frameworks in use, any prior art for a similar cross-cutting concern — never ask the user a fact a file read could answer. This is `grilling`'s rule, applied here too.

This exploration has a second job beyond gathering facts: surface the codebase's **existing architectural patterns and separation of concerns** — which layer currently owns what (routes/controllers vs. business logic vs. data access), naming and module conventions, and how anything structurally similar is already wired in. Every branch and both outputs must be grounded in this, not propose a shape that clashes with it.

Now decompose the idea into however many branches it actually implies. For "role-based access," that's naturally: role model & hierarchy, permission granularity, enforcement layer (UI/API/DB row-level), assignment & delegation, multi-tenancy interaction, audit & compliance, session/token propagation, migration of existing users, admin UX, **edge cases & failure modes**, testing strategy — roughly 8-12 branches for something this broad. A narrower idea gets fewer. **The testing-strategy branch always includes unit test coverage for each decision, not just integration/e2e** — resolve which decisions need a dedicated unit test (usually most of them) alongside whatever higher-level test levels the idea calls for.

**Edge cases and failure modes are their own branch, not an afterthought.** For RBAC: role changes mid-session, conflicting or overlapping permissions, default-deny vs. default-allow, the super-admin escape hatch, orphaned resources after a role is deleted. Every idea has a version of this branch — find it before round 1.

### 2. Flag architectural forks

Where the tree contains a genuine fork — RBAC vs. ABAC, roles-as-table vs. roles-as-enum, synchronous vs. event-driven enforcement — don't turn it straight into an open question. Apply `brainstorming`'s pattern narrowly: name 2-3 approaches, state the tradeoffs, lead with a recommendation. This is a scoped borrow, not the full brainstorming workflow end to end.

### 3. Interrogate via grilling's frontier mechanic

Follow `grilling`'s Process steps verbatim once the tree exists:

- Compute the frontier — every branch whose prerequisites are already settled
- Ask the whole frontier in one round, each question numbered with your own recommended answer attached
- Wait for the user's answers
- Recompute the frontier from scratch — an answered round often unblocks branches that weren't askable before
- Repeat until the frontier is empty

**The question count is a consequence of the tree's real size, never a target to hit.** A focused idea with 4-5 branches typically lands around 10-15 questions. A genuinely broad domain like RBAC or multi-tenancy can reach 20-30+, because it actually has that many independent decisions — not because more looks more thorough. A branch that wouldn't change either output if answered either way doesn't belong in the tree; cut it.

Before round 1, tell the user roughly how many branches the tree has and why, so the scope is visible upfront rather than a surprise mid-interview.

### 4. Hard confirmation gate

Once the frontier is empty, synthesize the full tree and its answers into a compact restatement — branch by branch, one line each. Require an explicit "yes" before producing either output. "Sounds good," "sure," and silence are not yes — same bar as `interview-me`'s Step 5. If the user corrects something, fold it in and restate again.

### 5. Output A — the Desired Prompt

Write 2-3 paragraphs that crystallize every locked-in decision into one instruction, in prose dense enough to hand off on its own — to a fresh session, or straight into `/spec`, `/feature-doc`, `/plan`, or `/build`. This is not a summary of the interview; it reads like a well-specified feature request from someone who already knew all the answers.

### 6. Output B — the detailed spec file

Structure:

```markdown
# Deep Dive: [Idea Name]

## Architectural Fit
[How this integrates with the codebase's existing patterns and separation of
concerns — which layer owns what, matching current conventions. Grounded in
step 1's exploration, not generic advice. Check decisions against
references/coding-patterns.md where relevant (boundaries around external
systems, decisions separated from actions, etc.).]

## [Branch Name]
**Decision:** [what was decided]
**Rationale:** [why]
**Alternatives Considered:** [if this branch was a fork — the options and why this one won]
**Edge Cases & Failure Modes:** [what could go wrong here, and how it's handled]
**Assumptions:** [anything taken as given without explicit confirmation]

... one section per branch ...

## Out of Scope
- [What this explicitly does not cover, and why]

## Open Questions
- [Anything genuinely unresolved — not a deferred edge case, an actual unknown]
```

Save to `deep-dives/<topic-slug>.md` under the project's external output location (see `references/external-output-paths.md`) — outside the project's own repo, never a path git in this project tracks or ignores. Create the directory if it doesn't exist. If a file for this topic already exists, ask whether to update it in place or start a new one (`<topic-slug>-2.md`). This is a distinct subpath from `specs/` and `features/` — this skill's output is upstream of `spec-driven-development` and `feature-doc`, not a replacement for either.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll ask fewer questions to save time" | A skipped branch becomes a silent gap in the prompt and spec — it surfaces as rework once implementation starts, at a much higher cost than answering it now. |
| "I can guess this from common RBAC/auth/etc. patterns" | Facts about *this* codebase are never guessed. If it's discoverable from the filesystem, dispatch a sub-agent instead of asking the user or assuming a convention. |
| "The tree feels done after one round" | Recompute the frontier from scratch every round — an answered round often unblocks branches that weren't askable before. Done means the frontier is empty, not that a round got answered. |
| "I should add a few more branches to seem thorough" | Padding degrades both outputs with noise the user has to read past. A branch earns its place only if answering it differently would change the prompt or spec. A smaller idea deserves a smaller tree. |
| "Edge cases can go in Open Questions instead of their own branch" | Open Questions is for genuinely unresolved items. A known edge case with a knowable answer belongs in its branch, decided like everything else — not deferred. |
| "The feature can live in its own new module, I'll skip checking existing patterns" | A spec that ignores the codebase's current separation of concerns produces something that gets re-architected on review. Step 1's exploration is mandatory, not optional context-gathering. |
| "I'll just save the spec into docs/ in the project, it's easier to find" | Both outputs go to the project's external output location (`references/external-output-paths.md`), never a path inside the project's repo — not even a gitignored one. Tell the user the full external path so it's still easy to find. |

## Red Flags

- Asking questions one at a time instead of batching the computable frontier
- Guessing a fact about the codebase instead of dispatching a sub-agent to look it up
- Treating an answered round as the end without recomputing the frontier
- Producing either output before the user has given an explicit "yes" to the restatement
- A branch that doesn't change either output regardless of how it's answered — a sign it was manufactured to inflate the count, not a real decision
- A spec with no Architectural Fit section, or no edge cases listed in any branch — a sign step 1's codebase exploration was skipped
- A genuine architectural fork asked as a plain question instead of framed with tradeoffs and a recommendation

## Verification

- [ ] The codebase was explored before any question was asked, including existing architectural patterns and separation of concerns
- [ ] The tree was mapped into branches before round 1, including a dedicated edge-cases branch
- [ ] Every round asked the full computable frontier, not one question at a time
- [ ] Every question carried the asker's own recommended answer
- [ ] Genuine architectural forks were framed with named approaches and tradeoffs, not bare questions
- [ ] The frontier was recomputed after every round of answers
- [ ] The user gave an explicit "yes" to the full restatement before either output was produced
- [ ] Output A (the Desired Prompt) is 2-3 paragraphs, self-contained, and usable without the interview transcript
- [ ] Output B (the spec file) has an Architectural Fit section grounded in real codebase conventions, and every branch lists its edge cases, rationale, and assumptions
- [ ] The spec was saved to `deep-dives/<topic-slug>.md` in the project's external output location (see `references/external-output-paths.md`), with the existing-file case handled if applicable

## Interaction with Other Skills

- **`grilling`** — this skill's questioning engine *is* grilling's frontier-batching mechanic, applied to a tree built from a bare idea instead of an existing plan. Once the tree exists, follow grilling's own Process steps rather than re-deriving them.
- **`brainstorming`** — borrowed narrowly, only for genuine architectural forks surfaced while mapping the tree, not the full brainstorming workflow end to end.
- **`interview-me`** — sibling for narrower asks. If the idea turns out to be one ambiguity rather than a whole domain, stop and hand off instead of forcing a tree onto it.
- **`idea-refine`** — sibling for pre-idea exploration. If the idea is too vague to even decompose into branches, hand off upstream first.
- **`spec-driven-development`**, **`feature-doc`**, **`planning-and-task-breakdown`** — downstream. The Desired Prompt or the spec file is a seed input to these, not a replacement for any of them.
