// Pattern 6: Open for Extension, Closed for Modification
// See references/coding-patterns.md#6-open-for-extension-closed-for-modification
export {};

interface Order {
  total: number;
  destination: 'domestic' | 'international';
  weightKg: number;
}

// BAD: adding a new shipping method means editing this function again —
// every new case is a new risk of breaking the ones already working.
function calculateShippingBad(order: Order, method: string): number {
  if (method === 'standard') return order.weightKg * 2;
  if (method === 'express') return order.weightKg * 5 + 10;
  if (method === 'international') return order.weightKg * 8 + 25;
  // Someone adds 'freight' here next quarter, editing a function every
  // other shipping method already depends on.
  throw new Error(`Unknown shipping method: ${method}`);
}

// GOOD: each method is its own implementation behind a shared interface —
// adding "freight" means writing a new class, never touching the others.
interface ShippingStrategy {
  calculate(order: Order): number;
}

class StandardShipping implements ShippingStrategy {
  calculate(order: Order): number {
    return order.weightKg * 2;
  }
}

class ExpressShipping implements ShippingStrategy {
  calculate(order: Order): number {
    return order.weightKg * 5 + 10;
  }
}

class InternationalShipping implements ShippingStrategy {
  calculate(order: Order): number {
    return order.weightKg * 8 + 25;
  }
}

function calculateShippingGood(order: Order, strategy: ShippingStrategy): number {
  return strategy.calculate(order);
}

// --- self-check ---
function main() {
  const order: Order = { total: 100, destination: 'domestic', weightKg: 4 };

  console.log('BAD (editing the function for each method):', calculateShippingBad(order, 'express'));

  console.log('GOOD (standard):', calculateShippingGood(order, new StandardShipping()));
  console.log('GOOD (express):', calculateShippingGood(order, new ExpressShipping()));
  console.log('GOOD (international):', calculateShippingGood(order, new InternationalShipping()));
  // A "FreightShipping" class could be added right here, with zero changes
  // to calculateShippingGood or the classes above it.
}

main();
