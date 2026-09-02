// Pattern 4: Separate Decisions from Actions
// See references/coding-patterns.md#4-separate-decisions-from-actions
export {};

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function isRetryable(error: unknown): boolean {
  return error instanceof Error && error.message !== 'permanent failure';
}

async function fetchStub(shouldFail: boolean): Promise<{ ok: true }> {
  if (shouldFail) throw new Error('transient failure');
  return { ok: true };
}

// BAD: the decision (should we retry?) and the action (sleep + retry) are fused —
// you can't test the decision without actually waiting or mocking setTimeout.
async function fetchWithRetryBad(shouldFail: boolean, attempt = 1): Promise<{ ok: true }> {
  try {
    return await fetchStub(shouldFail && attempt < 3);
  } catch (err) {
    if (attempt < 3 && isRetryable(err)) {
      await sleep(attempt * 10); // scaled down for a fast self-check
      return fetchWithRetryBad(shouldFail, attempt + 1);
    }
    throw err;
  }
}

// GOOD: the decision is a pure function you can unit-test exhaustively with no I/O.
type RetryDecision = { retry: true; delayMs: number } | { retry: false };

function decideRetry(attempt: number, error: unknown): RetryDecision {
  if (attempt >= 3 || !isRetryable(error)) return { retry: false };
  return { retry: true, delayMs: attempt * 10 }; // scaled down for a fast self-check
}

async function fetchWithRetryGood(shouldFail: boolean, attempt = 1): Promise<{ ok: true }> {
  try {
    return await fetchStub(shouldFail && attempt < 3);
  } catch (err) {
    const decision = decideRetry(attempt, err);
    if (!decision.retry) throw err;
    await sleep(decision.delayMs);
    return fetchWithRetryGood(shouldFail, attempt + 1);
  }
}

// --- self-check ---
function checkDecideRetry() {
  // Pure decisions, tested with zero I/O and zero waiting:
  console.log('attempt 1, retryable error ->', decideRetry(1, new Error('transient')));
  console.log('attempt 3, retryable error ->', decideRetry(3, new Error('transient')));
  console.log('attempt 1, permanent error ->', decideRetry(1, new Error('permanent failure')));
}

async function main() {
  checkDecideRetry();
  console.log('BAD path (eventually succeeds after retries):', await fetchWithRetryBad(true));
  console.log('GOOD path (eventually succeeds after retries):', await fetchWithRetryGood(true));
}

main();
