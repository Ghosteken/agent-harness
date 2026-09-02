// Pattern 5: Make Errors Useful and Detailed
// See references/coding-patterns.md#5-make-errors-useful-and-detailed
export {};

interface User {
  id: string;
}

const currentUser: User = { id: 'user_admin' };

async function findUser(_userId: string): Promise<User | null> {
  return null; // simulating "not found" for this self-check
}

// BAD: no context, indistinguishable from every other failure in the logs.
async function getUserBad(userId: string) {
  const user = await findUser(userId);
  if (!user) {
    throw new Error('Not found');
  }
  return user;
}

// GOOD: a structured error carries what a debugging agent or human actually needs.
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

async function getUserGood(userId: string) {
  const user = await findUser(userId);
  if (!user) {
    throw new ResourceNotFoundError('User', userId, { requestedBy: currentUser.id });
  }
  return user;
}

// Wrapping an error should preserve the original cause, not replace it.
async function getUserGoodWithCause(userId: string) {
  try {
    return await getUserGood(userId);
  } catch (err) {
    throw new Error(`Failed to load user for profile page`, { cause: err });
  }
}

// --- self-check ---
async function main() {
  try {
    await getUserBad('user_42');
  } catch (err) {
    console.log('BAD error message:', (err as Error).message);
    // No resourceType, no resourceId, no requester — a debugger has to go re-add
    // logging and reproduce the failure to learn anything more.
  }

  try {
    await getUserGood('user_42');
  } catch (err) {
    const nfErr = err as ResourceNotFoundError;
    console.log('GOOD error message:', nfErr.message);
    console.log('GOOD error structured fields:', {
      resourceType: nfErr.resourceType,
      resourceId: nfErr.resourceId,
      context: nfErr.context,
    });
  }

  try {
    await getUserGoodWithCause('user_42');
  } catch (err) {
    const wrapped = err as Error;
    console.log('GOOD wrapped error message:', wrapped.message);
    console.log('GOOD wrapped error preserves cause:', (wrapped.cause as Error)?.message);
  }
}

main();
