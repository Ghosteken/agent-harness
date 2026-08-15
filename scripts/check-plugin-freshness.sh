#!/usr/bin/env bash
# Verifies that the committed agent-harness.plugin bundle is fresh and lean:
#   - contains no archive/ entries (pre-prune bulk content must never ship)
#   - contains no local-only settings files
#   - its skills/*/SKILL.md count matches the live skills/ directory exactly
#     (catches "skills changed but the plugin wasn't rebuilt")
#   - stays under a sane size ceiling (catches silent re-bloat regressions)
#
# Usage: bash scripts/check-plugin-freshness.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
PLUGIN="${REPO_ROOT}/agent-harness.plugin"
MAX_SIZE_MB=10

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

[[ -f "$PLUGIN" ]] || fail "agent-harness.plugin not found at repo root. Run scripts/build-plugin.sh (or .ps1) and commit the result."

LISTING="$(unzip -l "$PLUGIN")" || fail "agent-harness.plugin is not a valid zip archive. Rebuild with scripts/build-plugin.sh (or .ps1)."

# 1. No archive/ content
if grep -qE '[[:space:]]archive[/\\]' <<< "$LISTING"; then
  fail "agent-harness.plugin contains archive/ entries — pre-prune bulk-import content must be excluded. Rebuild with the current scripts/build-plugin.sh."
fi

# 2. No local-only settings files
if grep -qi 'settings\.local' <<< "$LISTING"; then
  fail "agent-harness.plugin contains a settings.local file — local-only config must never ship. Rebuild with the current scripts/build-plugin.sh."
fi

# 3. Skill count matches the live tree exactly
ZIPPED_SKILL_COUNT="$(grep -cE '[[:space:]]skills[/\\][^/\\]+[/\\]SKILL\.md$' <<< "$LISTING" || true)"
LIVE_SKILL_COUNT="$(find "${REPO_ROOT}/skills" -mindepth 2 -maxdepth 2 -name 'SKILL.md' | wc -l)"

if [[ "$ZIPPED_SKILL_COUNT" -ne "$LIVE_SKILL_COUNT" ]]; then
  fail "agent-harness.plugin has ${ZIPPED_SKILL_COUNT} skill(s) bundled but skills/ currently has ${LIVE_SKILL_COUNT}. The plugin is stale — rebuild with scripts/build-plugin.sh (or .ps1) and commit the result."
fi

# 4. Size ceiling
SIZE_BYTES="$(stat -c%s "$PLUGIN" 2>/dev/null || stat -f%z "$PLUGIN")"
SIZE_MB=$(( SIZE_BYTES / 1024 / 1024 ))
if (( SIZE_MB > MAX_SIZE_MB )); then
  fail "agent-harness.plugin is ${SIZE_MB}MB, exceeding the ${MAX_SIZE_MB}MB ceiling — likely shipping content that should be excluded (check archive/, node_modules, or other bulk directories). Rebuild with the current scripts/build-plugin.sh."
fi

echo "OK: agent-harness.plugin is fresh (${ZIPPED_SKILL_COUNT} skills bundled, ${SIZE_MB}MB, no archive/ or settings.local content)."
