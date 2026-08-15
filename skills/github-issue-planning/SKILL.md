---
name: github-issue-planning
description: Turns a completed spec or feature plan into a GitHub Issues hierarchy (Epic → Feature → Story/Enabler → Task) with dependencies, priorities, and project-board columns, ready for automated issue creation. Use when the team tracks work in GitHub Issues/Projects and needs a feature broken into that specific artifact shape, rather than a generic agent task list.
---

# GitHub Issue Planning

## Overview

`planning-and-task-breakdown` turns a spec into a task list an agent executes directly. This skill turns the same kind of input into a different artifact: a GitHub Issues hierarchy — Epic, Feature, Story, Enabler, Task — with dependency links, priority/value labels, and project-board placement, sized for a human team working through GitHub Projects rather than an agent working through a session. Use this one when the deliverable is issues to create, not tasks to execute directly.

## When to Use

- The team tracks work in GitHub Issues/Projects and wants a feature broken into that hierarchy
- A completed PRD, technical breakdown, or implementation plan needs to become a set of linked, prioritized, estimated issues
- Setting up or populating a GitHub Project board (Kanban columns, custom fields) for a feature
- NOT when the immediate need is a task list for an agent to execute in this session — use `planning-and-task-breakdown` for that; the two produce different artifacts for different consumers

## Process

### 1. Confirm inputs exist

This skill turns finished planning artifacts into issues — it doesn't produce the plan itself. Confirm a PRD or spec, and ideally a technical breakdown, already exist (via `spec-driven-development` or `feature-doc`) before generating issues from them. Generating issues from an unclear or unwritten plan just produces unclear, unwritten issues with a GitHub Issues wrapper around them.

### 2. Build the work-item hierarchy

Map the plan onto five levels, each with a distinct job:

| Level | Scope | Example |
|---|---|---|
| **Epic** | A business capability spanning multiple features | "Checkout redesign" |
| **Feature** | One deliverable, user-facing piece of an epic | "Guest checkout" |
| **Story** | A user-focused requirement, independently valuable | "As a guest, I can check out without an account" |
| **Enabler** | Technical/infrastructure work with no direct user story of its own, but that stories depend on | "Add guest session table" |
| **Task** | Implementation-level breakdown of a story or enabler | "Add `guest_sessions` migration" |

Apply INVEST (Independent, Negotiable, Valuable, Estimable, Small, Testable) to every Story — if a story fails two or more of those, it's still an Epic or Feature in disguise and needs to be split further.

### 3. Write each issue against a fixed template

Every issue at every level needs, at minimum: a one-paragraph description, an acceptance-criteria checklist, its parent link (Feature → Epic, Story/Enabler → Feature, Task → Story/Enabler), an explicit **Blocks / Blocked by** dependency list, a size estimate, and a Definition of Done. Keep the fields identical across issues of the same level — a Story missing a field a sibling Story has is a sign it was rushed, not that the field didn't apply.

Size with story points for Story/Enabler/Task (Fibonacci: 1, 2, 3, 5, 8 — anything estimated 13+ is an Epic-sized chunk hiding inside a Story and needs breaking down), and t-shirt sizes (XS–XL) for Epic/Feature, where XL is itself a signal to split the Feature.

### 4. Make dependencies explicit, not implicit

For every issue, state what it **blocks** and what it's **blocked by** — not just "related to." A dependency graph that's only in your head disappears the moment the plan is handed to a team; written blocking relationships are what let a project board actually reflect the critical path.

### 5. Assign priority and value independently

Score every Feature/Story on two separate axes — priority (P0–P3: how urgent) and value (High/Medium/Low: how much it's worth) — rather than collapsing them into one number. A P0/Low item and a P2/High item are both real and get worked differently; conflating the axes loses that distinction.

### 6. Map onto the project board

Place each issue into the board's Kanban columns (typically Backlog → Sprint Ready → In Progress → In Review → Testing → Done) and set custom fields (Priority, Value, Component, Estimate, Sprint, Epic). If a repo automation already exists (a GitHub Action wiring PR events to column moves), reference it rather than re-describing it in every plan; if none exists yet, note that as a Definition-of-Done gap for the Enabler that sets up the board, not something to invent per-feature.

### 7. Produce the creation checklist

Output a checklist ordered Epic → Feature → Story/Enabler → Task, so issues get created in dependency order (a Story issue that links to a Feature issue that doesn't exist yet is a broken link). Include the labels each issue needs (`epic`/`feature`/`user-story`/`enabler`, plus priority and value labels) so issue creation — whether done by hand or via the GitHub CLI/API — is mechanical once the checklist exists.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll skip the Enabler level, it's all Stories" | Technical work with no direct user story (migrations, CI setup, infra) still needs tracking — burying it inside a Story's tasks hides it from prioritization. |
| "Dependencies are obvious from reading order" | They're obvious to you, right now. Write them as explicit Blocks/Blocked-by so they survive being read by someone else, or by you in three weeks. |
| "One priority number is simpler than two axes" | Priority and value answer different questions (urgency vs. worth) — collapsing them loses information a team needs to sequence work correctly. |
| "I can generate issues from a vague plan and refine later" | Vague plan in, vague issues out — the GitHub Issues wrapper doesn't add clarity that wasn't in the source plan. |

## Red Flags

- A Story with no acceptance criteria, or acceptance criteria that just repeats the title
- Dependencies described in prose ("this needs the schema first") instead of as explicit Blocks/Blocked-by links
- Every Story sized identically regardless of actual scope
- An Epic with no Features under it, or a Feature with no Stories — a hierarchy level skipped entirely
- Issues generated from a plan that was never actually written down (no PRD, no technical breakdown)
- A dependency chain that, once drawn out, reveals a cycle (A blocks B blocks A)

## Verification

- [ ] Every issue exists at the correct hierarchy level (Epic/Feature/Story/Enabler/Task), with a parent link
- [ ] Every Story passes INVEST, or has been split until it does
- [ ] Every issue states explicit Blocks/Blocked-by relationships, not prose dependencies
- [ ] Every issue has a size estimate and a Definition of Done
- [ ] Priority and value are scored independently, not collapsed into one field
- [ ] The creation checklist orders issues so no issue links to a not-yet-created parent

## See Also

- `spec-driven-development` / `feature-doc` — produce the PRD/spec this skill turns into issues; run first
- `planning-and-task-breakdown` — for a task list an agent executes directly in this session, rather than a GitHub Issues hierarchy for a team
- `ci-cd-and-automation` — for wiring the project-board automation (PR-to-column moves) this skill's Step 6 assumes may already exist
