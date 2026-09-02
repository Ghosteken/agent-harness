// Pattern 1: Keep the Main Path Easy to Follow
// See references/coding-patterns.md#1-keep-the-main-path-easy-to-follow
export {};

interface OrderItem {
  productId: string;
  quantity: number;
  unitPrice: number;
}

interface Order {
  id: string;
  items: OrderItem[];
  customer: {
    id: string;
    paymentMethod: string | null;
  };
}

class ValidationError extends Error {}

function calculateTotal(items: OrderItem[]): number {
  return items.reduce((sum, item) => sum + item.quantity * item.unitPrice, 0);
}

async function chargeCustomer(customerId: string, amount: number): Promise<{ chargeId: string }> {
  return { chargeId: `ch_${customerId}_${amount}` };
}

// BAD: the actual purpose (charge the customer) is buried three levels deep
async function processOrderBad(order: Order | null) {
  if (order) {
    if (order.items.length > 0) {
      if (order.customer.paymentMethod) {
        const total = calculateTotal(order.items);
        const charge = await chargeCustomer(order.customer.id, total);
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
async function processOrderGood(order: Order | null) {
  if (!order) throw new ValidationError('Order is required');
  if (order.items.length === 0) throw new ValidationError('Order has no items');
  if (!order.customer.paymentMethod) throw new ValidationError('No payment method on file');

  const total = calculateTotal(order.items);
  return chargeCustomer(order.customer.id, total);
}

// --- self-check ---
async function main() {
  const order: Order = {
    id: 'order_1',
    items: [{ productId: 'p1', quantity: 2, unitPrice: 10 }],
    customer: { id: 'cust_1', paymentMethod: 'card_1' },
  };

  const badResult = await processOrderBad(order);
  const goodResult = await processOrderGood(order);
  console.log('BAD path result:', badResult);
  console.log('GOOD path result:', goodResult);

  try {
    await processOrderGood(null);
  } catch (err) {
    console.log('GOOD path correctly rejected a null order:', (err as Error).message);
  }
}

main();
