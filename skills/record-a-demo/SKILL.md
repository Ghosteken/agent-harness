---
name: record-a-demo
description: Records a polished, human-paced video walkthrough of a finished, already-QA'd feature via Playwright's screencast API — for stakeholder review, sign-off, or sharing. This is a presentation artifact, not a testing pass. Use when asked to demo, walk through, or record a video of finished work — never for a feature that hasn't already passed verification.
---

# Record a Demo

## Overview

Produces a `.webm` video of working software for people to watch and sign off on — not a QA artifact. The premise going in is that the feature already works and was already verified (via `quality-assurance` or `playwright-e2e-testing`); this skill's only job is to show it working, at a natural pace, with clear visual annotation of what's happening. It does not hunt bugs, narrate a checklist, or produce a verdict.

## When to Use

- Asked to demo, walk through, or record finished work end-to-end
- Presenting a feature to stakeholders for review or sign-off
- Sharing a completed flow with colleagues
- NOT when the feature hasn't been verified yet — run `quality-assurance` (or check `playwright-e2e-testing` coverage) first; this skill assumes correctness, it doesn't establish it
- NOT for a testing artifact of any kind — a demo that surfaces a real regression is a stop-and-report situation (see Step 5), not a bug-hunting session

## Process

### 1. Resolve what to demo

In priority order: explicit instructions for specific flows, a named source (test plan, spec, curated scenario list) to extract scenarios from, or — if asked to demo "what you just worked on" — the feature context from the current session.

### 2. Draft and confirm a short outline

Write a 3-6 step outline and confirm it with the user before recording anything. This is the one checkpoint in the whole process — cheap insurance the demo matches intent, and the reason not to need further check-ins once it's approved.

### 3. Rehearse the flow before recording it

Drive the actual flow once, live, before writing any recording script: confirm the entry URL, auth steps, and exact locators; identify dynamic/async content and what it actually needs to wait on; note working selectors and element positions for later label placement. Recording a flow you haven't actually driven yet is how a demo ends up narrating a wait condition that doesn't hold or a locator that doesn't resolve.

### 4. Record

Prefer Playwright's built-in action annotation over hand-rolled cursor code: `page.screencast.start({ path, size })`, then `screencast.showActions({ cursor: 'pointer' })` for automatic cursor/click visualization during the recording. Reach for a custom synthetic-cursor script (DOM cursor injected via `page.addInitScript`, driven by a `glide()`/`show()` helper — see `patterns.md`) only when the built-in annotation doesn't give the visual result the outline calls for (e.g. precise custom label placement tied to element bounding boxes).

Either way:
- Load and let the entry screen fully settle **before** calling `screencast.start()` — starting on a half-painted page means the recording opens fighting its own load state
- Put visible motion on screen within the first ~300-500ms after `start()` — a rendered-but-motionless opening frame reads as a frozen screenshot to a viewer, which is the single most common way a demo opens poorly
- Type with `pressSequentially({ delay: ~60 })` when the typing itself is part of what's being shown; use `fill` when it isn't — cranking the delay higher doesn't read as more "human," it just reads as slow
- Target ~800-1200ms between ordinary steps, ~1500-2500ms at key beats, so a viewer has time to actually absorb the new screen
- Annotate sparingly with small, colorful, contextual labels (`showOverlay`) positioned at the actual target's bounding box — never full-page cards (`showChapter`) mid-flow, which hard-interrupt the sense of motion; reserve `showChapter` for a title card on a cold open at most
- Encode state in label color where a lifecycle applies — neutral/in-progress vs. a success color (e.g. green with a checkmark) on completion is the highest-leverage single annotation, especially for anything that streams (see below)

For a throwaway/rough clip where sign-off isn't the goal, driving the flow live with recording on (no authored script) is an acceptable lighter alternative — just don't deliver that version for sign-off.

### 5. Handle streaming or long-running UI correctly

An SSE/WebSocket-driven UI (streaming chat replies, a live agent loop) needs to record in full — showing the complete response is the point, not a truncated stand-in. Two specific traps:

