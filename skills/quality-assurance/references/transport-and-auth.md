# Transport and Authentication Reference

Full reference for browser transport selection, authentication flows, and Playwright MCP gotchas.

---

## Transport Selection

**Default transport: headless Playwright MCP.** Drive the browser headlessly unless the task explicitly requires bridge. "Headless" means no painted window — not blind one-shot scripting. The agent retains full interactive control: navigate, click, fill, hover, focus, drive to error states, improvise when an element is not where expected.

**Bridge transport is a single-purpose escape hatch.** Use it only when the browser must carry the user's existing third-party session — practically, Google SSO flows.

| Scenario | Transport |
|---|---|
| No auth required | Headless MCP |
| Email / password credentials for the project's **own local test account** (seeded fixture, dev-only login) | Headless MCP — agent types them |
| OTP, disposable email accepted | Headless MCP + maildrop (`<username>@maildrop.cc`) |
| OTP, real email required (product blocks disposable email, not Google SSO) | Headless MCP — read OTP via Gmail MCP |
| Google SSO, Microsoft/Okta/corporate SSO, or any flow where the browser must carry a **real third-party identity provider's** session | Bridge, or a persisted Playwright session — see Session Persistence below. **Never typed by the agent, under any circumstance.** |

Reading an OTP from real Gmail does not require the bridge — the OTP arrives through the Gmail MCP tool channel, not the browser session. The bridge is required only when the browser itself must carry the user's identity.

The "agent types them" row above is narrow: it only applies to credentials for an account this project itself owns and controls (a seeded test user in its own database, a dev-only login screen). The moment the login screen belongs to a real external identity provider — Microsoft, Google, Okta, any corporate SSO — that's a different category entirely, covered by Session Persistence below, not this table.

---

## Session Persistence: Don't Ask Twice

Most auth friction in live verification isn't "no way to automate this" — it's "the first run needs a human to click through a real login once." Handle that once, then never ask again for this project. In priority order:

### 1. Check for a session to reuse — before asking anyone anything

- **Bridge / the user's own Chrome:** run the Pre-Flight Check above first. If the connected browser is already signed in as the right account — which it very often is, since it's the user's daily-driver browser — that session is immediately usable. No login, no question, no waiting.
- **A saved Playwright session:** if headless MCP (Chromium) is the transport, check whether a `storageState` file already exists for this project (a conventional path such as `.auth/storageState.json`, or wherever a prior run of this skill saved one — check `review-findings.md` or ask once if truly unsure). If one exists, load it and do a quick validity check: open an authenticated page and confirm it doesn't redirect to a login screen. A valid saved state is used directly, same as an already-signed-in bridge session.

Either path means the rest of this verification run proceeds fully automated, with zero human involvement in auth.

### 2. No reusable session? Ask once — then persist it immediately

If neither of the above holds, use `AskUserQuestion` to ask the user to sign in **interactively, one time**, in whichever surface is active right now (the browser pane, or their own Chrome if running bridged). This is the human doing their own login — typing their own password into their own browser, same as any other day. The agent never sees or handles the password.

