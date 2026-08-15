---
name: teach
description: Runs a persistent, multi-session teaching workspace that tracks a learner's mission, learning records, and lessons for a topic outside of software engineering. Use when the user asks to be taught, tutored, or coached on an ongoing topic over multiple sessions — not a one-off explanation, and not an engineering skill covered elsewhere in this catalog.
---

# Teach

## Overview

A single explanation answers one question; teaching is a relationship that persists across sessions and needs somewhere to keep state. This skill treats the current directory as a teaching workspace: a mission statement grounding why the topic matters to this learner, a record of what they've already learned, and a sequence of short, focused lessons built to fit in working memory and tied back to the mission. Note: this repo's skill catalog is otherwise scoped to engineering workflows — this skill is the one deliberate exception, for a user who wants an ongoing tutor rather than an engineering collaborator.

## When to Use

- The user asks to be taught, tutored, or coached on a topic they intend to learn over multiple sessions, not answered once
- A teaching workspace already exists in the current directory (`MISSION.md`, `learning-records/`, etc. are present) and the user wants to continue it
- NOT for a single "explain X to me" question with no ongoing intent — just answer it
- NOT for teaching a software engineering topic already covered by this catalog (e.g. a framework, a testing pattern) — those are better served by the relevant engineering skill, which can cite official sources directly

## Process

### 1. Establish the workspace

Check for `MISSION.md`, `RESOURCES.md`, `NOTES.md`, `./learning-records/`, `./lessons/`, `./reference/`, and `./assets/` in the current directory. If they don't exist, this is a new workspace — before anything else, ask why the user wants to learn this topic and what they intend to do with it, and write the answer to `MISSION.md`. Every lesson that follows gets grounded against this mission; teaching without it produces lessons that feel abstract and unmoored from what the learner actually needs.

### 2. Separate knowledge, skill, and wisdom

Figure out which of the three this topic mostly needs:

- **Knowledge** — facts and concepts, best acquired from high-quality external sources. Never rely on parametric memory for this; track sources in `RESOURCES.md` and cite them in every lesson, since a lesson's trustworthiness comes from where its claims can be checked.
- **Skill** — durability and flexibility, built through effortful retrieval, not passive reading. A topic weighted toward skill (a physical practice, an interactive technique) needs practice loops, not more reading.
- **Wisdom** — only comes from real-world interaction outside the lesson. When a question needs this, answer what you can, but point toward a real community (forum, local group, class) rather than pretending a lesson can substitute for it. Respect it if the user doesn't want a community pointer.

### 3. Find the learner's zone of proximal development

Before writing a lesson, read the existing `./learning-records/` to see what's already been covered and what open questions remain, and check `MISSION.md` for what the learner is ultimately working toward. Pick the next lesson so it's challenged "just enough" — not a rehash of something already solid, and not several steps ahead of what's been built up. If the user names something specific they want to learn, teach that; otherwise infer the next right step from the records and the mission.

### 4. Write one lesson

A lesson is one self-contained, tightly-scoped file in `./lessons/`, teaching a single thing tied to the mission, short enough to complete quickly (working memory is small — one tangible win per lesson, not a survey). Cite a primary source for the topic — the highest-trust one found, not the first one — and end with an invitation to ask follow-up questions. Build from shared components in `./assets/` (a stylesheet, a quiz widget, a diagram helper) rather than one-off styling per lesson — reuse is the default, and a new reusable component belongs in `./assets/` the first time a second lesson would otherwise duplicate it.

For skill-acquisition lessons (not knowledge-acquisition ones), build in retrieval practice, spacing, and interleaving — desirable difficulty is what converts a fleeting sense of "I get it" into something that's still there next week. For knowledge-acquisition lessons, do the opposite: minimize incidental difficulty, since working-memory load is the enemy of first-pass understanding.

### 5. Capture reference material separately from lessons

If the topic produces reusable reference content (a glossary, a cheat sheet, a syntax reference, a routine), write it to `./reference/` — lessons are rarely revisited, but reference material is, so it should be the compressed, quick-lookup essence of what was taught, not a copy of the lesson prose. Once a glossary exists, stay consistent with its terms in every later lesson.

### 6. Log a learning record when something non-obvious lands

After a session where something worth remembering was learned or the mission itself shifted, write (or append) a numbered `./learning-records/000N-<name>.md` entry — the equivalent of an architecture decision record for the learner's own understanding. This is what lets a later session find the actual zone of proximal development instead of guessing from scratch. If the mission changes, update `MISSION.md` and log the change as a learning record — confirm the change with the user first.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I already know this topic, I don't need external sources" | Parametric knowledge goes stale and isn't checkable by the learner — track and cite real sources in `RESOURCES.md` regardless of how confident the recall feels. |
| "One long comprehensive lesson is more efficient" | Working memory is small; a lesson that tries to cover too much produces a shallow pass over all of it rather than a solid grasp of one thing. |
| "The user will remember this because it made sense in the moment" | That's fluency, not storage strength — desirable difficulty (retrieval, spacing, interleaving) is what makes it stick, and skipping it produces an illusion of mastery. |
| "I can skip the mission and just teach the topic" | Without a mission, there's no way to judge what the learner should do next or why a given lesson matters — establish it first, even briefly. |
| "I can answer this wisdom-type question definitively myself" | Wisdom comes from real-world practice, not a lesson. Answer what's reasonable, then point toward a real community unless the user has said they don't want one. |

## Red Flags

- A lesson written with no primary-source citation
- A lesson that doesn't tie back to anything in `MISSION.md`
- Skill-acquisition content taught the same way as knowledge-acquisition content (no retrieval practice, no spacing)
- A new lesson duplicating styling or components a previous lesson already built, instead of extracting a shared asset
- A learning record never written after a session that clearly changed the learner's understanding or the mission itself
- Treating a one-off "explain X" question as if it required standing up a whole teaching workspace

## Verification

- [ ] `MISSION.md` exists and reflects why the learner actually wants this topic, confirmed with them
- [ ] The lesson just produced is scoped to one tangible thing, cites a primary source, and is saved under `./lessons/`
- [ ] The lesson matches the learner's zone of proximal development, checked against `./learning-records/` before writing it
- [ ] Skill-acquisition lessons include a retrieval/practice loop; knowledge-acquisition lessons minimize incidental difficulty
- [ ] Reusable components were pulled from or added to `./assets/` rather than duplicated inline
- [ ] A learning record was written if the session surfaced something non-obvious or shifted the mission
