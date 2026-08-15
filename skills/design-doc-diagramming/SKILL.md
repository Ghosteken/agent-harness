---
name: design-doc-diagramming
description: Chooses the right Mermaid diagram type for the content, drafts and validates it, and assembles it into a design document. Use when asked to create or update an architecture/API/feature/database/system design doc, to "create a diagram" or "generate mermaid" for a codebase or design, or to convert existing code/config into an architecture or deployment diagram.
---

# Design Doc Diagramming

## Overview

A design doc earns its keep when a diagram answers a question faster than the prose around it would. This skill covers the part that's easy to get wrong: picking the diagram type that actually matches the content (a flowchart forced to represent a request/response sequence loses the ordering that made it worth drawing), drafting it small enough to stay legible, validating it before it ships, and slotting it into a document structure appropriate to what's being designed.

For the prose sections of a design doc (goals, non-goals, alternatives considered, rollout plan), defer to `feature-doc`, `spec-driven-development`, or `documentation-and-adrs` — this skill owns diagram selection and quality, not general doc-writing conventions.

## When to Use

- Asked to create or update an architecture, API, feature, database, or full-system design document
- Asked to "create a diagram," "generate mermaid," "document the architecture," or "show the flow" for a system, feature, or codebase
- Asked to convert existing code, config, or infrastructure-as-code into an architecture or deployment diagram
- A design doc already exists but its diagrams are stale relative to the code
- NOT for a single ad-hoc diagram inside a Claude Artifact — use `artifact-diagramming` there, since it covers Artifact-specific rendering constraints this skill doesn't
- NOT for a standalone, directly-editable diagram file — use `excalidraw-diagramming` when the deliverable is a `.excalidraw` file rather than Mermaid embedded in a doc

## Process

### 1. Identify what's being documented

Match the request to a document shape before drafting anything:

| Document type | Center of gravity | Diagrams it usually needs |
|---|---|---|
| Architecture | Components and their dependencies | Component graph, deployment |
| API | Request/response contracts | Sequence, occasionally ER for payload shapes |
| Feature | User-facing flow and decision points | Flowchart/activity, sequence for backend calls |
| Database | Schema and relationships | ER diagram |
| System | All of the above, at lower resolution each | Component graph as the anchor, with sequence/ER call-outs per subsystem |

A doc doesn't need every diagram type available to it — one clear diagram beats three redundant ones. If the request doesn't specify a document type, ask, or infer it from what's already open in the conversation (a PR touching a schema migration implies Database, not Architecture).

### 2. Pick the diagram type per section

For each section that needs a visual, use `references/mermaid-diagram-patterns.md` to match the content shape (workflow, interaction-over-time, entity relationships, component dependencies, state transitions) to the corresponding Mermaid diagram type and syntax skeleton. Don't default to `flowchart` because it's the most familiar — a sequence diagram that shows message ordering, or an ER diagram that shows cardinality, often carries information a flowchart of the same content would lose.

If the content comes from existing code or config rather than a description — a Spring/FastAPI/Express app, a Terraform/K8s manifest, an OpenAPI spec — read the actual source before drafting: component boundaries from module/package structure, deployment topology from the infra config, sequence from the call chain of the endpoint in question. A diagram invented from the request's prose alone, when the source is available, is a diagram that will drift from the code on the first review.

### 3. Draft, then check it against the source

Write the diagram in a fenced ```mermaid block. Keep it to the node-count and contrast guidance in `references/mermaid-diagram-patterns.md` — split an overloaded diagram into an overview plus focused sub-diagrams rather than cramming everything into one. After drafting, re-read the diagram against whatever it's meant to represent (the described flow, the actual source file) and check for the failure mode that's easy to miss: a label copied from an earlier node, an edge direction that's backwards, a state that's unreachable in the real code.

### 4. Validate before embedding

If `mermaid-cli` (`mmdc`) is available in the project, validate syntax with it (see `references/mermaid-diagram-patterns.md` for the command) before embedding the diagram in the document. If it isn't available, at minimum re-read the diagram source for unbalanced brackets, unclosed subgraphs, and reserved words used as node IDs — the most common syntax breaks. A diagram that fails to render shows up as a raw code fence to anyone whose Markdown viewer doesn't support Mermaid, which defeats the point of having drawn it.

### 5. Assemble and place the document

Follow the target document type's conventions from `feature-doc` / `documentation-and-adrs` for the surrounding prose structure. Save the document where the project already keeps design docs (check for an existing `docs/design/`, `docs/adr/`, or similar directory before inventing a new location) and match its existing naming pattern.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "A flowchart can show anything, I'll just use that" | A flowchart loses ordering and cardinality information that a sequence or ER diagram would have preserved — pick the type that matches the content, not the one you're most fluent in. |
| "I described the flow in the prompt, that's enough to draw from" | If the actual source (code, config, spec) is available, read it — a diagram drawn only from the request's description drifts from the real system on the first review. |
| "It looks right, I don't need to validate the syntax" | A single unbalanced bracket or unclosed subgraph renders as a broken code fence in front of whoever reads the doc next — validate or re-read before shipping. |
| "One big diagram is more thorough than several small ones" | Past ~12-15 nodes a diagram stops communicating and starts requiring its own legend — split it. |
| "Color coding makes the states clear" | Not for a colorblind viewer, a grayscale printout, or dark-mode rendering — pair color with a label or shape, never color alone. |

## Red Flags

- A diagram type chosen because it's familiar, not because it fits the content (e.g., a flowchart standing in for a sequence)
- A diagram drawn from prose description when the actual source file was available and unread
- No validation step before the diagram is embedded in the document
- A single diagram with more nodes than a reader could hold in their head at once
- Meaning encoded only in color, with no label or shape backing it up
- A design doc saved to a new, invented location when the project already had a design-doc directory

## Verification

- [ ] The diagram type for each section matches the content shape (checked against `references/mermaid-diagram-patterns.md`)
- [ ] Diagrams drawn from existing code/config were checked against that source, not just the request's prose
- [ ] Each diagram stays under the node-count guidance, or is split into overview + sub-diagrams
- [ ] Diagram syntax was validated (via `mmdc` or a careful manual re-read) before embedding
- [ ] The document was saved to the project's existing design-doc location and naming convention, if one exists

## See Also

- `references/mermaid-diagram-patterns.md` — diagram type selection, syntax skeletons, accessibility rules
- `feature-doc` — the prose structure for a pre-implementation feature doc
- `documentation-and-adrs` — architecture decision record conventions
- `spec-driven-development` — writing the specification a design doc often accompanies
- `artifact-diagramming` — for a single diagram rendered inside a Claude Artifact, not a project design doc
- `excalidraw-diagramming` — for a standalone, directly-editable `.excalidraw` file rather than a Mermaid diagram embedded in the doc
