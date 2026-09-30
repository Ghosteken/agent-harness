// Pattern 7: Depend on Narrow, Honest Interfaces
// See references/coding-patterns.md#7-depend-on-narrow-honest-interfaces
export {};

// BAD: one fat interface forces every implementer to support methods it
// doesn't actually need (Interface Segregation) — and the read-only cache
// below "supports" write/delete by lying about it, which breaks any code
// that trusts the interface's promise (Liskov Substitution).
interface StorageBad {
  read(key: string): Promise<string | null>;
  write(key: string, value: string): Promise<void>;
  delete(key: string): Promise<void>;
  backup(): Promise<void>;
}

class ReadOnlyCacheBad implements StorageBad {
  private data = new Map<string, string>([['config', 'v1']]);

  async read(key: string): Promise<string | null> {
    return this.data.get(key) ?? null;
  }

  // These three exist only because the interface demands them — callers
  // that see a Storage and call .write() get silent no-ops instead of the
  // write they were promised, or a thrown error where the base type promised
  // success. Either way, the subtype has quietly narrowed the contract.
  async write(_key: string, _value: string): Promise<void> {
    // no-op — a caller trusting the interface has no way to know this
  }
  async delete(_key: string): Promise<void> {
    throw new Error('Not supported');
  }
  async backup(): Promise<void> {
    throw new Error('Not supported');
  }
}

// GOOD: split into focused interfaces — an implementer only takes on what
// it genuinely supports, and every implementer of a given interface fully
// honors what that interface promises. No silent no-ops, no surprise throws.
interface Readable {
  read(key: string): Promise<string | null>;
}

interface Writable {
  write(key: string, value: string): Promise<void>;
  delete(key: string): Promise<void>;
}

class ReadOnlyCacheGood implements Readable {
  private data = new Map<string, string>([['config', 'v1']]);

  async read(key: string): Promise<string | null> {
    return this.data.get(key) ?? null;
  }
  // No write/delete to fake — this class is honestly read-only,
  // and its type signature says so.
}

class DurableStoreGood implements Readable, Writable {
  private data = new Map<string, string>();

  async read(key: string): Promise<string | null> {
    return this.data.get(key) ?? null;
  }
  async write(key: string, value: string): Promise<void> {
    this.data.set(key, value);
  }
  async delete(key: string): Promise<void> {
    this.data.delete(key);
  }
}

// A function that only needs to read doesn't require a full Storage —
// it can accept exactly the capability it uses.
async function loadConfig(store: Readable): Promise<string | null> {
  return store.read('config');
}

// --- self-check ---
async function main() {
  const badCache = new ReadOnlyCacheBad();
  console.log('BAD: read works', await badCache.read('config'));
  console.log('BAD: write "succeeds" but silently does nothing', await badCache.write('config', 'v2'));
  console.log('BAD: read after "write" — still v1, the caller was never told', await badCache.read('config'));

  const goodCache = new ReadOnlyCacheGood();
  console.log('GOOD: read-only cache only exposes read()', await loadConfig(goodCache));

  const durable = new DurableStoreGood();
  await durable.write('config', 'v2');
  console.log('GOOD: durable store genuinely supports write()', await loadConfig(durable));
}

main();
