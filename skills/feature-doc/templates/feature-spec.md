<!--
Template: feature-spec.md
Fill every section. Remove this comment block from the final output.
No bracketed placeholders may remain in the final file.
-->

# <Feature Name> — <Actor Name>

| | |
|---|---|
| **Feature** | `<feature-slug>` |
| **Actor** | `<actor-slug>` — <one-line description of who/what this actor is> |
| **Status** | Draft |
| **Source docs** | <links/section refs to the technical doc and product doc sections used> |
| **Last updated** | <date> |

## Main Goal

<One to two sentences: the primary outcome this feature delivers for this actor. Not a list of capabilities — the single reason this feature exists for them.>

## User Journey

<Narrative, written from the actor's point of view, spanning every touchpoint before, during, and after using this feature. Not a use case list — this is the story a person would tell about using it.>

## Use Cases

| ID | Title | Trigger | Goal | Description |
|---|---|---|---|---|
| UC-<feature-slug>-1 | <short title> | <what starts it> | <actor's goal> | <one or two sentences, black-box, no internal mechanics> |

## Features

- **<capability name>** — <one-line description of the concrete capability>

## Specs

### Functional

- <inputs, outputs, business rules, UI/data requirements — reference rule IDs where a spec item is also a validation rule enforced elsewhere, e.g. `(RULE-<feature-slug>-1)`>

### Non-functional

- <performance, security, compliance constraints that apply — omit this subsection entirely if none apply, rather than inventing generic ones>

## Pre-conditions

- <system/data/state conditions that must already hold before this actor can use this feature>

## Happy Path

1. <step> — `RULE-<feature-slug>-<n>`
2. <step> — `RULE-<feature-slug>-<n>`

## Alternate & Unhappy Paths

| Path | Trigger / condition | System touchpoint(s) | System behavior | Resulting state | Rule(s) |
|---|---|---|---|---|---|
| <name> | <what deviates from the happy path> | <API/service/DB/third-party involved> | <what the system does in response> | <end state for the actor> | `RULE-<feature-slug>-<n>` |