- **Never gate on network-idle.** A live streaming connection stays open, so `waitForLoadState('networkidle')` (or `waitUntil: 'networkidle'`) blocks until it times out — it will never arrive on its own.
- **Advance on a real completion signal, not a fixed sleep.** Poll for the actual DOM signal that the stream finished (e.g. the response container's text length holding steady across consecutive polls, past its pre-send size) with a generously-sized timeout for a long generation — not a guessed fixed delay, and not a "send button re-enabled" check (it may not reflect stream state reliably).

### 6. Verify before delivering — you can't casually watch a webm

Review the key-beat screenshots captured along the way: cursor/annotation visible where expected, each beat actually reached the expected state, no error screens or incomplete loads. If something's visually wrong, re-record — never deliver a take you haven't confirmed. If you need to inspect the actual video content beyond what beat screenshots capture, use the Playwright-bundled ffmpeg (ships alongside the browser binaries; locate it rather than assuming a fixed path, since it differs by OS/environment) to pull a specific frame to a PNG rather than trying to "watch" the file.

### 7. Handle a failed take correctly

A flaky, transient failure (a missed wait, a stale locator, bad timing) is a recording problem — silently re-record. A real regression (the feature is actually broken) is a stop-immediately situation: report exactly what failed, and do not deliver a video that misrepresents broken work as working. This skill never fixes the implementation itself — that's a hand-off, not this skill's job.

### 8. Deliver

Save the final `.webm` (plus its key-beat screenshots) to `demos/<feature-slug>/` under the project's external output location (see `references/external-output-paths.md`) — outside the project's own repo. Tell the user the full path(s), which scenarios were demoed, and that it's ready for sign-off or change requests — not a verdict.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I found a bug, let me note it in the video" | This skill assumes the feature already passed QA — a real regression found here is a stop-and-report situation, not something to narrate into the recording. Run `quality-assurance` first if that assumption doesn't actually hold. |
| "I'll skip the rehearsal, I already know this flow" | An unrehearsed recording script is exactly how a demo ends up narrating a wait condition that doesn't hold — rehearse live before scripting, every time. |
| "A frozen half-second at the open is fine, it's brief" | It's the single most common way a demo reads as broken before anything's even happened — lead with visible motion, not a settled static frame. |
| "I'll wait for network-idle so the streaming reply is fully done before continuing" | A live stream keeps the connection open — network-idle never arrives, and the wait times out. Poll for an actual completion signal instead. |
| "More typing delay looks more human" | Natural pacing comes from deliberate pauses between actions, not slower typing — a higher `pressSequentially` delay just reads as sluggish. |
| "I'll hand-roll a synthetic cursor, that's how it's always done" | Playwright's `screencast.showActions({ cursor: 'pointer' })` already provides this built in — reach for a custom cursor script only when the built-in doesn't give the specific visual the outline needs. |
| "One big full-page overlay explains the whole step" | `showChapter` hard-interrupts the sense of motion — small contextual `showOverlay` labels at the actual target keep the flow feeling live. |

## Red Flags

- A demo recorded for a feature that hasn't actually passed `quality-assurance` (or equivalent) yet
- A real regression narrated into the video instead of triggering a stop-and-report
- A recording script written without first rehearsing the flow live
- `screencast.start()` called before the entry screen has settled, or with no motion in the first ~300-500ms after
- `waitForLoadState('networkidle')` (or equivalent) used to gate a streaming/long-lived-connection UI
- A fixed sleep used to "wait out" a stream instead of polling a real completion signal
- `showChapter` used mid-flow as a repeated interruption instead of only at a cold open
- A take delivered without reviewing its key-beat screenshots first
- Output saved as anything other than `.webm`, or saved inside the project's own repo instead of the external output location

## Verification

- [ ] The feature was already verified (QA'd) before this skill started — this skill didn't establish correctness itself
- [ ] A 3-6 step outline was drafted and confirmed with the user before recording
- [ ] The flow was rehearsed live before any recording script was written
- [ ] The recording opens with visible motion in the first ~300-500ms, not a settled static frame
- [ ] Any streaming/long-lived-connection UI advanced on a real completion signal, never on network-idle or a fixed sleep
- [ ] Annotations are small and contextual (`showOverlay`), with `showChapter` reserved for a cold-open title card at most
- [ ] Key-beat screenshots were reviewed and confirmed correct before delivery — no take shipped unverified
- [ ] Any failed take was correctly classified (re-recorded if flaky, reported and stopped if a real regression) — never papered over
- [ ] Final `.webm` and key-beat screenshots saved to `demos/<feature-slug>/` in the project's external output location (see `references/external-output-paths.md`)
- [ ] The user was told the full path(s) and that it's for sign-off, not a verdict

## See Also

- `quality-assurance` — establishes the correctness this skill assumes; run it first if the feature hasn't actually been verified
- `playwright-e2e-testing` — a persistent, CI-run regression suite; a different artifact and audience than a one-off demo video
- `browser-testing-with-devtools` / `playwright-skill` — live verification/automation, not video production
- `patterns.md` — the fallback synthetic-cursor script, overlay styling reference, and ffmpeg frame-extraction commands
- `references/external-output-paths.md` — where this skill's output lives
