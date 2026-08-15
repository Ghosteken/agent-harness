# Code Smells Checklist

Reference material for the `reuse`, `simplification`, and `altitude` finder angles in
`code-review-and-quality`. Each smell is named so a finding can cite it directly
("this is a Data Clump") instead of describing the problem from scratch.

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

## Type-safety patterns worth a dedicated look

- **`any`/`unknown` introduced without justification**, or a type assertion / non-null assertion (`as X`, `!`) used where proper narrowing should have been possible instead.
- **Optional-and-nullable conflation** — a field typed `field?: Type | null` almost never means what it says. A field that's truly nullable should be `field: Type | null`; a field that may simply be absent should be `field?: Type`.
- **"Optional soup"** — a spread of correlated optional fields that really represent a few distinct, mutually exclusive shapes (one field's presence implying another's absence). Model these as a discriminated union keyed on a literal tag instead. Flag as a correctness-level finding when the optionals make an invalid state representable (a "success" that also carries an `error`); flag as a lower-severity cleanup finding when the shape is merely awkward but no invalid state is reachable.
