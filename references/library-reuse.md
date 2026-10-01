# Library Reuse: Prefer a Proven Dependency Over Custom Code

## Overview

A huge share of "implementation work" is solving a problem that a well-maintained, widely-used library already solves correctly — date arithmetic, schema validation, HTTP retries, password hashing, CSV parsing, PDF generation, rate limiting. Writing it by hand isn't a sign of rigor; it's usually a sign the alternative wasn't considered. Custom code for a solved problem means custom bugs, custom edge cases (timezones, locale, Unicode, leap years, encoding), and an ongoing maintenance cost the library's maintainers already absorbed.

**This applies in every language and ecosystem, not only JavaScript/TypeScript.** The categories below (date/time, validation, HTTP, ORM, auth, background jobs, and the rest) are universal software problems — every ecosystem has its own standard answer to each one. A Python repo reaches for `pydantic`/`httpx`/SQLAlchemy where a Node repo reaches for `zod`/`axios`/Prisma; a C#/.NET repo reaches for `FluentValidation`/`HttpClient`+Polly/EF Core. The category is the same, the idiomatic library is whatever that project's ecosystem actually uses.

## Step 0: Determine the Language and Ecosystem First

Before naming any library, resolve the project's actual language, runtime, and framework the same way `breakdown-feature-implementation`/`spec-driven-development` resolve the stack — stated directly, detected from the codebase (lockfiles, manifest files, import statements, existing dependencies), or asked about on a greenfield project. Never default to a JS/TS recommendation because it's the most familiar one — the category table below is organized so each row names the idiomatic choice per ecosystem, and only the one matching this project's actual language belongs in the plan/spec.

Quick ecosystem tells, when detecting from an existing codebase:

| Signal | Ecosystem |
|---|---|
| `package.json`, `.ts`/`.js` files, `node_modules` | Node.js / JavaScript / TypeScript |
| `pyproject.toml`, `requirements.txt`, `.py` files | Python |
| `.csproj`/`.sln`, `.cs` files | C# / .NET |
| `go.mod`, `.go` files | Go |
| `pom.xml`/`build.gradle`, `.java`/`.kt` files | Java / Kotlin |
| `Gemfile`, `.rb` files | Ruby |
| `Cargo.toml`, `.rs` files | Rust |
| `composer.json`, `.php` files | PHP |

If the project spans more than one (a polyglot repo — e.g. a Python backend with a TypeScript frontend), resolve the ecosystem *per component* the plan/spec section is actually describing, not once for the whole document.

## The Rule

