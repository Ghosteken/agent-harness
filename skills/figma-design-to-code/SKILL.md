---
name: figma-design-to-code
description: Implements a Figma frame, file, or selection as production code with pixel-exact fidelity — cross-referencing the Figma MCP server's structured design context against the Figma REST API's raw node data to capture every metric (position, size, spacing, colors, typography, corner radius, shadows, opacity, constraints) and every asset (images, icons, fonts) exactly as designed. Use when asked to "implement this Figma design", "build this screen from Figma", "turn this Figma link into code", or "port this Figma frame/selection".
---

# Figma Design to Code

## Overview

Converts a Figma design into real, production-ready code in the project's own stack — design to code only, never the reverse (that direction, generating or editing Figma files themselves, belongs to Figma's own design-authoring tools, not this repo). The defining constraint is fidelity: the output must match the Figma design exactly, not approximately. That means treating two data sources as complementary, not either/or — the Figma MCP server for structured context and codebase-aware mapping, and the Figma REST API for the complete, unsummarized node data that catches anything the MCP context simplified, rounded, or omitted.

## When to Use

- The user wants a Figma frame, file, or selection implemented, ported, or built as code
- Exact visual and structural fidelity to the source design is the goal, not a rough approximation
- NOT for generating or editing designs inside Figma itself — that's design-authoring tooling, out of scope for this repo
- NOT when the user only wants something "inspired by" a design rather than an exact reproduction — say so, and treat it as a lighter-weight frontend task instead of this skill's full fidelity process

## Process

### 1. Resolve the target

