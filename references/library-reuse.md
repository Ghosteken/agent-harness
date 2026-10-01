# Library Reuse: Prefer a Proven Dependency Over Custom Code

## Overview

A huge share of "implementation work" is solving a problem that a well-maintained, widely-used library already solves correctly — date arithmetic, schema validation, HTTP retries, password hashing, CSV parsing, PDF generation, rate limiting. Writing it by hand isn't a sign of rigor; it's usually a sign the alternative wasn't considered. Custom code for a solved problem means custom bugs, custom edge cases (timezones, locale, Unicode, leap years, encoding), and an ongoing maintenance cost the library's maintainers already absorbed.

This reference exists so that implementation plans, specs, and technical docs name the library a reasonable senior engineer would reach for — not as a footnote, but as a concrete line in the plan ("date math uses `date-fns`," not "implement date comparison logic").

## The Rule

When a plan, spec, or design doc calls for logic in one of the categories below, name the specific library to use for it, not a description of the logic to hand-write. Only write custom code when:

- The need is a few lines of straightforward, boundary-free logic (e.g. `Math.max(a, b)`, a one-line string template) — not worth a dependency.
- No category below actually fits — the need is genuinely domain-specific business logic, not a solved general problem.
- The project has an explicit, stated constraint against adding dependencies (bundle-size budget, vendored/offline environment, a security policy restricting third-party code) — note the constraint and the custom alternative it forces, don't silently add a library when one was ruled out.
- An equivalent library is already a dependency in the project — use what's already there over introducing a second library for the same job, even if this reference recommends a different default.

## Decision Heuristic (When Choosing Among Options)

Prefer, in rough order:

1. **Actively maintained** — recent releases, open issues getting addressed, not abandoned.
2. **Widely adopted** — high download counts/ecosystem presence is a proxy for battle-testing, not a goal in itself.
3. **First-class TypeScript support** (for TS/JS projects) — shipped types, not a community `@types` package years out of date.
4. **Matches the project's existing stack** — a Zod-validated project adding Yup for one new feature is a worse choice than consistency, even if Yup is otherwise fine.
5. **Bundle size, for anything shipped to a browser** — a server-side job has far more headroom than client bundle code; note this tradeoff explicitly when it's relevant (e.g. prefer a tree-shakeable or lighter-weight option for client-side validation).
6. **License compatible with the project** — flag anything GPL/AGPL in a proprietary codebase rather than assuming it's fine.

## Categories and Current Defaults

These are starting points, not mandates — confirm against what the project already uses first. Treat this table as something to refresh periodically; libraries and ecosystems move.

