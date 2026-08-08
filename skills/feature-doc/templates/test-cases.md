<!--
Template: test-cases.md
Fill every section. Remove this comment block from the final output.
Every rule listed in implementation-guide.md's Rules Summary must appear at least once in the traceability table below.
-->

# <Feature Name> — <Actor Name> — Test Cases

| | |
|---|---|
| **Feature** | `<feature-slug>` |
| **Actor** | `<actor-slug>` |
| **Companion docs** | [feature-spec.md](./feature-spec.md) · [implementation-guide.md](./implementation-guide.md) |

## Traceability

| Rule ID | Scenario(s) |
|---|---|
| `RULE-<feature-slug>-<n>` | <scenario name(s) below that verify it> |

## Scenarios

```gherkin
Feature: <Feature Name> — <Actor Name>

  @RULE-<feature-slug>-<n>
  Scenario: <happy path scenario name>
    Given <precondition>
    When <actor action>
    Then <expected result>

  @RULE-<feature-slug>-<n>
  Scenario: <alternate/unhappy path scenario name>
    Given <precondition>
    When <actor action or system condition>
    Then <expected system behavior / resulting state>
```
