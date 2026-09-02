# Coding Patterns

Five structural patterns that apply across API, backend, and frontend logic. Use alongside `incremental-implementation`, `spec-driven-development`, `feature-doc`, `deep-dive`, and `code-review-and-quality` — these describe the *shape* code should have, not a specific framework or language.

Every code sample below also exists as a standalone, runnable file under [`examples/coding-patterns/`](examples/coding-patterns/) (`01-main-path.ts` through `05-useful-errors.ts`) — each compiles clean under `tsc --strict` and its `main()` prints the BAD vs. GOOD behavior side by side so you can run it and see the difference rather than take the markdown's word for it.

## Table of Contents

- [1. Keep the Main Path Easy to Follow](#1-keep-the-main-path-easy-to-follow)
- [2. Keep External Systems Behind a Boundary](#2-keep-external-systems-behind-a-boundary)
- [3. Make Invalid States Harder to Represent](#3-make-invalid-states-harder-to-represent)
- [4. Separate Decisions from Actions](#4-separate-decisions-from-actions)
- [5. Make Errors Useful and Detailed](#5-make-errors-useful-and-detailed)
- [Review Checklist](#review-checklist)

## 1. Keep the Main Path Easy to Follow

*Runnable: [`examples/coding-patterns/01-main-path.ts`](examples/coding-patterns/01-main-path.ts)*

The primary logic of a function — what it's actually *for* — should read top to bottom without being buried under error handling, edge cases, or setup. Use guard clauses to handle exceptions early and return, so the last, unindented block of the function is the thing it exists to do.

```typescript
// BAD: the actual purpose (charge the customer) is buried three levels deep
async function processOrder(order: Order) {
  if (order) {
    if (order.items.length > 0) {
      if (order.customer.paymentMethod) {
        const total = calculateTotal(order.items);
        const charge = await chargeCustomer(order.customer, total);
        return charge;
      } else {
        throw new Error('No payment method');
      }
    } else {
      throw new Error('Empty order');
    }
  } else {
    throw new Error('No order');
  }
}

// GOOD: guard clauses handle exceptions up front; the main path is flat and last
async function processOrder(order: Order) {
  if (!order) throw new ValidationError('Order is required');
  if (order.items.length === 0) throw new ValidationError('Order has no items');
  if (!order.customer.paymentMethod) throw new ValidationError('No payment method on file');

  const total = calculateTotal(order.items);
  return chargeCustomer(order.customer, total);
}
```

A reader should be able to skim past the guard clauses and understand what the function does from its last few lines alone.

## 2. Keep External Systems Behind a Boundary

*Runnable: [`examples/coding-patterns/02-external-boundary.ts`](examples/coding-patterns/02-external-boundary.ts)*

Never let a third-party SDK, HTTP client, or vendor-specific shape leak directly into business logic. Wrap every external system — a payment processor, an email provider, an external API, even a specific database client — behind an interface your domain code depends on, not the vendor's shape.

```typescript
// BAD: business logic depends on Stripe's SDK and error shapes directly
async function refundOrder(orderId: string) {
  const order = await db.orders.findUnique({ where: { id: orderId } });
  await stripe.refunds.create({ payment_intent: order.paymentIntentId });
  // If we ever swap providers, or unit-test this, Stripe's SDK comes along for the ride.
}

// GOOD: business logic depends on an interface; the vendor lives in one adapter
interface PaymentGateway {
  refund(paymentReference: string): Promise<RefundResult>;
}

class StripePaymentGateway implements PaymentGateway {
  async refund(paymentReference: string): Promise<RefundResult> {
    const result = await stripe.refunds.create({ payment_intent: paymentReference });
    return { id: result.id, status: mapStripeStatus(result.status) };
  }
}

async function refundOrder(orderId: string, gateway: PaymentGateway) {
  const order = await db.orders.findUnique({ where: { id: orderId } });
  return gateway.refund(order.paymentIntentId);
}
```

This is what makes swapping providers tractable and lets tests use a fake `PaymentGateway` instead of mocking Stripe's SDK. It also stops a vendor's breaking change or vendor-specific error type from propagating past one file.

## 3. Make Invalid States Harder to Represent

*Runnable: [`examples/coding-patterns/03-invalid-states.ts`](examples/coding-patterns/03-invalid-states.ts)*

Model state so illegal combinations can't be constructed, instead of validating them scattered across the codebase at runtime. Independent boolean/nullable fields are the usual culprit — they multiply into states that should never exist.

```typescript
// BAD: these three independent fields allow nonsensical combinations
interface RequestState {
  isLoading: boolean;
  error: string | null;
  data: Order[] | null;
}
// isLoading: true, error: "failed", data: [...] all at once is representable —
// and now every consumer has to defensively check for it.

// GOOD: a discriminated union makes the impossible combination unrepresentable
type RequestState =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: Order[] }
  | { status: 'error'; error: string };

function render(state: RequestState) {
  switch (state.status) {
    case 'success':
      return state.data; // TypeScript knows `data` exists here — no null check needed
    case 'error':
      return state.error;
    // ...
  }
}
```

The same principle applies to backend domain models: an `Order` that's simultaneously `cancelled` and `shipped` shouldn't be constructible — model status as one field with a closed set of values, not several independently-settable flags.

## 4. Separate Decisions from Actions

*Runnable: [`examples/coding-patterns/04-decisions-vs-actions.ts`](examples/coding-patterns/04-decisions-vs-actions.ts)*

Keep the pure logic of *what should happen* separate from the code that *makes it happen*. This applies directly to validation, retries, pricing, and permissions — anywhere a decision currently triggers its side effect inline.

```typescript
// BAD: the decision (should we retry?) and the action (sleep + retry) are fused —
// you can't test the decision without actually waiting or mocking setTimeout
async function fetchWithRetry(url: string, attempt = 1): Promise<Response> {
  try {
    return await fetch(url);
  } catch (err) {
    if (attempt < 3 && isRetryable(err)) {
      await sleep(attempt * 1000);
      return fetchWithRetry(url, attempt + 1);
    }
    throw err;
  }
}

// GOOD: the decision is a pure function you can unit-test exhaustively with no I/O
type RetryDecision = { retry: true; delayMs: number } | { retry: false };

function decideRetry(attempt: number, error: unknown): RetryDecision {
  if (attempt >= 3 || !isRetryable(error)) return { retry: false };
  return { retry: true, delayMs: attempt * 1000 };
}

async function fetchWithRetry(url: string, attempt = 1): Promise<Response> {
  try {
    return await fetch(url);
  } catch (err) {
    const decision = decideRetry(attempt, err);
    if (!decision.retry) throw err;
    await sleep(decision.delayMs);
    return fetchWithRetry(url, attempt + 1);
  }
}
```

The same split applies to pricing ("what should this order cost" vs. "charge the card") and permissions ("can this user do this" vs. "perform the action") — a pure decision function is trivial to unit-test, audit, log, or preview before its side effect ever runs.

## 5. Make Errors Useful and Detailed

*Runnable: [`examples/coding-patterns/05-useful-errors.ts`](examples/coding-patterns/05-useful-errors.ts)*

An error should carry enough context to debug without reproducing it: what operation failed, what inputs were involved (redacted if sensitive), what was expected vs. what happened, and — where there is one — a next step.

```typescript
// BAD: no context, indistinguishable from every other failure in the logs
if (!user) {
  throw new Error('Not found');
}

// GOOD: a structured error carries what a debugging agent or human actually needs
class ResourceNotFoundError extends Error {
  constructor(
    public readonly resourceType: string,
    public readonly resourceId: string,
    public readonly context?: Record<string, unknown>,
  ) {
    super(`${resourceType} not found: ${resourceId}`);
    this.name = 'ResourceNotFoundError';
  }
}

if (!user) {
  throw new ResourceNotFoundError('User', userId, { requestedBy: currentUser.id });
}
```

Never swallow an error's original context when re-throwing or wrapping it — attach the cause (`new Error('...', { cause: err })` or an equivalent field) rather than replacing it with a generic message.

## Review Checklist

- [ ] The main path of each function reads top-to-bottom without wading through nested conditionals
- [ ] No business logic module imports a third-party SDK directly — it depends on an interface, with the vendor isolated in one adapter
- [ ] State is modeled so illegal combinations can't be constructed (discriminated unions, not independent booleans/nullables)
- [ ] Validation, retry, pricing, and permission logic each expose a pure decision function separate from the code that acts on the decision
- [ ] Every thrown/returned error identifies what failed, with what inputs, and preserves the original cause when wrapped
