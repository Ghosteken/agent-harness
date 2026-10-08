# Coding Patterns

Eight structural patterns that apply across API, backend, and frontend logic — what a senior engineer actually means by "good design," made concrete rather than left as an acronym. Use alongside `incremental-implementation`, `spec-driven-development`, `deep-dive`, `breakdown-feature-implementation`, and `code-review` — these describe the *shape* code should have, not a specific framework or language.

Every code sample below also exists as a standalone, runnable file under [`examples/coding-patterns/`](examples/coding-patterns/) (`01-main-path.ts` through `08-dependency-injection.ts`) — each compiles clean under `tsc --strict` and its `main()` prints the BAD vs. GOOD behavior side by side so you can run it and see the difference rather than take the markdown's word for it.

## How this maps to SOLID

These patterns aren't a competing framework to SOLID — they're SOLID made concrete, plus two patterns (main path, useful errors) that are just good practice regardless of acronym:

| SOLID | Pattern here |
|---|---|
| **S**ingle Responsibility | [4. Separate Decisions from Actions](#4-separate-decisions-from-actions) |
| **O**pen/Closed | [6. Open for Extension, Closed for Modification](#6-open-for-extension-closed-for-modification) |
| **L**iskov Substitution | [7. Depend on Narrow, Honest Interfaces](#7-depend-on-narrow-honest-interfaces) |
| **I**nterface Segregation | [7. Depend on Narrow, Honest Interfaces](#7-depend-on-narrow-honest-interfaces) |
| **D**ependency Inversion | [2. Keep External Systems Behind a Boundary](#2-keep-external-systems-behind-a-boundary), [8. Inject Dependencies, Don't Reach for Globals](#8-inject-dependencies-dont-reach-for-globals) |

## Table of Contents

- [1. Keep the Main Path Easy to Follow](#1-keep-the-main-path-easy-to-follow)
- [2. Keep External Systems Behind a Boundary](#2-keep-external-systems-behind-a-boundary)
- [3. Make Invalid States Harder to Represent](#3-make-invalid-states-harder-to-represent)
- [4. Separate Decisions from Actions](#4-separate-decisions-from-actions)
- [5. Make Errors Useful and Detailed](#5-make-errors-useful-and-detailed)
- [6. Open for Extension, Closed for Modification](#6-open-for-extension-closed-for-modification)
- [7. Depend on Narrow, Honest Interfaces](#7-depend-on-narrow-honest-interfaces)
- [8. Inject Dependencies, Don't Reach for Globals](#8-inject-dependencies-dont-reach-for-globals)
- [Other Patterns Worth Recognizing](#other-patterns-worth-recognizing)
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

## 6. Open for Extension, Closed for Modification

*Runnable: [`examples/coding-patterns/06-open-closed.ts`](examples/coding-patterns/06-open-closed.ts)*

When a new variant of something (a shipping method, a payment type, a notification channel) means editing an existing function's conditional again, that function is closed to extension, not open to it — every addition risks breaking every case already working. Give each variant its own implementation behind a shared interface instead, so adding one is writing a new class, never touching the others.

```typescript
// BAD: a new shipping method means editing this function, and re-risking
// every case that already worked
function calculateShipping(order: Order, method: string): number {
  if (method === 'standard') return order.weightKg * 2;
  if (method === 'express') return order.weightKg * 5 + 10;
  // next quarter: another case gets added here, in the same function
  throw new Error(`Unknown method: ${method}`);
}

// GOOD: each method is its own class behind one interface — a new
// "FreightShipping" class can be added with zero changes to this function
// or to StandardShipping/ExpressShipping
interface ShippingStrategy {
  calculate(order: Order): number;
}

class StandardShipping implements ShippingStrategy {
  calculate(order: Order) { return order.weightKg * 2; }
}

function calculateShippingViaStrategy(order: Order, strategy: ShippingStrategy): number {
  return strategy.calculate(order);
}
```

This is the mechanism the Strategy pattern names — interchangeable behavior behind one interface, selected by the caller rather than branched on inside the function.

## 7. Depend on Narrow, Honest Interfaces

*Runnable: [`examples/coding-patterns/07-honest-interfaces.ts`](examples/coding-patterns/07-honest-interfaces.ts)*

Two related failures, usually seen together: a fat interface that forces every implementer to support methods it doesn't actually have (a read-only cache forced to implement `write`/`delete` it can't honor), and a subtype that silently narrows its supertype's contract to cope (a no-op `write`, or a `delete` that throws where the interface promised success). Split interfaces by what's actually used, and never let an implementer fake support for a capability it doesn't have.

```typescript
// BAD: one fat interface forces a read-only cache to "implement" write/delete —
// it either no-ops silently or throws, and callers trusting the interface
// have no way to know which
interface Storage {
  read(key: string): Promise<string | null>;
  write(key: string, value: string): Promise<void>;
  delete(key: string): Promise<void>;
}

class ReadOnlyCache implements Storage {
  async read(key: string) { /* ... */ return null; }
  async write() { /* no-op — callers can't tell this silently did nothing */ }
  async delete() { throw new Error('Not supported'); }
}

// GOOD: split by actual capability — a read-only cache only claims Readable,
// and anything claiming Writable genuinely supports it
interface Readable { read(key: string): Promise<string | null>; }
interface Writable { write(key: string, value: string): Promise<void>; delete(key: string): Promise<void>; }

class ReadOnlyCacheHonest implements Readable {
  async read(key: string) { /* ... */ return null; }
  // no write/delete to fake — the type signature says so
}
```

A function that only needs to read should accept `Readable`, not the full `Storage` — it can't accidentally call a method it doesn't actually use, and every implementer it receives genuinely supports what it claims to.

## 8. Inject Dependencies, Don't Reach for Globals

*Runnable: [`examples/coding-patterns/08-dependency-injection.ts`](examples/coding-patterns/08-dependency-injection.ts)*

A function or class that reaches directly for a module-level singleton (a shared DB client, a real clock, a global notifier) can't be tested without the real thing firing, and can't have that dependency swapped without editing its body. Pass dependencies in — constructor or function parameter — so the signature is honest about what's needed, and any implementation (real or fake) can be substituted with no change to the code that uses it.

```typescript
// BAD: reaches for module-level globals directly — untestable without
// the real clock and a real notification actually firing
async function remindOverdueInvoice(dueDate: Date, email: string) {
  if (systemClock.now() > dueDate) {
    await realNotifier.send(email, 'Your invoice is overdue.');
  }
}

// GOOD: dependencies are parameters — a FixedClock and a FakeNotifier make
// this fully deterministic and side-effect-free in a test, with no
// mocking framework needed
async function remindOverdueInvoiceGood(
  dueDate: Date, email: string, clock: Clock, notifier: Notifier,
) {
  if (clock.now() > dueDate) {
    await notifier.send(email, 'Your invoice is overdue.');
  }
}
```

This is the delivery mechanism for Pattern 2's boundary interfaces — injection is *how* a real adapter (or a fake, in a test) actually reaches the code that depends on it.

## Other Patterns Worth Recognizing

These compose the eight patterns above rather than introducing new principles — recognize them by name, but the underlying mechanism is already covered:

- **Repository** — Pattern 2 (external boundary) applied specifically to data access: domain code depends on a `UserRepository` interface, not a specific ORM/query builder.
- **Factory** — centralizes *which* implementation to construct (often paired with Pattern 6's Strategy) so callers depend on the interface, never on a constructor call to a concrete class scattered through the codebase.
- **Adapter** — the concrete class that implements a Pattern 2 boundary interface for one specific vendor/library (e.g. `StripePaymentGateway` implementing `PaymentGateway`).
- **Observer / Pub-Sub** — decouples "something happened" from "here's what reacts to it," the same separation Pattern 4 (decisions from actions) applies across component boundaries instead of within one function.
- **Decorator** — wraps an existing implementation of an interface to add behavior (logging, caching, retries) without the wrapped code or its callers knowing — only possible because the dependency was already behind an interface (Pattern 2) and injected (Pattern 8), not reached for directly.

## Review Checklist

- [ ] The main path of each function reads top-to-bottom without wading through nested conditionals
- [ ] No business logic module imports a third-party SDK directly — it depends on an interface, with the vendor isolated in one adapter
- [ ] State is modeled so illegal combinations can't be constructed (discriminated unions, not independent booleans/nullables)
- [ ] Validation, retry, pricing, and permission logic each expose a pure decision function separate from the code that acts on the decision
- [ ] Every thrown/returned error identifies what failed, with what inputs, and preserves the original cause when wrapped
- [ ] Adding a new variant (shipping method, payment type, notification channel) means writing a new implementation, not editing an existing conditional
- [ ] No interface forces an implementer to fake support for a capability it doesn't have (silent no-op, or a throw where the interface promised success)
- [ ] Dependencies (clients, clocks, notifiers) are passed in as parameters, not reached for as module-level globals