Get the Figma link (ask if one wasn't given) and confirm the specific frame or selection in scope — not an entire file when one screen was meant. Extract the file key and node-id from the link (see `references/figma-rest-api-reference.md` for the URL format). Also confirm whether prototype interactions/animations on that frame are in scope, or only static visual fidelity — extracting trigger events and transition curves for a purely static port is wasted effort. Scope creep here means outdated context and wasted extraction work.

After resolving, call `get_metadata` (or the REST API's node lookup) and state back what was actually resolved — node name, node-id, and node type — before extracting anything further. A link can point to the wrong frame, a stale one, or an ambiguous name shared by multiple nodes; catching that now is far cheaper than catching it after a full implementation pass. If there's any ambiguity (similar names, multiple candidates, an unclear link), stop and confirm with the user rather than picking the most-likely one.

### 2. Enumerate every variant and state

Before extracting styles, check whether the target is a component with multiple variants or states (e.g. a component set, or visibly different states like Expanded/Condensed/Collapsed). List all of them explicitly — via `get_metadata` on the component set or by inspecting the REST API's node children — and confirm which ones are actually in scope with the user rather than assuming "the first one I see" is the whole task. Implementing one variant and leaving the others unchecked until the user points it out is exactly the gap this step exists to close.

### 3. Primary extraction — Figma MCP

If the Figma MCP server is connected, call its design-context tool for the target node: structured reference code (adapt it to the project's real stack — never ship it verbatim), a screenshot, and hints. Pull design tokens/variables, and the Code Connect mapping from Figma components to the project's actual existing components. This pass gives you *what to build with* — the codebase-aware mapping raw data alone can't provide.

### 4. Fidelity cross-check — Figma REST API

Always run this pass too, not only when MCP is unavailable — it is a required part of the fidelity mandate, not a fallback. Call the REST API's node-detail endpoint for **every node in scope, individually — not a representative sample of the visually obvious ones.** A font-size or padding value that's wrong on three rows out of ten is exactly the kind of miss that spot-checking lets through. Read off the complete, raw values:

- **Geometry** — exact x/y/width/height, padding, and auto-layout gap
- **Fill/stroke** — exact colors (not a nearest-token guess), gradients, image fills
- **Corner radius** — including per-corner values
- **Effects** — shadows (offset, blur, spread, color), background blur
- **Opacity and blend mode**
- **Typography** — font family, weight, size, line-height, letter-spacing, alignment
- **Constraints** — how each node behaves on resize, for responsive fidelity

Cross-check every one of these against what the MCP context surfaced. A value that's rounded, defaulted, or missing from the MCP pass is exactly what this step exists to catch. See `references/figma-rest-api-reference.md` for the endpoints and exact fields, and `references/figma-to-css-property-mapping.md` for translating each of these categories to its correct CSS output rather than guessing.

When a fill, border, or shadow color is meant to come from a design token, match it by **exact value equality** against the token list from `get_variable_defs`/the REST variables endpoint — never by "this token looks about right." A nearest-looking token is still a wrong token.

### 5. Assets

Export every image and icon at its exact size, via the MCP tool's asset URLs or the REST API's image-export endpoint (matching the original format and scale) — and use the exported file as-is. Never hand-draw an SVG, substitute a similar icon from a library, or drop in a placeholder. A missing or inaccessible asset is a stop-and-ask, not a fill-in-and-continue.

This includes icons that look plausible but aren't the ones the design actually uses — a generic "collapse" chevron or a generic "getting started" icon standing in for the real exported asset is the same class of error as an approximated icon, even though it renders as *a* reasonable icon. Identify each icon by its actual node in the source file, export that exact node, and use it — never substitute from memory or general icon-library convention.

### 6. Reuse before generating

Audit the project's existing components, tokens, and design system before writing anything new. Apply hints in priority order: Code Connect mapping to a real component > component docs/annotations > design tokens > raw values. The goal is code that matches this codebase's real conventions, not a literal transcription of the Figma file's raw values into inline styles.

When a style choice looks like it could go either of two ways (e.g. a pill-shaped badge vs. plain text, a filled vs. outlined treatment), never guess the more-common or more-plausible-looking direction — check what the actual extracted node data says and go with that. A guess that happens to be wrong reads as confident, correct-looking code, which makes it harder to catch later, not easier.

### 7. Build in the project's real stack

Write the implementation in the project's actual framework and styling approach — never the MCP tool's example snippet verbatim, which targets a generic setup. If the project's conventions aren't already known, ground this in `acquire-codebase-knowledge` or prior exploration rather than guessing. For every property pulled in Step 4 — typography, dimensions, auto-layout, visual effects, variants/tokens, and (if in scope) prototype interactions/animations — apply `references/figma-to-css-property-mapping.md` so each one lands on its correct CSS/code output, not an approximation.

Add nothing that isn't sourced from the extracted node data — no decorative icon, border, background fill, or shadow that "would look nice" or "seems consistent with the rest." Every visual element in the output must trace back to a specific node or style property that was actually extracted. An invented addition is a fidelity defect exactly like a wrong value is, even when it looks tasteful.

### 8. Completeness check

Before moving to verification, diff the output's element list against the extracted node tree from Step 4, not just the styles within elements you already built: is every node from the source present in the output, and is everything in the output traceable to a source node? A dropped element (deleting something that was genuinely in the design because it looked redundant or unimportant) is exactly as much a fidelity defect as an added one — confirm with the user before omitting anything you're not certain about, rather than silently deciding it doesn't belong.

### 9. Verify fidelity

Compare the rendered result against the Figma screenshot/export, node by node: spacing, font sizes and weights, colors, corner radius, shadows, image assets, and responsive/constraint behavior. Also check rendered *layout behavior*, not just static values — a flex child without an explicit `flex-shrink: 0` (or an equivalent fixed-size rule) can compress below its intended height when siblings compete for space, even though every individual size value was extracted correctly. A visible mismatch is a defect to fix, not a rounding error to accept — that's the whole point of the fidelity mandate.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The MCP context already gave me the styles, I don't need the REST API pass" | MCP's context is intentionally simplified for codegen — the REST API's raw node data is the only place to catch a value it rounded, omitted, or collapsed. Skipping it is how a design drifts from "looks right" to "is wrong by a few pixels." |
| "I'll approximate this icon with something similar from an icon library" | The mandate is pixel-exact fidelity — an approximated asset is an immediate, visible mismatch. Export and use the real asset, or stop and ask. |
| "I can ship the MCP tool's example code as-is" | Its reference code targets a generic setup — this project's real stack, components, and tokens take priority. Treat it as reference, not a deliverable. |
| "One frame is basically the whole file, I'll just extract everything" | Confirm the specific frame or selection in scope before extracting — pulling an entire file when one frame was meant invites scope creep and stale context. |
| "Good enough is good enough here" | This skill exists specifically for exact reproduction. If the user only wanted something loosely inspired by the design, say so and use a lighter-weight frontend approach instead. |
| "This link probably points to the right frame, I'll just go with it" | State back the resolved node's name, id, and type before extracting anything — a stale or ambiguous link produces a confident, fully-wrong implementation that's far more expensive to catch after the fact. |
| "I checked the first state, that's probably representative" | A component with multiple variants or states needs every one enumerated and confirmed in scope up front — the second and third variant are not optional follow-ups triggered by the user noticing. |
| "This icon looks close enough to what's probably meant" | A plausible-looking substitute is still the wrong icon — identify and export the actual node, don't pattern-match from general icon-library convention. |
| "This extra touch makes it look more finished" | Nothing goes into the output that doesn't trace back to an extracted node or style property — an invented addition is a fidelity defect, not a nice-to-have. |
| "This element looks redundant, I'll leave it out" | An element that's genuinely in the source data stays, even if its purpose isn't obvious — confirm with the user before omitting anything, never decide unilaterally that something doesn't belong. |
| "This token is close enough to the extracted color" | Match design tokens by exact value equality, not visual similarity — a near-miss token is still the wrong token. |

## Red Flags

- The resolved node/frame was never stated back and confirmed — extraction started on a link taken at face value
- A component with multiple variants or states where only one was checked, and the others weren't enumerated up front
- A generated component that doesn't reuse an existing, equivalent component or token already in the project
- A hand-drawn SVG, or a plausible-but-wrong icon substituted for the design's actual icon, instead of the exported asset
- Font size/weight, spacing, or color values that don't match either data source exactly, especially when only some instances were checked and others were assumed consistent
- An added element, border, fill, or shadow that isn't traceable to a specific extracted node or style property
- An element present in the source node tree but missing from the output, removed without confirming with the user first
- A style choice (e.g. badge vs. plain text, filled vs. outlined) decided by guessing the more-plausible direction instead of checking the extracted data
- A design token selected by visual similarity rather than exact value match
- No REST API cross-check pass — only MCP's summarized context was used
- A raw value mapped to the wrong CSS property, or approximated instead of looked up in `references/figma-to-css-property-mapping.md`
- Layout that matches on static values but compresses or overflows at render time (e.g. a missing `flex-shrink: 0`)
- No final visual comparison against the Figma screenshot/export before calling the work done

## Verification

- [ ] The specific frame or selection in scope was confirmed before extraction, not assumed
- [ ] The resolved node's name, id, and type were stated back and confirmed before further extraction
- [ ] Every variant or state of the target component was enumerated and its scope confirmed, not just the first one encountered
- [ ] The MCP design-context tool was called for structure, hints, and Code Connect mapping (when the MCP server is connected)
- [ ] The REST API's raw node data was cross-checked against the MCP context for every node in scope individually — not a representative sample
- [ ] Every image/icon is the exact exported asset at the correct size — none hand-drawn, substituted, or pattern-matched from general convention
- [ ] Every design-token-backed color/border/shadow was matched by exact value, not visual similarity
- [ ] Existing components/tokens were reused wherever an equivalent already exists in the project
- [ ] Any ambiguous style choice was resolved by checking the extracted data, not by guessing the more-plausible direction
- [ ] Generated code targets the project's actual stack, not a generic example snippet
- [ ] Every extracted property (typography, dimensions, auto-layout, visual effects, variants/tokens) was mapped per `references/figma-to-css-property-mapping.md`, not approximated
- [ ] The output's element list was diffed against the source node tree — nothing added that isn't traceable to a source node, nothing dropped without user confirmation
- [ ] Rendered layout behavior (not just static values) was checked for compression/overflow issues
- [ ] A final side-by-side comparison against the Figma screenshot confirms spacing, typography, color, radius, shadows, and assets match exactly

## See Also

- `references/figma-rest-api-reference.md` — REST API endpoints, auth, and how to extract a file key/node-id from a Figma link
- `references/figma-to-css-property-mapping.md` — translating each extracted Figma property to its correct CSS (or equivalent styling-system) output
- `frontend-ui-engineering` — component architecture and design-system conventions this skill's output should match
- `react-best-practices` — if the target stack is React, for hooks/composition conventions to follow while implementing
- `api-and-interface-design` — if the ported screen also needs new backend contracts
- `acquire-codebase-knowledge` — ground the "reuse before generating" step in the project's real conventions if they aren't already known
