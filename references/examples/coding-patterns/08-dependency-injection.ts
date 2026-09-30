// Pattern 8: Inject Dependencies, Don't Reach for Globals
// See references/coding-patterns.md#8-inject-dependencies-dont-reach-for-globals
export {};

interface Clock {
  now(): Date;
}

interface Notifier {
  send(to: string, message: string): Promise<void>;
}

// Stand-ins for real infrastructure.
const systemClock: Clock = { now: () => new Date() };
const realNotifier: Notifier = {
  async send(to, message) {
    console.log(`[real email to ${to}]: ${message}`);
  },
};

// BAD: the function reaches directly for module-level singletons —
// there is no way to test this without the real clock and a real notifier
// firing, and no way to swap either without editing this function's body.
async function remindOverdueInvoiceBad(dueDate: Date, customerEmail: string) {
  if (systemClock.now() > dueDate) {
    await realNotifier.send(customerEmail, 'Your invoice is overdue.');
  }
}

// GOOD: both dependencies are passed in — the function's signature is
// honest about what it needs, and any implementation of Clock/Notifier
// (real or fake) can be substituted with no change to this function.
async function remindOverdueInvoiceGood(
  dueDate: Date,
  customerEmail: string,
  clock: Clock,
  notifier: Notifier,
) {
  if (clock.now() > dueDate) {
    await notifier.send(customerEmail, 'Your invoice is overdue.');
  }
}

// A fake clock and a fake notifier — no mocking framework, no real email sent.
class FixedClock implements Clock {
  constructor(private readonly fixedNow: Date) {}
  now(): Date {
    return this.fixedNow;
  }
}

class FakeNotifier implements Notifier {
  public sent: Array<{ to: string; message: string }> = [];
  async send(to: string, message: string): Promise<void> {
    this.sent.push({ to, message });
  }
}

// --- self-check ---
async function main() {
  const dueDate = new Date('2026-01-01');

  console.log('BAD: always uses the real clock and real notifier — nothing here is substitutable.');
  await remindOverdueInvoiceBad(dueDate, 'customer@example.com');

  const clock = new FixedClock(new Date('2026-02-01')); // deterministic "now", no waiting for real time
  const notifier = new FakeNotifier(); // records calls instead of sending real email

  await remindOverdueInvoiceGood(dueDate, 'customer@example.com', clock, notifier);
  console.log('GOOD: substituted a fixed clock and fake notifier — fully deterministic:', notifier.sent);
}

main();
