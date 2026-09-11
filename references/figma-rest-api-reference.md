# Figma REST API Reference

Companion to the `figma-design-to-code` skill: the raw-data fidelity cross-check path, used alongside (not instead of) the Figma MCP server.

## Auth

A personal access token, sent as the `X-Figma-Token` header (or an OAuth bearer token). Ask the user for a token if one isn't already configured as an environment variable — never invent one or reuse a token found elsewhere in the project.

## Resolving the file key and node-id from a link

A Figma URL looks like:

```
https://www.figma.com/design/<file-key>/<file-name>?node-id=<node-id>
```

- `<file-key>` — the file identifier, the path segment right after `/design/`.
- `node-id` query param — URL-encoded with a hyphen (`1234-5678`). Convert the hyphen to a colon (`1234:5678`) before using it in API calls.

## Key endpoints

| Endpoint | Purpose |
|---|---|
| `GET /v1/files/:key/nodes?ids=<node-id>` | Full raw node tree for specific node(s) — exact geometry, styles, effects, text properties. Use this for the fidelity cross-check pass. |
| `GET /v1/images/:key?ids=<node-id>&format=png\|svg&scale=<n>` | Rendered image export at a given scale — for re-verifying visual output, or exporting an asset the MCP pass didn't surface. |
| `GET /v1/files/:key/variables/local` | Local variables (design tokens) — cross-check against the MCP tool's variable-definitions output. |
| `GET /v1/files/:key/styles` | Published styles (color/text/effect styles) — relevant when the file uses styles instead of variables. |

## What to pull per node for a fidelity pass

- **Geometry** — `absoluteBoundingBox` (x/y/width/height), `paddingLeft/Right/Top/Bottom`, `itemSpacing` (auto-layout gap)
- **Fill/stroke** — the `fills`/`strokes` arrays: exact color (`r/g/b/a`), gradient stops, image fills
- **Corner radius** — `cornerRadius`, or per-corner `rectangleCornerRadii`
- **Effects** — the `effects` array: drop/inner shadows (offset, blur, spread, color), background blur
- **Opacity / blend mode** — `opacity`, `blendMode`
- **Text** — `style.fontFamily`, `fontWeight`, `fontSize`, `lineHeightPx`/`lineHeightPercent`, `letterSpacing`, `textAlignHorizontal`/`textAlignVertical`
- **Constraints** — `constraints.horizontal`/`constraints.vertical`, for resize/responsive behavior

## Rate limits

Same tier as MCP server access for Dev/Full seat users. Batch node-id lookups into one call (`ids=1:2,3:4,5:6`) rather than one request per node wherever possible.

## When this pass matters most

- Any single value from the MCP context looks rounded, defaulted, or suspiciously generic
- The node uses something the MCP hints didn't surface — an unusual blend mode, per-corner radius, or a style not exposed via variables
- A bulk or offline extraction across many frames, where an interactive MCP session isn't practical

This is a cross-check, not a replacement — the MCP server's Code Connect mapping and existing-component reuse guidance aren't something the raw REST data gives back for free. Use both together: MCP for what to build with, REST for confirming every value is exactly right.