When a plan, spec, or design doc calls for logic in one of the categories below, name the specific library (in this project's actual ecosystem) to use for it, not a description of the logic to hand-write. Only write custom code when:

- The need is a few lines of straightforward, boundary-free logic (e.g. `max(a, b)`, a one-line string template) — not worth a dependency.
- No category below actually fits — the need is genuinely domain-specific business logic, not a solved general problem.
- The project has an explicit, stated constraint against adding dependencies (bundle-size budget, vendored/offline environment, a security policy restricting third-party code, a language's standard library already covers it without one) — note the constraint and the custom alternative it forces, don't silently add a library when one was ruled out or isn't needed.
- An equivalent library is already a dependency in the project — use what's already there over introducing a second library for the same job, even if this reference recommends a different default.

## Decision Heuristic (When Choosing Among Options)

Prefer, in rough order:

1. **Actively maintained** — recent releases, open issues getting addressed, not abandoned.
2. **Widely adopted in this project's ecosystem** — high download/usage counts within that language's community is a proxy for battle-testing, not a goal in itself; "most popular overall" across languages is meaningless, it has to be popular *for this stack*.
3. **Idiomatic for the language/framework** — fits that ecosystem's conventions (e.g. a Python project typically composes smaller libraries like `httpx`+`pydantic`; a .NET project leans on first-party `Microsoft.Extensions.*` packages where they exist).
4. **Matches the project's existing stack** — a Zod-validated Node project adding Yup for one new feature, or a Pydantic-validated Python project adding a second validation library, is a worse choice than consistency, even if the alternative is otherwise fine.
5. **Resource footprint appropriate to where it runs** — bundle size matters for anything shipped to a browser; it's close to irrelevant for a server-side batch job. Note this tradeoff explicitly when it's relevant.
6. **License compatible with the project** — flag anything GPL/AGPL (or LGPL for a statically-linked/commercial context) rather than assuming it's fine.

## Categories and Current Defaults, by Ecosystem

These are starting points, not mandates — confirm against what the project already uses first, and treat this table as something to refresh periodically since libraries and ecosystems move.

| Category | Node / JS / TS | Python | C# / .NET | Go | Notes |
|---|---|---|---|---|---|
| Date/time math & formatting | `date-fns` or `dayjs` | `pendulum` or `arrow`; stdlib `datetime`+`zoneinfo` for simple cases | `NodaTime` | stdlib `time` (generally sufficient) | Never hand-roll date arithmetic, timezone conversion, or "days between dates" — DST, leap years, and locale are real edge cases every one of these libraries already handles. |
| Schema/input validation | `zod` or `valibot` (bundle-size-sensitive client code) | `pydantic` | `FluentValidation` or Data Annotations | stdlib + `validator`/`go-playground/validator` | Validate at every boundary (API input, env vars, form submission) through one schema library, not ad hoc `if` chains re-deriving the same checks. |
| HTTP client | `axios` or `ky`/`ofetch` | `httpx` (async-capable, `requests`-like) | `HttpClient` + `Polly` (retries/circuit breaker) or `Refit` (typed client) | stdlib `net/http` + `go-resty/resty` for ergonomics | Don't hand-write retry/timeout/interceptor logic around a raw HTTP call — that's exactly what these exist for. |
| Forms (web UI) | `react-hook-form` (+ `zodResolver`) | — (typically handled server-side or by the frontend framework) | ASP.NET Core model binding + Data Annotations/FluentValidation | — | — |
| ORM / database access | `drizzle-orm` or `prisma` | `SQLAlchemy` (Core or ORM) | `Entity Framework Core` or `Dapper` (lighter, SQL-first) | `sqlc` or `gorm` | Hand-written SQL string concatenation for anything beyond a trivial query is both an injection risk and where this category's value is highest. |
| Authentication | `better-auth`, Auth.js, or a managed provider (Clerk) | `authlib` or the framework's own (Django auth, FastAPI + `fastapi-users`) | ASP.NET Core Identity | — (compose from OAuth2 libraries + the platform's identity provider) | Never hand-roll session/token issuance, password hashing, or OAuth flows — a `security-and-hardening` concern as much as a reuse one. |
| Password hashing | `argon2` or `bcrypt` (npm packages) | `passlib` (or `argon2-cffi` directly) | ASP.NET Core Identity's built-in hasher, or `BCrypt.Net` | `golang.org/x/crypto/bcrypt` | Never a hand-rolled hash or a fast general-purpose hash (MD5/SHA-256 alone) for passwords. |
| Unique IDs | `nanoid` or `uuid` | stdlib `uuid` | `Guid` (BCL) | stdlib `google/uuid` | Don't hand-write ID generation with a bare random-number call. |
| Background jobs / queues | `bullmq` (Redis) or `agenda` (Mongo) | `celery` (standard; needs a broker, usually Redis) | `Hangfire` | platform-native (Cloud Tasks/SQS) or `asynq` | Don't hand-roll a polling loop or in-memory job queue for anything that needs to survive a restart. |
| Scheduling (cron-style) | `node-cron` | `celery beat` or `APScheduler` | `Hangfire` recurring jobs or `Quartz.NET` | platform-native scheduler or `robfig/cron` | — |
| Caching | `ioredis` (shared) / `lru-cache` (in-process) | `redis-py` (shared) / `cachetools` (in-process) | `Microsoft.Extensions.Caching.*` (in-process or distributed Redis) | `go-redis` / in-process `sync.Map`-based LRU | Don't hand-write a size-unbounded in-memory map as a cache. |
| Rate limiting | `express-rate-limit` or `@upstash/ratelimit` (distributed) | `slowapi` (FastAPI) or `django-ratelimit` | `Microsoft.AspNetCore.RateLimiting` (first-party) | `golang.org/x/time/rate` | A `security-and-hardening` concern too — don't hand-roll a request counter without a proven sliding-window/token-bucket implementation. |
| Logging | `pino` or `winston` | stdlib `logging` + `structlog` for structured logs | `Serilog` | stdlib `log/slog` | Structured logging, not string concatenation sprinkled through the codebase. |
| CSV parsing/generation | `papaparse` or `csv-parse`/`csv-stringify` | stdlib `csv` | `CsvHelper` | stdlib `encoding/csv` | CSV has enough real-world quoting/encoding edge cases that hand-rolled split-on-comma parsing breaks on real data. |
| Excel files | `exceljs` | `openpyxl` | `ClosedXML` or `EPPlus` | `excelize` | — |
| PDF generation | `pdf-lib` or `pdfkit` | `reportlab` or `weasyprint` (HTML-to-PDF) | `QuestPDF` | `gofpdf` | — |
| Image processing (server) | `sharp` | `Pillow` | `ImageSharp` | `imaging` or stdlib `image` | Don't shell out to ImageMagick or hand-write resize/format-conversion logic when a library already wraps it safely. |
| Markdown parsing/rendering | `remark`/`unified` or `marked` | `markdown-it-py` or `mistune` | `Markdig` | `goldmark` | — |
| Internationalization | `react-i18next` or `lingui` | `gettext`/Babel (Django/Flask integrations) | `Microsoft.Extensions.Localization` | — | — |
| Money/currency arithmetic | `dinero.js`, or integer minor-units if no library | `py-moneyed` or integer minor-units | `decimal` (BCL, for precision) or integer minor-units | integer minor-units (`int64` cents) | Never do currency math in floating point, in any language. |
| Email sending | `nodemailer` or a transactional provider SDK (Resend, SendGrid, Postmark) | `smtplib`-based wrapper or the provider's SDK | `MailKit` or the provider's SDK | provider's SDK | — |
| Payments | The payment processor's official SDK (e.g. Stripe's) in whichever language it ships for | same | same | same | Never hand-roll card handling or PCI-sensitive logic — a hard `security-and-hardening` boundary, not a style choice, in any language. |
| CLI argument parsing | `commander` or `yargs` | `click` or `typer` | `System.CommandLine` | `cobra` or `urfave/cli` | Don't hand-parse raw argv. |
| End-to-end/UI testing | `playwright` or `cypress` | `playwright` (Python bindings) | `Playwright for .NET` | `playwright-go` or `rod` | — |
| Component/unit testing | `vitest`/`jest` + `@testing-library/react` | `pytest` | `xUnit`/`NUnit` + `FluentAssertions` | stdlib `testing` + `testify` | — |
| Resilience (retry/circuit-breaker) | `cockatiel` or a retry wrapper around `axios`/`ky` | `tenacity` | `Polly` | `sethvargo/go-retry` | Don't hand-write retry-with-backoff loops — they have real failure modes (thundering herd, unbounded retry) these libraries already guard against. |
| Utility functions (debounce, deep clone, groupBy, etc.) | Check native features first (`structuredClone`, `Object.groupBy`); `lodash-es` when a broad belt is genuinely needed | stdlib `itertools`/`functools`; `more-itertools` for the rest | LINQ (BCL) covers most of this already | stdlib `slices`/`maps` packages | Don't hand-write a deep-clone or debounce implementation — these have known correctness pitfalls (circular refs, timer leaks) regardless of language. |

