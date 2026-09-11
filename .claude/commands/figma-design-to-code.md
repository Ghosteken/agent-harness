---
description: Implement a Figma frame, file, or selection as production code with pixel-exact fidelity
---

Invoke the agent-harness:figma-design-to-code skill.

Get the Figma link if one wasn't given, and confirm the specific frame or selection in scope — never a whole file when one screen was meant. If the Figma MCP server is connected, call its design-context tool for structured reference code, hints, design tokens, and the Code Connect mapping to the project's real existing components. Then always run a raw fidelity cross-check via the Figma REST API (see `references/figma-rest-api-reference.md`) — pull the complete node data for every node in scope and compare it against what the MCP pass surfaced, to catch anything rounded, defaulted, or omitted.

Export every image and icon at its exact size and use it as-is — never hand-draw an SVG, substitute a similar icon, or drop in a placeholder. Reuse the project's existing components and tokens wherever an equivalent already exists, and write the implementation in the project's actual stack, not a generic example snippet. Finish with a side-by-side comparison against the Figma screenshot to confirm spacing, typography, color, corner radius, shadows, and assets all match exactly — a visible mismatch is a defect to fix, not a rounding error to accept.
