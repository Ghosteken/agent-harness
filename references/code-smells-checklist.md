# Code Smells Checklist

Reference material for the Code Quality checklist in `code-review`. Each smell
is named so a finding can cite it directly ("this is a Data Clump") instead of
describing the problem from scratch.

## Structural smells (Fowler-style catalog)

| Smell | What it looks like | Fix to name in the finding |
|---|---|---|
| Mysterious Name | A function, variable, or type whose name gives no clue what it holds or does | Rename it; if no honest name fits, the design itself is unclear |
| Duplicated Code | The same logic shape repeated across hunks or files in the change | Extract the shared shape, call it from both sites |
| Feature Envy | A method that reads another object's data more than its own | Move the method to the data it envies |
| Data Clumps | The same handful of fields or parameters keep traveling together | Bundle them into one type and pass that instead |
| Primitive Obsession | A raw primitive or string standing in for a domain concept | Give the concept its own small type |
| Repeated Switches | The same switch/if-cascade on the same type recurs across the change | Replace with polymorphism, or one shared lookup |
| Shotgun Surgery | One logical change forces edits scattered across many files | Gather what changes together into one module |
| Divergent Change | One file or module is edited for several unrelated reasons | Split it so each module has a single reason to change |
| Speculative Generality | Abstraction, parameters, or hooks added for a need the spec doesn't have | Delete it; inline back until a real need appears |
| Message Chains | Long `a.b().c().d()` navigation the caller shouldn't know about | Hide the walk behind one method on the first object |
| Middle Man | A class or function that mostly just forwards the call onward | Cut it out; call the real target directly |
| Refused Bequest | A subclass/implementer that ignores or overrides most of what it inherits | Drop the inheritance in favor of composition |

## Other smells worth flagging

- **Dead Code** — unused imports/variables, unreachable branches, leftover debug statements, or commented-out code left in the change. Delete it; version control remembers it.
- **Noisy Comment** — a comment that restates what the code already says. Cut it; keep only comments that explain *why*.
- **Long Function** — a function doing too much to hold in your head at once. Split it into focused pieces.
- **Magic Number / String** — a bare literal with no name explaining what it means. Extract it to a named constant.

## View-layer smells (UI/templates)

These apply to whatever templating or component system the project uses — JSX, Vue/Svelte templates, server-rendered templates — not any one of them specifically.

- **Hardcoded style values instead of the project's own token/theme system** — a raw hex color, an arbitrary one-off spacing/size value, or any other literal that duplicates what the project's design-token system already names. If the project has a token system at all, a literal that bypasses it is a finding; name the token that should have been used if one clearly fits, or flag that a new token is needed if the value is legitimately new.
- **Non-data-driven duplicated markup** — the same block of markup (a table row, a list item, a section with a heading) repeated several times in the template with only the text changed, instead of one data array (or equivalent config) mapped over to render it once. This is `Duplicated Code` specifically applied to the view layer, and it's exactly where facts (an address, a contact email, a date) tend to get hardcoded in more than one place and drift out of sync.
- **UI affordance not gated by the access control it implies** — a button, menu item, or action visible/enabled for a role or user that the backend will reject (or that shouldn't be able to reach it at all). The server remains the actual authority, but an ungated affordance in the UI is still a finding — it's a broken affordance at best and a false promise at worst, and for any especially sensitive action (one requiring a reason, a confirmation, an elevated role) checking that the UI actually enforces that precondition is worth a dedicated look, not an assumption.

## Type-safety patterns worth a dedicated look

- **`any`/`unknown` introduced without justification**, or a type assertion / non-null assertion (`as X`, `!`) used where proper narrowing should have been possible instead.
- **Optional-and-nullable conflation** — a field typed `field?: Type | null` almost never means what it says. A field that's truly nullable should be `field: Type | null`; a field that may simply be absent should be `field?: Type`.
- **"Optional soup"** — a spread of correlated optional fields that really represent a few distinct, mutually exclusive shapes (one field's presence implying another's absence). Model these as a discriminated union keyed on a literal tag instead. Flag as a correctness-level finding when the optionals make an invalid state representable (a "success" that also carries an `error`); flag as a lower-severity cleanup finding when the shape is merely awkward but no invalid state is reachable.
