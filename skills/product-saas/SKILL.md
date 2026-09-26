---
name: product-saas
description: Writes a whole-product PRD for a new app or product idea — starting from a problem statement and idea (optionally grounded in a comparable app the user has seen solve a similar problem, plus any context docs pointed at), gathers the project's fundamentals (app type, high-level tech stack) via AskUserQuestion, suggests a name for the product, proposes core features the user can accept, add to, or refine, lists the external integrations an MVP will need, searches the web for whatever current data or precedent would speed up shipping an MVP, and lays out the end-to-end build steps from this doc through launch. Use when asked to "write a product doc/PRD", "document this product idea", "I want to build something like X for my own use case", "what would an MVP for this look like", or before any feature-level PRD, spec, or scaffold exists for a new product.
---

# Product SaaS PRD

## Overview

Turns a problem + idea (optionally "I've seen an app like X, I want my own take on it for Y") into a single whole-product PRD: a concrete approach, fundamentals (app type, high-level stack), a suggested name, a confirmed feature list, external integrations, current web-grounded MVP guidance, and an end-to-end build roadmap. Sits upstream of `breakdown-feature-prd` and `project-scaffolding` — this skill decides *what the product is, what it's called, and what it needs*; it never writes a feature's full PRD detail or the actual scaffold, and doesn't fix which of those two comes first — the user's own sequencing choice, both are valid.

## When to Use

- A new product/app idea exists (a problem + an idea, optionally naming a comparable app already seen solving a similar problem, optionally with context docs — market notes, a brief, competitor research) and needs a single grounding document before any feature-level work starts
- The user wants a concrete approach, fundamentals (app type, stack direction), a suggested name, a feature list, external integrations, and an MVP-shaped build roadmap — not yet a per-feature PRD or an engineering spec
- NOT when the idea is still too vague to state as a problem — use `idea-refine` or `interview-me` first, then feed the result in as the idea/context here
- NOT for a per-feature requirements doc once the product's feature list is confirmed — use `breakdown-feature-prd` for each feature
- NOT for the actual folder structure, dependencies, or tooling — use `project-scaffolding` once the stack direction here is confirmed
- NOT for the engineering-facing spec of a specific feature — use `spec-driven-development`

## Process

### 1. Gather the problem, idea, comparable app, and any context

State back the problem and idea as understood. If the user names a comparable app they've seen solve a similar problem, note it explicitly — it's a primary input, not incidental color. Read whatever context docs the user points at (market notes, a brief, competitor notes, prior discussion) — never invent product context that isn't in the problem statement, the idea, a named comparable app, or a pointed-at doc.

### 2. Research the comparable app, if one was named

Use the `WebSearch` tool to find out what that app actually does — its core mechanism, how it solves the shared problem, its own feature set. Never analyze it from memory alone if it's a real, findable product; a stale or invented recollection of a competitor is exactly the kind of ungrounded advice this skill exists to avoid.

### 3. Frame the approach

Before any fundamentals or features, write a short **Approach** section that turns the problem + comparable app + the user's own use case into a concrete answer to three questions: what you can do (the core mechanism this product will use to solve the problem — what to take from the comparable app, what to deliberately do differently for this use case, and why), how to do it (the shape of the solution in plain terms, before any tech-stack or feature detail), and what you need (a preview of what Steps 4-6 will pin down — fundamentals, a name, features). This is the section that actually answers "I have a problem and a rough idea, help me turn it into something buildable" — treat it as the heart of the doc, not a preamble.

### 4. Check whether this is a refinement, not a fresh draft

Before drafting further, check whether `product/prd.md` already exists for this project. If it does, use the `AskUserQuestion` tool to confirm: refine the existing doc (add features, adjust fundamentals, update integrations) or start over — the same confirm-before-proceeding gate `breakdown-feature-prd` uses for its own refinement case. If refining, add or adjust only what the new request actually changes; don't silently discard sections the user didn't ask to touch.

### 5. Establish fundamentals

