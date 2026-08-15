---
name: excalidraw-diagramming
description: Generates a directly-editable .excalidraw diagram file (flowchart, sequence, ER, class, architecture, mind map, DFD, or swimlane) from a natural-language description, with hand-computed element positions since Excalidraw has no auto-layout. Use when asked to "create a diagram," "make a flowchart," or "generate an Excalidraw file" — as opposed to a Mermaid diagram embedded in a design doc, which `design-doc-diagramming` covers instead.
---

# Excalidraw Diagramming

## Overview

A Mermaid diagram is text that a renderer lays out; an Excalidraw diagram is a JSON list of shapes at explicit coordinates that you compute yourself. That's the entire difference in difficulty between this skill and `design-doc-diagramming` — the diagram-type selection logic is similar, but here there's no auto-layout backstop, so a diagram with overlapping elements or disconnected arrows is a bug you introduced, not a renderer quirk to work around. Use this skill when the deliverable is a standalone `.excalidraw` file someone opens and edits directly (a whiteboard-style artifact), not a diagram embedded in a Markdown design doc.

## When to Use

- Asked to "create a diagram," "make a flowchart," "visualize a process," "draw a system architecture," or "generate an Excalidraw file"
- The user wants a diagram they can open and directly rearrange in the Excalidraw app or website, not a text-based diagram embedded in a doc
- NOT for a diagram meant to live inside a project's Markdown design doc — use `design-doc-diagramming`, whose Mermaid output renders inline in almost every Markdown viewer without a separate app

## Process

### 1. Identify the diagram type

Match the request to one of: flowchart, relationship diagram, mind map, architecture diagram, data flow diagram, business flow/swimlane, class diagram, sequence diagram, or ER diagram. See `references/excalidraw-element-patterns.md` for the keyword-to-type mapping and the element conventions specific to each.

### 2. Extract the structured content before drawing anything

Pull out exactly what the diagram type needs — steps and decision points for a flowchart, entities and cardinalities for an ER diagram, actors and message order for a sequence diagram, and so on (each type's required inputs are listed in `references/excalidraw-element-patterns.md`). Extracting this first, as a plain list, catches missing information (an unlabeled relationship, an actor mentioned once but never given a lifeline) before it turns into a layout problem.

### 3. Lay out the elements on a grid

Compute `x`/`y`/`width`/`height` for every element before writing the JSON, snapped to a consistent grid step (20–40px), following the flow direction convention for that diagram type (top-to-bottom for a flowchart, left-to-right for a DFD, top-to-bottom for a sequence diagram's time axis). Don't place shapes ad hoc and adjust after the fact — compute the layout once, deliberately.

### 4. Build the element list

Use the type-specific shape/line/arrowhead conventions in `references/excalidraw-element-patterns.md` (a diamond for a flowchart decision, an open triangle arrowhead for inheritance in a class diagram, a filled diamond for composition, and so on — these notations carry meaning, and using the wrong one misrepresents the relationship). Every text element needs `fontFamily: 5`.

### 5. Check before delivering

Re-read the element list as if rendering it mentally: do any two elements overlap at their computed coordinates, does every arrow's `points` array actually reach the two shapes it's meant to connect, and is the flow direction consistent across the whole diagram? Fix these before handing the file over — they only become visible once someone opens it in the app, by which point the mistake is the user's problem to spot instead of yours to have caught.

### 6. Save and hand off

Save as a `.excalidraw` file and tell the user where it is and how to open it (the Excalidraw desktop/web app, or VS Code's Excalidraw extension if the project uses one). If the same shapes need to end up in a Markdown doc instead, that's a sign `design-doc-diagramming` was the right skill for this request — reconsider before completing the Excalidraw file.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll place shapes roughly and fix overlaps after" | There's no auto-layout to catch the mistake for you — compute the grid layout deliberately up front, once. |
| "Any arrowhead style is fine, it's just a line" | In a class diagram, an open triangle means inheritance and a filled diamond means composition — using the wrong one states the wrong relationship, not just a cosmetic slip. |
| "I don't need to extract the structured content, I can wing the JSON" | Diagram types have specific required inputs (cardinality for ER, message order for sequence) — skipping extraction is how a relationship or an actor gets silently dropped. |
| "This should really be a Mermaid diagram in the doc" | If so, stop and use `design-doc-diagramming` instead — don't force a Markdown-embedded diagram into a standalone Excalidraw file just because this skill was already invoked. |

## Red Flags

- Elements placed without computed coordinates, relying on eyeballing to avoid overlap
- An arrow whose `points` don't actually terminate at the two shapes it's meant to connect
- A class-diagram relationship drawn with the wrong line style or arrowhead for what it represents
- Inconsistent flow direction within a single diagram (top-to-bottom in one section, left-to-right in another, with no reason)
- Text elements missing `fontFamily: 5`
- Building an Excalidraw file for content that was actually meant to live inline in a Markdown doc

## Verification

- [ ] The diagram type matches the content, per `references/excalidraw-element-patterns.md`
- [ ] All required structured content (entities, steps, cardinalities, message order) was extracted before layout began
- [ ] Every element's position was computed on a grid, not placed ad hoc
- [ ] Relationship line styles and arrowheads match their semantic meaning (inheritance vs. composition vs. association, etc.)
- [ ] No overlapping elements or disconnected arrows in the final element list
- [ ] The file was saved as valid `.excalidraw` JSON with `fontFamily: 5` on every text element

## See Also

- `references/excalidraw-element-patterns.md` — diagram-type-to-element mapping, layout conventions, and per-type notation rules
- `design-doc-diagramming` — for a Mermaid diagram meant to live inline in a Markdown design doc, rather than a standalone editable file
