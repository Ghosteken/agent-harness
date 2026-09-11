# Figma → CSS Property Mapping

Companion to the `figma-design-to-code` skill: once a node's raw values are pulled (via the Figma MCP server's context or the REST API's raw node data — see `references/figma-rest-api-reference.md`), this is the lookup for translating each Figma property into the correct CSS (or equivalent styling-system) output. Treat every row as a required translation, not an optional nicety — a value extracted correctly but mapped to the wrong property is still a fidelity miss.

## Typography

| Figma property | CSS output |
|---|---|
| Font family | `font-family` |
| Font size | `font-size` (px or rem, matching the project's existing unit convention) |
| Font weight | `font-weight` (numeric — 400 Regular, 700 Bold, etc., not the style-name string) |
| Line height | `line-height` (px value or unitless ratio, matching how Figma expressed it — `lineHeightPx` vs `lineHeightPercent`) |
| Letter spacing | `letter-spacing` (convert Figma's value to `em` or `px` consistently with the project) |
| Text align (horizontal) | `text-align` (`left` / `center` / `right` / `justify`) |
| Text align (vertical) | Flexbox alignment (`align-items`) or padding on the text container — CSS has no direct vertical text-align equivalent |
| Text case | `text-transform` (`uppercase` / `lowercase` / `capitalize`) |
| Text decoration | `text-decoration` (`underline` / `line-through`) |
| Paragraph spacing | `margin-bottom` on the text block |
| Paragraph indent | `text-indent` |

## Dimensions & Sizing

| Figma property | CSS output |
|---|---|
| Width | `width` or `max-width`, depending on the resizing rule below |
| Height | `height` or `min-height`, depending on the resizing rule below |
| Constraints | Sizing rules such as `width: 100%`, `flex-grow`, or absolute-position anchors, depending on the constraint direction |
| Resizing rule: hug contents | Auto sizing — omit a fixed width/height, let content determine size |
| Resizing rule: fill container | `width: 100%` (or `flex: 1` inside a flex parent) |

## Layout & Spacing (Auto Layout)

| Figma property | CSS output |
|---|---|
| Direction | `flex-direction` (`row` for horizontal auto layout, `column` for vertical) |
| Gap / item spacing | `gap` |
| Padding (horizontal/vertical/per-side) | `padding` — use the shorthand only when all sides match, per-side properties otherwise |
| Alignment | `justify-content` and `align-items` (e.g. center, space-between) |
| Absolute position | `position: absolute` with the appropriate combination of `top`/`bottom`/`left`/`right` |

## Visual Styles & Effects

| Figma property | CSS output |
|---|---|
| Fill (solid color) | `background-color`, or `color` when the fill is on text |
| Fill (gradient) | `background: linear-gradient(...)` (or the matching gradient function for the gradient type) |
| Opacity | `opacity` (0–1) |
| Stroke / border | `border-width`, `border-style`, `border-color` |
| Stroke alignment | Not a direct CSS property — inside/outside/center alignment changes the *box sizing* the border implies; account for it when converting Figma's width/height into CSS dimensions, don't just apply the border on top |
| Corner radius | `border-radius` — uniform value, or four values when Figma specifies per-corner radii |
| Drop shadow | `box-shadow` (x-offset, y-offset, blur, spread, color) |
| Inner shadow | `box-shadow` with the `inset` keyword |
| Layer blur | `filter: blur(...)` |
| Background blur | `backdrop-filter: blur(...)` |

## Structure & Organization

| Figma property | CSS/code output |
|---|---|
| Component variants | State/props in the project's component model — React props, a state variable, or CSS class modifiers (e.g. `btn--primary`, `is-active`) — match however this codebase already expresses variants, don't invent a new pattern |
| Variables / design tokens | CSS custom properties or the project's token system (e.g. a Tailwind config key) — reuse an existing token before hardcoding the raw value |
| Export settings | Determines the asset's format and resolution (`.svg`, `.png`, `.jpg` at the specified scale) when exporting images/icons |

## Advanced Typography & Layout

| Figma property | CSS output |
|---|---|
| Text truncation / max lines | `-webkit-line-clamp` combined with `overflow: hidden` and `text-overflow: ellipsis` (plus `display: -webkit-box` and `-webkit-box-orient: vertical`, which `-webkit-line-clamp` requires to take effect) |
| Min/max width and height | `min-width`, `max-width`, `min-height`, `max-height` — don't collapse these into a single `width`/`height` if Figma specifies a constraint range rather than a fixed value |
| Wrap (auto layout) | `flex-wrap: wrap` |
| Baseline alignment | `align-items: baseline` on the flex container |
| Stroke cap / join (vector paths) | `stroke-linecap` and `stroke-linejoin` in SVG output, or the equivalent Canvas context properties if the path is rendered to canvas rather than SVG |

## Interaction & Animation (Prototyping)

Only relevant when the source frame's prototype interactions are actually part of what's being ported — confirm that's in scope before spending effort extracting them; a static-fidelity request doesn't need this section.

| Figma prototype property | Code output |
|---|---|
| Trigger event | The matching event handler in the target framework — "On click" → a click handler, "While hovering" → paired enter/leave handlers, etc. Use the framework's real event names, not a generic placeholder. |
| Transition curve (Smart Animate / easing) | `transition-timing-function` or `animation-timing-function` — a named easing (`ease-in-out`) or an explicit `cubic-bezier(...)` when Figma's curve doesn't map to a named one |
| Transition duration | `transition-duration` (or `animation-duration`), converted from Figma's duration setting |
| Overlay open/close | Modal or overlay logic in the project's existing pattern for that (a modal component, a portal, absolute/fixed centering) — reuse whatever the codebase already has for overlays rather than building a one-off |

## Component Logic & Visibility

| Figma property | Code output |
|---|---|
| Boolean visibility property | Conditional rendering in the target framework (e.g. `{showIcon && <Icon />}`) rather than a hidden-but-present element |
| Nested instance-swap property | A child component passed as a prop or slot, not a hardcoded nested component |
| Text property bound to a string | Interpolated from the corresponding prop/variable (e.g. `` {props.label} `` ), not a hardcoded string copied from the Figma content |

## Variables & Modes (Advanced Tokens)

| Figma property | Code output |
|---|---|
| Variable modes (e.g. light/dark) | A theming mechanism the project already has — a theme provider, a root class toggle (`.dark-theme`) that swaps CSS custom-property values, or an equivalent data-context switch. Don't invent a new theming approach if one already exists. |
| Number/string/color variables | The project's token structure — a JSON token map, a Tailwind config key, or CSS custom properties, matching whatever the codebase already uses for tokens |

## How this fits into the skill's process

- **Step 3 (fidelity cross-check)** pulls the raw values this table's left column names — this table is what tells you where each one goes.
- **Step 5 (reuse before generating)** still takes priority over this table for anything the project already has a token, component variant, or class for — this mapping is for translating a *raw* value, not for bypassing an existing convention.
- **Step 6 (build in the project's real stack)** is where the mapping is actually applied — verify every property in this table was considered for every node in scope before calling a section done, not just the ones that were visually obvious.