Ask (batched, via `AskUserQuestion`) whatever wasn't already stated directly:

- **App type** — web app, mobile app, desktop app, CLI, browser extension, or other (name it)
- **High-level tech stack direction** — a stated preference, or "no preference, recommend one" (if the latter, recommend one grounded in the app type and Approach section, and say why — never a default reached out of habit)

Keep this to the product-level decision only — the concrete framework/package-manager/monorepo-topology detail belongs to `project-scaffolding` once this direction is set, not here. Skip asking anything already stated.

### 6. Suggest a name

Propose 2-3 candidate names for the product, each grounded in the problem/Approach section (not generic or interchangeable with any other product), and briefly say why each fits. Confirm the choice with the user via `AskUserQuestion` — including an option for them to supply their own name instead of picking a suggestion. Don't check domain/trademark availability unless asked; that's outside this skill's scope.

### 7. Propose core features, then let the user extend or refine

Propose exactly two core features that most directly solve the stated problem — the smallest set that makes the product real, not a wishlist. Then ask (via `AskUserQuestion`) whether to add more, and keep adding one round at a time until the user confirms the list is complete. Each feature gets a name and a one- or two-sentence description here — full Problem/Solution/Requirements/Acceptance-Criteria detail is `breakdown-feature-prd`'s job downstream, not this doc's.

### 8. List external integrations

From the confirmed app type, stack direction, and feature list, name each external integration the MVP will actually need (auth provider, payment processor, email/SMS, push notifications, maps, storage/CDN, analytics, etc.) — only ones the feature list actually implies, never a generic checklist padded with unused integrations. For each: why it's needed, and which specific provider/service is recommended.

### 9. Search the web for current MVP-shaping data

Use the `WebSearch` tool to ground the recommendations above and the roadmap in Step 10 — current SDK/API options and pricing for the named integrations, and any current platform-specific constraint (e.g. mobile app store review requirements) that would change scope or sequencing. This is distinct from Step 2's comparable-app research — that one grounds the *approach*, this one grounds the *build*. Cite what was found; flag anything time-sensitive (pricing, API versions) as worth re-checking before it's acted on. Never substitute memorized/stale knowledge for a search when the information could plausibly have changed.

### 10. Lay out the build steps, start to finish

Write an ordered, numbered roadmap from this doc through launch, grounded in the actual app type, stack direction, and feature list confirmed above — never a generic project-lifecycle template. Point to the actual next skill at each relevant step (`project-scaffolding` to set up the stack, `breakdown-feature-prd` per feature, `spec-driven-development` and/or `planning-and-task-breakdown` to get to implementable tasks, `incremental-implementation`/`test-driven-development` to build, `ci-cd-and-automation` and `shipping-and-launch` to ship) rather than restating what those skills already own in detail. `project-scaffolding` and `breakdown-feature-prd` don't have a fixed order relative to each other — scaffold first then write per-feature PRDs, or write per-feature PRDs first then scaffold against them, are both valid; note this explicitly rather than presenting one fixed sequence as the only path.

### 11. Save the doc

Save to `product/prd.md` under the project's external output location (see `references/external-output-paths.md`) — outside the project's own repo, never a path git in this project tracks or ignores. Step 4 already covers the case where this file already exists.

### 12. Report back

