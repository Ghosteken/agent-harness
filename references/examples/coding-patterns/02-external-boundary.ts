// Pattern 2: Keep External Systems Behind a Boundary
// See references/coding-patterns.md#2-keep-external-systems-behind-a-boundary
export {};

interface Order {
  id: string;
  paymentIntentId: string;
}

// Stand-in for a real vendor SDK (e.g. the Stripe Node SDK) and a real DB client.
const stripe = {
  refunds: {
    async create(params: { payment_intent: string }): Promise<{ id: string; status: string }> {
      return { id: `re_${params.payment_intent}`, status: 'succeeded' };
    },
  },
};

const db = {
  orders: {
    async findUnique(_query: { where: { id: string } }): Promise<Order> {
      return { id: _query.where.id, paymentIntentId: 'pi_123' };
    },
  },
};

// BAD: business logic depends on Stripe's SDK and error shapes directly.
// If we ever swap providers, or unit-test this, Stripe's SDK comes along for the ride.
async function refundOrderBad(orderId: string) {
  const order = await db.orders.findUnique({ where: { id: orderId } });
  return stripe.refunds.create({ payment_intent: order.paymentIntentId });
}

// GOOD: business logic depends on an interface; the vendor lives in one adapter.
interface RefundResult {
  id: string;
  status: 'succeeded' | 'failed' | 'pending';
}

interface PaymentGateway {
  refund(paymentReference: string): Promise<RefundResult>;
}

function mapStripeStatus(status: string): RefundResult['status'] {
  if (status === 'succeeded') return 'succeeded';
  if (status === 'pending') return 'pending';
  return 'failed';
}

class StripePaymentGateway implements PaymentGateway {
  async refund(paymentReference: string): Promise<RefundResult> {
    const result = await stripe.refunds.create({ payment_intent: paymentReference });
    return { id: result.id, status: mapStripeStatus(result.status) };
  }
}

// A fake for tests — no network, no SDK, no mocking framework needed.
class FakePaymentGateway implements PaymentGateway {
  public calls: string[] = [];
  async refund(paymentReference: string): Promise<RefundResult> {
    this.calls.push(paymentReference);
    return { id: `fake_${paymentReference}`, status: 'succeeded' };
  }
}

async function refundOrderGood(orderId: string, gateway: PaymentGateway) {
  const order = await db.orders.findUnique({ where: { id: orderId } });
  return gateway.refund(order.paymentIntentId);
}

// --- self-check ---
async function main() {
  console.log('BAD path (direct Stripe dependency):', await refundOrderBad('order_1'));

  const stripeGateway = new StripePaymentGateway();
  console.log('GOOD path (via interface, real adapter):', await refundOrderGood('order_1', stripeGateway));

  const fakeGateway = new FakePaymentGateway();
  const result = await refundOrderGood('order_2', fakeGateway);
  console.log('GOOD path (via interface, fake for a test):', result, 'calls recorded:', fakeGateway.calls);
}

main();