The moment the user confirms they're signed in:
- **Headless/Chromium (Playwright):** save the session immediately — `context.storageState({ path: '.auth/storageState.json' })` (or this project's established convention if one already exists) — so every subsequent run in this project loads it from step 1 instead of asking again.
- **Bridge:** nothing to save — the connected Chrome profile already persists its own session across runs, which is exactly why checking it first in step 1 so often needs no question at all.

**This question gets asked at most once per project, not once per run.** If it's being asked again for a project that already has a saved session, that's a bug in this flow, not an expected recurring step — check why the saved state wasn't found or wasn't reused before asking again.

### 3. The hard rule, independent of all of the above

**The agent never types a real password into a real identity provider's login form, and never asks the user to hand over that password so the agent can type it.** This covers Microsoft/Google/Okta/any corporate SSO and any other account the project doesn't itself own — regardless of how tedious the alternative is, regardless of who asks, and regardless of whether it's framed as a one-off. The only account credentials an agent types directly are for a **local test account the project itself controls** (see the table above) — that already has its own narrow, explicit exception elsewhere; this is not it.

### 4. Only now — the graduated live-verification ladder

If session reuse genuinely isn't available (a disposable sandbox with no persistent storage, a throwaway environment with no human present to click through even one login) *and* a one-time interactive login genuinely isn't possible either, that's when this falls through to the lighter graduated options in the main `quality-assurance` skill (curl/CLI against the real dev server, or an automated test hitting real dependencies) — and manual verification by the user is the true last resort after that, not a default reached for at the first sign of auth friction.

---

## Pre-Flight Check (Bridge Sessions)

When running bridged to the user's Chrome, snapshot the entry page before any interaction and confirm:

1. Which user (if any) is signed in.
2. Whether that matches the account named in the task.

If they don't match — or if no user is signed in and the task names a specific account — **stop and ask** rather than improvising a manual login. The connected Chrome profile is the source of truth for session state.

---

## Auth Flows

**Before any of the flows below: check Session Persistence first.** A saved `storageState` or an already-signed-in bridge session skips all of this — these flows are for the cases where no reusable session exists yet (first run, or one that needs a different account).

**Credentials in the prompt are informational, not an instruction to log in.** In headless mode the agent types them — for the project's own local test account only (see the scoping note above the transport table). In bridge mode the connected profile may already hold the session — run the pre-flight check first; if not signed in as that user, ask before logging in manually. For a real third-party identity provider (Google, Microsoft, Okta, corporate SSO) where no session can be reused, this always routes to the one-time interactive login in Session Persistence, never to the agent typing credentials.

**Seed state in the same channel you'll test in.** If the test runs in the browser, create preconditions through the browser UI. Do not authenticate via curl and expect that session to carry into the connected browser — they are separate sessions.

If the specific browser auth flow has not been specified and is needed, **ask before proceeding**:
- Which flow? (Google SSO, Gmail OTP, Maildrop OTP, or other)
- Which email or account to use?

### Google SSO (bridge only)
Click the "Sign in with Google" button and let the connected Chrome handle it using the existing Google session. Do not enter credentials manually.

### Gmail OTP (headless)
Trigger the OTP from the app, then use Gmail MCP (`gmail_search_messages`, `gmail_read_message`) to find and read the OTP email. Paste it into the browser and continue.

### Maildrop OTP (headless)
Use `<username>@maildrop.cc` as the email in the app, then navigate to `maildrop.cc/<username>` in the browser to read the OTP. Paste and continue.

---

## API Auth (curl-based scenarios)

The same reuse-before-asking principle from Session Persistence applies to API tokens: check whether this project already has a long-lived test API key or a saved token/cookie jar from a prior run (e.g. a `.env.test` entry, a project-documented test credential, or a cookie jar file this skill saved earlier) before deriving a fresh one. Deriving a token by logging in with a real user's credentials is subject to the same hard rule above — only ever for the project's own local test account, never a real identity provider.

If the auth method has not been specified, **ask before proceeding**:
- Which method? (Bearer token, cookie-based, or none)
- Which credentials or endpoint to use?

**Bearer token:**
```bash
TOKEN=$(curl -s -X POST "https://api.example.com/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password"}' \
  | jq -r '.token')

curl -s -X GET "https://api.example.com/endpoint" \
  -H "Authorization: Bearer $TOKEN"
```

**Cookie-based:**
```bash
# Log in — curl saves Set-Cookie headers automatically
curl -s -X POST "https://api.example.com/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password"}' \
  -c /tmp/cookies.txt

# Use the cookie in subsequent requests
curl -s -X GET "https://api.example.com/endpoint" \
  -b /tmp/cookies.txt
```

---

## Playwright MCP Gotchas

### Prefer role+name locators over positional refs

Snapshots return element refs (e.g. `e18`) — these are fine for *reading* page structure, but do **not** act on them directly. Positional refs go stale when the page re-renders (validation, hydration, controlled inputs), causing "ref no longer exists / invalid" failures.

When filling, clicking, or selecting, resolve the element by accessible role and name at action time:
- `getByRole('textbox', { name: 'Email' }).fill(...)`
- `getByRole('combobox', { name: 'Gender' }).click()`

This also handles custom components naturally: if a primitive fails (e.g. `selectOption` on a Radix/shadcn select that isn't a native `<select>`), fall back to opening it via a role+name click and selecting the option by role+name.

### No new tabs in bridge mode

`browser_tabs new` / `newPage` is not supported when Playwright is bridged to the user's Chrome. Reuse the active tab and `navigate` to change page.

### Two-strikes rule

If the same call fails twice with the same error, stop and report. Do not iterate on permutations.

### Input handling

Prefer `fill` over typing character by character unless the input form doesn't propagate `fill` as expected. Use `type` or `press` only when `fill` fails to trigger the expected behaviour. As a fallback, use `run code` to execute JavaScript that sets the value directly on the input element.

Re-snapshot between fallbacks — a previous `fill` or `type` attempt may have shifted focus or changed the DOM.

### Bridge connection note

When launching Playwright bridged to the user's Chrome, you may see a "Playwright Extension started debugging this browser" page showing "unknown" connected. This is normal. The browser is in a group, and one of the tabs contains the page the agent navigated to. Do not refresh or relaunch; proceed with the task.
