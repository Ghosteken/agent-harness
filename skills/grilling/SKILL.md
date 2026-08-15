---
name: grilling
description: Stress-tests a plan, architecture, or decision that already has multiple branching sub-decisions, by mapping it as a tree and interrogating a whole round of unblocked questions at once. Use when the user wants to pressure-test a design before committing to it, or explicitly says "grill me" about a plan. For a single underspecified ask rather than an existing multi-decision plan, use `interview-me` instead.
---

# Grilling

## Overview

Some asks are one ambiguous thing — `interview-me` handles those by asking one question at a time until a single intent is pinned down. Other asks arrive already shaped as a plan with a dozen sub-decisions hanging off each other: an architecture with a data model, an auth strategy, and a deployment target all still open. Interrogating that one question at a time is slow and myopic — by the time you reach question six, the user has forgotten the shape of questions one through five. This skill instead maps the whole thing as a **design tree** and interrogates it a full round at a time.

## When to Use

- The user wants their plan, architecture, or decision pressure-tested before they commit to it
- The user says "grill me" or asks you to stress-test a design with many moving parts
- A plan has multiple decisions that depend on each other, and getting them wrong compounds
- NOT for a single underspecified ask with no internal branching — use `interview-me`, which converges on one intent rather than mapping a tree
- NOT for reviewing a decision already made and shipped — use `doubt-driven-development` for adversarial review of a standing artifact; this skill is for a plan that hasn't been committed to yet

## Process

### 1. Map the design tree

Read the plan, decision, or idea the user brought, and lay out every decision it implies as a tree: each node is a decision, and its children are the decisions that only make sense once it's answered (an auth strategy decision has children like "session vs. token" only once "build vs. buy" is settled).

### 2. Compute the frontier

The **frontier** is every decision whose prerequisites are already settled — the ones answerable right now without guessing at something not yet asked. A question whose answer depends on another still-open question belongs to a later round, not this one.

### 3. Ask the whole frontier in one round

Number each question, and attach your own recommended answer to each:

```
❓ Q1 — <question title>
<question body — may run multiple paragraphs, may include multiple choices>
➡️ <your recommended answer>

❓ Q2 — <question title>
...
```

Ask the entire frontier together, not one at a time — unlike `interview-me`, where sequencing matters because later questions depend on earlier answers, a frontier round is exactly the set of questions that *don't* depend on each other yet, so batching them costs nothing and saves round-trips. Then wait for the user's answers before computing the next round.

**Facts are your job, never the user's.** When a frontier question needs something you could look up (a file, a config value, an existing convention in the codebase) rather than a judgment call, dispatch a sub-agent to find it instead of asking the user. Don't block the rest of the round on it — only the questions that genuinely depend on that lookup wait; ask everything else in the frontier now. The user only answers questions that are theirs to decide.

### 4. Recompute the frontier after each round

Each answer reshapes the tree: a settled decision pushes the frontier outward and unblocks whatever depended on it. Recompute from scratch — don't just append the next few questions you can think of — and ask the new frontier as the next round.

### 5. Stop when the frontier is empty

The session is done when every branch of the tree has been visited and nothing is left silently assumed. Do not act on the plan until the user has explicitly confirmed the shared understanding is complete — an empty frontier means you've asked everything, not that the user has signed off.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll ask these one at a time to be thorough" | One-at-a-time is `interview-me`'s job for a single ambiguous ask. For a branching plan, batching the frontier is faster and lets the user see how the decisions relate to each other. |
| "I can guess this fact instead of looking it up" | Facts are always your job. If it's discoverable from the filesystem or a tool, dispatch a sub-agent rather than asking the user or guessing. |
| "The user answered everything I asked, we're done" | Recompute the frontier — an answered round often unblocks new questions that weren't askable before. Done means the frontier is empty, not that a round got answered. |
| "I'll just proceed once the tree's fully asked" | An empty frontier means every question got asked, not that the user confirmed the resulting plan. Get explicit confirmation before acting on it. |

## Red Flags

- Asking questions one at a time when a decision tree with an already-computable frontier exists
- Asking the user something a file read or a tool call could have answered
- Treating an answered round as the end, without recomputing the frontier for newly-unblocked questions
- Proceeding to implement before the user has confirmed the shared understanding is complete
- A question in a round that depends on the answer to another question still open in that same round

## Verification

- [ ] The plan was mapped as a decision tree before any question was asked
- [ ] Each round asked the full computable frontier, not one question at a time
- [ ] Every question carried the asker's own recommended answer
- [ ] Facts were looked up via sub-agent dispatch rather than asked of the user
- [ ] The frontier was recomputed after every round of answers
- [ ] The session ended only once the frontier was empty and the user explicitly confirmed the shared understanding

## Interaction with Other Skills

- **`interview-me`**: sibling, not overlap. Use `interview-me` for a single underspecified ask with no internal branching; use this skill once the ask is already a plan with multiple interdependent decisions.
- **`doubt-driven-development`**: downstream in time. This skill pressure-tests a plan before commitment; doubt-driven-development adversarially reviews a decision already made. Both catch divergence, at different moments.
- **`planning-and-task-breakdown`**: typically downstream. Once the design tree is fully settled here, hand off to task breakdown to turn the confirmed plan into implementable units.
