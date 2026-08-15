# Excalidraw Element Patterns

Reference material for the `excalidraw-diagramming` skill: how to translate each
diagram type into `.excalidraw` JSON elements, since — unlike Mermaid — there's
no text DSL doing layout for you. Every box, arrow, and label is a positioned
element you compute directly.

## File skeleton

```json
{
  "type": "excalidraw",
  "version": 2,
  "source": "https://excalidraw.com",
  "elements": [],
  "appState": { "viewBackgroundColor": "#ffffff", "gridSize": 20 },
  "files": {}
}
```

Every text element needs `fontFamily: 5` (Excalifont) so labels read consistently
once opened in the Excalidraw app rather than falling back to a mismatched default.

## Element types available

`rectangle`, `ellipse`, `diamond` (for decision points), `arrow` (directional
connections, needs a `points` array), `text` (labels — usually paired with a
shape rather than floating alone).

## Layout discipline

Compute `x`/`y`/`width`/`height` for every element up front, on a grid (steps
of 20–40px) — don't place elements ad hoc and hope they don't overlap. A
consistent left-to-right or top-to-bottom flow direction per diagram type
(see below) keeps the result readable without a human rearranging it after
the fact.

## Per-type conventions

**Flowchart** — `rectangle` for steps, `diamond` for decisions, `ellipse` for
start/end. Flow top-to-bottom or left-to-right, consistently within one
diagram. Label decision-branch arrows with the condition ("yes"/"no",
"valid"/"invalid").

**Relationship diagram** — `rectangle` (or `ellipse` for a softer node) per
entity, `arrow` per relationship with a text label describing the relationship
verb. Group tightly-related entities spatially even without an explicit
container, so proximity itself signals relatedness.

**Mind map** — one central node, 3–6 main branches radiating from it, optional
sub-topics per branch. Keep the branch count in that range — more than 6
primary branches from one center stops reading as a hierarchy.

**Architecture diagram** — group nodes into visually bounded regions (a large
background rectangle behind a cluster of component rectangles) to represent
subsystem boundaries, since Excalidraw has no native subgraph primitive the
way Mermaid does.

**Data flow diagram (DFD)** — external entities as rectangles, processes as
circles/ellipses, data stores as open-ended rectangles, arrows for data flow
only. Flow left-to-right or top-left to bottom-right. This diagram shows data
movement, not execution order — don't number the arrows as if they were steps.

**Business flow / swimlane** — actor names as a header row of text elements,
one vertical lane (a tall thin rectangle or just consistent x-alignment) per
actor below its header, process boxes placed inside the owning actor's lane,
arrows crossing lanes for handoffs between actors.

**Class diagram** — `rectangle` per class, subdivided internally by an inner
horizontal line into name / attributes / methods, using `+`/`-`/`#` prefixes
for public/private/protected. Relationship lines: inheritance (solid line,
open/white triangle arrowhead), implementation (dashed line, open triangle),
association (solid line, no special arrowhead), dependency (dashed line, open
arrowhead), aggregation (solid line, open diamond at the owner end),
composition (solid line, filled diamond at the owner end). Add multiplicity
labels (`1`, `0..1`, `1..*`, `*`) near each line's endpoints.

**Sequence diagram** — actor/object names as text elements across the top,
one vertical lifeline (a thin long rectangle or line) per actor below its
name, horizontal arrows between lifelines for messages, time flowing
top-to-bottom. Solid arrow for a synchronous call, dashed arrow for
asynchronous or for a return value. A short rectangle overlaid on a lifeline
during a call marks that object's activation period.

**ER diagram** — `rectangle` per entity, with attribute names listed inside
(underline or a `PK`/`FK` suffix to mark keys), lines between entities for
relationships labeled with cardinality (`1:1`, `1:N`, `N:M`). For an `N:M`
relationship, add a small dashed junction rectangle between the two entities
rather than drawing a direct many-to-many line.

## Before delivering

Re-open the element list mentally as a rendered picture: does anything
overlap at the computed coordinates, does every arrow's `points` array
actually terminate near the two shapes it's meant to connect, and does the
flow direction stay consistent across the whole diagram? A `.excalidraw` file
with overlapping or disconnected elements only reveals the problem once
someone opens it in the app — catch it before handing it over.
