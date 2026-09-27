# Playwright Patterns

Code patterns referenced by `SKILL.md`. Adapt to the project's actual conventions — these are references, not templates to paste verbatim.

## Config

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  timeout: 30000,
  expect: { timeout: 5000 },
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [['html'], ['junit', { outputFile: 'results.xml' }]],
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    // Add firefox/webkit/mobile projects only if cross-browser coverage is actually needed
  ],
});
```

## Page Object Model

```typescript
// pages/LoginPage.ts
import { Page, Locator } from '@playwright/test';

export class LoginPage {
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly loginButton: Locator;
  readonly errorMessage: Locator;

  constructor(page: Page) {
    this.page = page;
    this.emailInput = page.getByLabel('Email');
    this.passwordInput = page.getByLabel('Password');
    this.loginButton = page.getByRole('button', { name: 'Login' });
    this.errorMessage = page.getByRole('alert');
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.loginButton.click();
  }
}

// Test using the Page Object
import { test, expect } from '@playwright/test';
import { LoginPage } from './pages/LoginPage';

test('successful login', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.goto();
  await loginPage.login('user@example.com', 'password123');
  await expect(page).toHaveURL('/dashboard');
});
```

## Fixtures for test data (create + teardown)

```typescript
// fixtures/test-data.ts
import { test as base } from '@playwright/test';

type TestData = { testUser: { email: string; password: string } };

export const test = base.extend<TestData>({
  testUser: async ({}, use) => {
    const user = { email: `test-${Date.now()}@example.com`, password: 'Test123!@#' };
    await createTestUser(user);
    await use(user);
    await deleteTestUser(user.email); // teardown always runs, even on failure
  },
});
```

## Waiting strategies

```typescript
// Bad: fixed timeout — slower than necessary, still races real load
await page.waitForTimeout(3000);

// Good: wait on the actual condition
await page.waitForLoadState('networkidle');
await page.waitForURL('/dashboard');
await expect(page.getByText('Welcome')).toBeVisible();

// Wait on a specific network response
const responsePromise = page.waitForResponse(
  (r) => r.url().includes('/api/users') && r.status() === 200
);
await page.getByRole('button', { name: 'Load Users' }).click();
const response = await responsePromise;
```

## Network mocking

```typescript
test('displays error when API fails', async ({ page }) => {
  await page.route('**/api/users', (route) =>
    route.fulfill({ status: 500, body: JSON.stringify({ error: 'Internal Server Error' }) })
  );
  await page.goto('/users');
  await expect(page.getByText('Failed to load users')).toBeVisible();
});

// Mock a third-party dependency (payments, etc.) rather than hitting it live
test('payment flow with mocked provider', async ({ page }) => {
  await page.route('**/api/payments/**', (route) =>
    route.fulfill({ status: 200, body: JSON.stringify({ status: 'succeeded' }) })
  );
});
```

## Visual regression (where it earns its cost)

```typescript
test('homepage looks correct', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveScreenshot('homepage.png', { fullPage: true, maxDiffPixels: 100 });
});
```

## Sharding for CI parallelism

```bash
npx playwright test --shard=1/4
npx playwright test --shard=2/4
```

## Accessibility scan folded into the suite

```typescript
// npm install @axe-core/playwright
import AxeBuilder from '@axe-core/playwright';

test('page has no accessibility violations', async ({ page }) => {
  await page.goto('/');
  const results = await new AxeBuilder({ page }).analyze();
  expect(results.violations).toEqual([]);
});
```

## Debugging a failing test

```bash
npx playwright test --headed   # watch it run
npx playwright test --debug    # step through
npx playwright show-trace trace.zip   # inspect a CI failure's captured trace
```

```typescript
test('checkout flow', async ({ page }) => {
  await test.step('Add item to cart', async () => {
    await page.goto('/products');
    await page.getByRole('button', { name: 'Add to Cart' }).click();
  });
  await test.step('Proceed to checkout', async () => {
    await page.getByRole('button', { name: 'Checkout' }).click();
  });
});
```
