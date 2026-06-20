# Execute Test Plan

You will receive a feature description, a test plan with scenarios and expected outcomes, and an entry point URL or API base URL.

**Scope: behaviour only.** This mode validates that the feature behaves as the test plan specifies. Visual fidelity is out of scope.

## Process

### 1. Orient

Navigate to the entry point and take an initial screenshot or snapshot to confirm the feature is reachable and in the expected initial state.

### 2. Execute Each Scenario

For each scenario in the test plan:

1. **Read the scenario** — understand the steps and the expected outcome before doing anything
2. **Set up state** — navigate to the correct starting point, authenticate if needed, seed any required preconditions
3. **Perform the steps** — use the browser or API to execute each step exactly as described
4. **Observe the outcome** — capture a screenshot or API response at the point where the expected outcome should be observable
5. **Record the result** — PASS if the actual outcome matches expected, FAIL with a specific description of the discrepancy if not

Work through scenarios independently. A failure in one scenario should not block execution of the others unless there is an explicit dependency.

### 3. API-only Scenarios

When a scenario involves a pure API call with no UI, use `curl` via Bash. Do not open a browser for API-only scenarios. Refer to the authentication flows in the main `SKILL.md` for how to handle auth before making requests.

Record the response status and body for each request, and compare against the expected outcome from the test plan.

### 4. Screenshots

Save any screenshots taken during execution to `/tmp/<feature-slug>/`. Create the directory if it does not exist. Use descriptive filenames that identify the scenario and step (e.g., `checkout-step2-payment-form.png`).

### 5. Check for Errors

After exercising the feature, review console output and network activity for unexpected failures.

## Output

```
## Test Execution Report

### Feature
[Feature name / description]

### Scenario Results

#### [Scenario name]
**Steps performed**: [brief summary]
**Expected**: [expected outcome from the test plan]
**Actual**: [what actually happened]
**Verdict**: PASS / FAIL
**Evidence**: [screenshot or response captured]

[Repeat for each scenario]

### Console Errors
[Any unexpected errors observed, or "None"]

### Network Failures
[Any failed requests, or "None"]

### Overall Verdict
PASS / FAIL — [X of Y scenarios passed]
```

Be specific about failures. "Clicking 'Submit' shows a spinner but the form never completes — network tab shows POST /api/orders returning 500" is better than "the form didn't work".
