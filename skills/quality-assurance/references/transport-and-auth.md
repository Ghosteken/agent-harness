# Transport and Authentication Reference

Full reference for browser transport selection, authentication flows, and Playwright MCP gotchas.

---

## Transport Selection

**Default transport: headless Playwright MCP.** Drive the browser headlessly unless the task explicitly requires bridge. "Headless" means no painted window — not blind one-shot scripting. The agent retains full interactive control: navigate, click, fill, hover, focus, drive to error states, improvise when an element is not where expected.

**Bridge transport is a single-purpose escape hatch.** Use it only when the browser must carry the user's existing third-party session — practically, Google SSO flows.

| Scenario | Transport |
|---|---|
| No auth required | Headless MCP |
| Email / password credentials | Headless MCP — agent types them |
| OTP, disposable email accepted | Headless MCP + maildrop (`<username>@maildrop.cc`) |
| OTP, real email required (product blocks disposable email, not Google SSO) | Headless MCP — read OTP via Gmail MCP |
| Google SSO, or any flow where the browser must carry an authenticated third-party session | Bridge only |

Reading an OTP from real Gmail does not require the bridge — the OTP arrives through the Gmail MCP tool channel, not the browser session. The bridge is required only when the browser itself must carry the user's identity.

---

## Pre-Flight Check (Bridge Sessions)

When running bridged to the user's Chrome, snapshot the entry page before any interaction and confirm:

1. Which user (if any) is signed in.
2. Whether that matches the account named in the task.

If they don't match — or if no user is signed in and the task names a specific account — **stop and ask** rather than improvising a manual login. The connected Chrome profile is the source of truth for session state.

---

## Auth Flows

**Credentials in the prompt are informational, not an instruction to log in.** In headless mode the agent types them. In bridge mode the connected profile may already hold the session — run the pre-flight check first; if not signed in as that user, ask before logging in manually.

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
