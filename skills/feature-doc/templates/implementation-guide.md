<!--
Template: implementation-guide.md
Fill every section. Remove this comment block from the final output.
No bracketed placeholders may remain in the final file.
See ../reference.md for the use-case-vs-workflow distinction, the DDD glossary, and the rule-tagging convention before filling this in.
-->

# <Feature Name> — <Actor Name> — Implementation Guide

| | |
|---|---|
| **Feature** | `<feature-slug>` |
| **Actor** | `<actor-slug>` |
| **Status** | Draft |
| **Companion docs** | [feature-spec.md](./feature-spec.md) · [test-cases.md](./test-cases.md) |
| **Last updated** | <date> |

## Workflow & Lifecycle

<This is the system's internal orchestration for this feature — distinct from the Use Cases in feature-spec.md (see reference.md). Number every step, name the real component/service responsible, and tag the rule(s) it enforces.>

1. **<step name>** — touchpoint: `<service/module>` — `RULE-<feature-slug>-<n>`
   <what happens at this step>

```mermaid
sequenceDiagram
    participant Actor
    participant <Component>
    Actor->><Component>: <action>
```

## Domain Model (DDD)

- **Bounded Context**: <name>
- **Aggregates / Entities**: <list, with the aggregate root marked>
- **Value Objects**: <list>
- **Domain Events**: <list, e.g. `<EventName>` — emitted when <condition>>
- **Domain Services**: <list, or "none" if not applicable>
- **Repositories**: <list>
- **Invariants**: <list of rules that must always hold for the aggregate(s) above>

## Actors

| Actor | Type | Relevant capability in this feature |
|---|---|---|
| `<actor-slug>` | Human / System | <what they can do here> |

## Triggers

- <what initiates this workflow — user action, schedule, webhook, internal event — and any condition gating it>

## Data Sources & APIs

- **Database**: <tables/models read or written>
- **External APIs**: <vendor/third-party calls, or "none">
- **Internal service calls**: <other internal services/modules invoked>
- **Events published/consumed**: <domain events crossing bounded-context boundaries, or "none">

## Pre-conditions (technical)

- <feature flags, migrations, config, auth scopes, infra dependencies required for this workflow to run>

## Rules Summary

| Rule ID | Description | Step | Enforcement point | Failure behavior | Unit test |
|---|---|---|---|---|---|
| `RULE-<feature-slug>-<n>` | <what it checks> | <workflow step it's tied to> | <where in code/system it's enforced> | <what happens when it fails> | <unit test name/location covering this rule at the enforcement point — every rule gets one, in addition to any Gherkin scenario in test-cases.md> |

## Open Questions / Assumptions

- <anything not resolved during the interview, or any assumption made to reconcile the docs with what the user described — flag it here rather than presenting it as settled>