Tell the user the full path written and the confirmed product name. Note that the confirmed feature list is ready to hand to `breakdown-feature-prd` one feature at a time, that the stack direction is ready to hand to `project-scaffolding`, and that either can go first.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll propose five features to be thorough" | The point of starting at two is forcing the smallest real version of the product — a longer list is the user's call to make via the follow-up round, not the default opening offer. |
| "I can skip the tech stack question, web app is the obvious default" | App type doesn't imply a stack — ask, or use the user's stated preference; guessing here cascades into a wrong scaffold and wrong integration list later. |
| "I'll list every integration a product like this might ever want" | Only integrations the confirmed feature list actually implies belong here — a padded list buries the ones that matter and reads as generic rather than grounded in this product. |
| "I already know how the comparable app works, I don't need to look it up" | A comparable app is real, checkable information — search it rather than recalling a possibly outdated or invented picture of what it does. |
| "I already know the current pricing/API options for this kind of integration" | Pricing, SDKs, and platform requirements change — search before recommending, don't recall from training data as if it were current. |
| "I'll write the full feature detail here since I'm already thinking about it" | Problem/Solution/Requirements/Acceptance-Criteria detail belongs to `breakdown-feature-prd` per feature — duplicating it here creates two documents that can drift out of sync. |
| "I'll just pick a name myself, it's a small detail" | The name is one of the concrete things the user asked this skill to help produce — suggest candidates and confirm, don't decide it unilaterally. |
| "Scaffolding obviously comes before feature PRDs (or vice versa)" | Both orders are legitimate — presenting one as the only path forecloses a choice that's actually the user's to make. |
| "The roadmap can just be a generic list of phases" | A roadmap not grounded in the actual stack/feature list reads as boilerplate and doesn't tell the user what to actually do next — name the real next skill at each step. |
| "I'll just re-draft the whole doc since there's a new feature to add" | Refining adds or adjusts what the request actually changes — a full re-draft risks silently losing fundamentals, name, or integrations already confirmed. |

## Red Flags

- A named comparable app analyzed from memory instead of an actual web search
- No Approach section, or one written before/without the comparable-app research that was supposed to ground it
- Fundamentals (app type, stack direction) assumed instead of asked
- A name chosen and stated as final without offering candidates or confirming with the user
- More than two features proposed before the user had a chance to confirm or extend the initial two
- An integration listed that no confirmed feature actually needs
- Integration or MVP guidance stated as current fact without a web search backing it
- The build roadmap presents `project-scaffolding` and `breakdown-feature-prd` as a fixed sequence instead of either order
- The build roadmap is a generic phase list not grounded in this product's actual stack and features
- Full feature-level PRD detail (personas, acceptance criteria) written into this doc instead of deferred to `breakdown-feature-prd`
- `product/prd.md` re-drafted from scratch when the actual request was adding or adjusting one thing
- Refinement proceeded without confirming via `AskUserQuestion` first

## Verification

- [ ] The problem, idea, any named comparable app, and any pointed-at context docs were read before drafting — nothing invented
- [ ] A comparable app, if named, was actually researched via `WebSearch` — not recalled from memory
- [ ] An Approach section states what to do, how, and why — grounded in the problem, the comparable app (if any), and the user's own use case
- [ ] Existing `product/prd.md` was checked first; refinement (if applicable) was confirmed via `AskUserQuestion`
- [ ] App type and tech stack direction were established via `AskUserQuestion` (or already stated), not assumed
- [ ] 2-3 name candidates were proposed and confirmed with the user (or the user's own name was used) — not decided unilaterally
- [ ] Exactly two core features were proposed first, with a follow-up round for the user to add or confirm more
- [ ] Each listed feature has a name and a one- or two-sentence description — not full PRD-level detail
- [ ] External integrations trace to the confirmed feature list, each with a reason and a recommended provider
- [ ] The `WebSearch` tool was actually used to ground integration and MVP guidance in current information, not recalled from memory
- [ ] The build roadmap is ordered, grounded in this product's real stack/features, names the actual next skill at each relevant step, and doesn't force one fixed order between `project-scaffolding` and `breakdown-feature-prd`
- [ ] Saved to `product/prd.md` in the project's external output location (see `references/external-output-paths.md`)
- [ ] The user was told the full path written and the confirmed product name

## See Also

- `idea-refine` / `interview-me` — upstream, if the idea is still too vague to state as a problem
- `breakdown-feature-prd` — downstream, expands each listed feature into its own full PRD
- `project-scaffolding` — downstream, sets up the actual folder structure/tooling for the confirmed stack direction
- `spec-driven-development` / `planning-and-task-breakdown` — further downstream, once a feature has its own PRD
- `references/external-output-paths.md` — where this skill's output lives