| Category | Reach for | Notes |
|---|---|---|
| Date/time math & formatting | `date-fns` (functional, tree-shakeable, immutable) or `dayjs` (smaller, Moment-like API) | Never hand-roll date arithmetic, timezone conversion, or "days between dates" — these have real edge cases (DST, leap years, locale). `Intl.DateTimeFormat` covers pure formatting without a dependency if that's all that's needed. |
| Schema/input validation | `zod` (TS-first, ecosystem standard, pairs with form libraries and API layers) or `valibot` (bundle-size-sensitive client code) | Validate at every boundary (API input, env vars, form submission) through one schema library, not ad hoc `if` chains re-deriving the same checks. |
| HTTP client | `axios` (interceptors, broad ecosystem) or `ky`/`ofetch` (modern, smaller, built on `fetch`) | Don't hand-write retry/timeout/interceptor logic around raw `fetch` — that's exactly what these libraries exist for. |
| Forms (React) | `react-hook-form` (+ `zodResolver` for validation) | Covers field state, validation wiring, and submission — don't hand-roll controlled-input state management for anything beyond a trivial form. |
| State management (React) | `zustand` for simple shared client state; `@reduxjs/toolkit` (+ RTK Query) for larger apps already on Redux conventions | Don't reinvent a pub/sub store or re-derive memoized selectors from scratch. |
| ORM / database access | `drizzle-orm` (SQL-first, type-safe) or `prisma` (schema-first, larger ecosystem) | Hand-written SQL string concatenation for anything beyond a trivial query is both an injection risk and where this category's value is highest. |
| Authentication | `better-auth` (self-hosted, 2026 standard) or `next-auth`/Auth.js (Next.js-specific) or a managed provider (Clerk) when the project already uses one | Never hand-roll session/token issuance, password hashing, or OAuth flows — this is also a `security-and-hardening` concern, not just a reuse one. |
| Password hashing | `argon2` or `bcrypt` | Never a hand-rolled hash or a fast general-purpose hash (MD5/SHA-256 alone) for passwords. |
| Unique IDs | `nanoid` (short, URL-safe) or `uuid` (RFC4122 compliance needed) | Don't hand-write ID generation with `Math.random()`. |
| Background jobs / queues | `bullmq` (Redis-backed) or `agenda` (Mongo-backed) for Node; the platform's native queue (SQS, Cloud Tasks) when already on that cloud | Don't hand-roll a polling loop or in-memory job queue for anything that needs to survive a restart. |
| Scheduling (cron-style) | `node-cron` or the platform's native scheduler (e.g. cloud provider cron triggers) | — |
| Caching | `ioredis` client against Redis for shared/distributed cache; in-process `lru-cache` for single-process memoization | Don't hand-write a size-unbounded in-memory `Map` as a cache. |
| Rate limiting | `express-rate-limit`/framework equivalent, or `@upstash/ratelimit` for distributed/serverless | A `security-and-hardening` concern too — don't hand-roll a request counter without a proven sliding-window/token-bucket implementation. |
| Logging | `pino` (performance-focused) or `winston` (flexible transports) | Structured logging, not `console.log` sprinkled through the codebase. |
| CSV parsing/generation | `papaparse` (browser+Node) or `csv-parse`/`csv-stringify` (Node) | CSV has enough real-world quoting/encoding edge cases that hand-rolled split-on-comma parsing breaks on real data. |
| Excel files | `exceljs` | — |
| PDF generation | `pdf-lib` (create/modify) or `pdfkit` (generate from scratch) | — |
| Image processing (server) | `sharp` | Don't shell out to ImageMagick or hand-write resize/format-conversion logic. |
| File uploads (React UI) | `react-dropzone` for the drop-zone UI; `uploadthing` or the storage provider's own SDK for the upload pipeline | — |
| Markdown parsing/rendering | `remark`/`unified` (full pipeline) or `marked` (simple, fast) | — |
| Internationalization (React) | `react-i18next` (most common) or `lingui` (type-safe, build-time) | — |
| Money/currency arithmetic | `dinero.js` or integer-minor-units arithmetic (store cents, not floats) if no library is added | Never do currency math in floating point. |
| Email sending | `nodemailer` (SMTP) or a transactional provider's SDK (Resend, SendGrid, Postmark) | — |
| Payments | The payment processor's official SDK (e.g. Stripe's) | Never hand-roll card handling or PCI-sensitive logic — this is a hard `security-and-hardening` boundary, not a style choice. |
| CLI argument parsing | `commander` or `yargs` | Don't hand-parse `process.argv`. |
| End-to-end/UI testing | `playwright` (current default) or `cypress` | — |
| Component/unit testing (React) | `vitest`/`jest` + `@testing-library/react` | — |
| Utility functions (debounce, deep clone, groupBy, etc.) | Check native language/runtime features first (`structuredClone`, `Array.prototype.group`, `Object.groupBy`) before reaching for `lodash`; when a broad utility belt is genuinely needed, `lodash-es` (tree-shakeable) over full `lodash` in browser code | Don't hand-write a deep-clone or debounce implementation — these have known correctness pitfalls (circular refs, timer leaks). |

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It's just date math, I'll write a quick helper" | Date math is the single most common source of "quick helper" bugs — DST transitions, leap years, month-end arithmetic, timezone offsets. `date-fns`/`dayjs` exist because this is genuinely hard to get right by hand. |
| "Adding a dependency is more overhead than writing 20 lines" | The 20 lines rarely stay at 20 — they grow edge cases over the project's life, each one a custom bug a library's maintainers and user base already found and fixed. |
| "I don't know this library well enough to recommend it" | Naming the category and a reasonable default (with the note that it's a starting point) is still more useful than silently defaulting to hand-written logic. |
| "The user didn't ask for a specific library" | Recommending one is exactly the value a senior engineer adds unprompted — this is what distinguishes a technical plan from a bare feature description. |
| "This project doesn't have any dependencies for this category yet" | That's exactly when the plan should name one — a greenfield decision point, not a reason to assume hand-rolled is the default. |

## Red Flags

- A plan or spec describing logic in prose ("compare the dates and compute the difference") for something in the table above, with no library named
- A security-sensitive category (passwords, payments, auth, rate limiting) left as hand-rolled logic instead of a named library or SDK
- A new library proposed for a category the project already has a working dependency for
- A library recommendation made with no acknowledgment of a stated project constraint (bundle size, offline/vendored environment, dependency policy)
- Currency/money arithmetic done in floating point with no library or minor-units note

## Verification

- [ ] Every category from the table above that the feature actually touches has a named library in the plan/spec, not a prose description of hand-written logic
- [ ] Security-sensitive categories (auth, passwords, payments, rate limiting) use a named library/SDK, cross-referenced with `security-and-hardening`
- [ ] The project's existing dependencies were checked first — no second library proposed for a job an existing one already does
- [ ] Any stated project constraint (bundle size, dependency policy, offline environment) that rules out a recommended default is noted, with the custom alternative it forces made explicit
- [ ] No money/currency arithmetic in floating point
