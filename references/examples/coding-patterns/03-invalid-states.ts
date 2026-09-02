// Pattern 3: Make Invalid States Harder to Represent
// See references/coding-patterns.md#3-make-invalid-states-harder-to-represent
export {};

interface Order {
  id: string;
}

// BAD: three independent fields allow nonsensical combinations —
// isLoading: true, error: "failed", data: [...] all at once is representable,
// and now every consumer has to defensively check for it.
interface RequestStateBad {
  isLoading: boolean;
  error: string | null;
  data: Order[] | null;
}

function renderBad(state: RequestStateBad): string {
  // Every branch has to guess which combination is "real" —
  // this is exactly the defensive checking the pattern avoids.
  if (state.isLoading) return 'Loading...';
  if (state.error) return `Error: ${state.error}`;
  if (state.data) return `Loaded ${state.data.length} orders`;
  return 'Idle';
}

// GOOD: a discriminated union makes the impossible combination unrepresentable.
type RequestStateGood =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: Order[] }
  | { status: 'error'; error: string };

function renderGood(state: RequestStateGood): string {
  switch (state.status) {
    case 'idle':
      return 'Idle';
    case 'loading':
      return 'Loading...';
    case 'success':
      return `Loaded ${state.data.length} orders`; // TS knows `data` exists here, no null check needed
    case 'error':
      return `Error: ${state.error}`; // TS knows `error` exists here
  }
}

// --- self-check ---
function main() {
  // This nonsensical state compiles under the BAD shape — that's the problem.
  const impossibleButValid: RequestStateBad = { isLoading: true, error: 'failed', data: [{ id: 'o1' }] };
  console.log('BAD shape allows a contradictory state:', renderBad(impossibleButValid));

  // The GOOD shape has no way to express "loading" and "success" at once —
  // uncomment the next line to see TypeScript reject it at compile time:
  // const invalid: RequestStateGood = { status: 'loading', data: [] }; // Error: 'data' does not exist on type '{ status: "loading" }'

  const goodStates: RequestStateGood[] = [
    { status: 'idle' },
    { status: 'loading' },
    { status: 'success', data: [{ id: 'o1' }] },
    { status: 'error', error: 'network down' },
  ];
  for (const s of goodStates) console.log('GOOD shape:', renderGood(s));
}

main();