For a language or framework not in this table (Rust, PHP, Swift, Kotlin/Android, etc.), apply the same method: identify the category, then find that ecosystem's own standard answer — it almost always has one — rather than defaulting to a library from a different language's ecosystem or writing custom code because this table doesn't happen to list it.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It's just date math, I'll write a quick helper" | Date math is the single most common source of "quick helper" bugs — DST transitions, leap years, month-end arithmetic, timezone offsets — in every language. Every ecosystem's date library exists because this is genuinely hard to get right by hand. |
| "Adding a dependency is more overhead than writing 20 lines" | The 20 lines rarely stay at 20 — they grow edge cases over the project's life, each one a custom bug a library's maintainers and user base already found and fixed. |
| "I don't know this library well enough to recommend it" | Naming the category and a reasonable default for this project's actual ecosystem (with the note that it's a starting point) is still more useful than silently defaulting to hand-written logic. |
| "The user didn't ask for a specific library" | Recommending one is exactly the value a senior engineer adds unprompted — this is what distinguishes a technical plan from a bare feature description. |
| "This project doesn't have any dependencies for this category yet" | That's exactly when the plan should name one — a greenfield decision point, not a reason to assume hand-rolled is the default. |
| "This is a Node project so I'll use the JS/TS defaults everywhere" | Only after confirming the ecosystem. A plan for a Python service, a C# service, or a polyglot repo needs the library idiomatic to *that* component, not a JS/TS default applied out of habit. |

## Red Flags

- A plan or spec describing logic in prose ("compare the dates and compute the difference") for something in the table above, with no library named
- A JS/TS library recommended for a non-JS/TS project (or vice versa) because the ecosystem wasn't actually checked
- A security-sensitive category (passwords, payments, auth, rate limiting) left as hand-rolled logic instead of a named library or SDK
- A new library proposed for a category the project already has a working dependency for
- A library recommendation made with no acknowledgment of a stated project constraint (bundle size, offline/vendored environment, dependency policy)
- Currency/money arithmetic done in floating point with no library or minor-units note

## Verification

- [ ] The project's actual language/ecosystem was resolved (stated, detected, or asked about) before any library was named — never assumed to be JS/TS by default
- [ ] Every category from the table above that the feature actually touches has a named library idiomatic to this project's ecosystem, not a prose description of hand-written logic
- [ ] Security-sensitive categories (auth, passwords, payments, rate limiting) use a named library/SDK, cross-referenced with `security-and-hardening`
- [ ] The project's existing dependencies were checked first — no second library proposed for a job an existing one already does
- [ ] Any stated project constraint (bundle size, dependency policy, offline environment) that rules out a recommended default is noted, with the custom alternative it forces made explicit
- [ ] No money/currency arithmetic in floating point
