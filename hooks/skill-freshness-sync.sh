#!/bin/bash
# agent-harness PreToolUse hook — fires before every Skill tool call, in any
# project, as long as this plugin is installed.
#
# Problem: the Skill tool serves content from the *installed* plugin copy
# (CLAUDE_PLUGIN_ROOT). Editing a SKILL.md in the dev repo has no effect on
# what Skill actually returns until the .plugin zip is rebuilt and
# reinstalled — see scripts/build-plugin.ps1 / .sh.
#
# Fix: before Skill reads a skill's content, resync that skill's directory
# into the installed copy from a fixed dev-repo source, so edits made there
# take effect immediately, from any project, without a rebuild/reinstall.
#
# Source repo resolution (first match wins):
#   1. $AGENT_HARNESS_SOURCE_REPO env var, if set
#   2. The hardcoded default below
# Update the default (or set the env var) if the dev repo ever moves.
#
# No-op, safely, if the source repo isn't present on this machine (e.g. a
# teammate without the dev repo checked out) — installed content is served
# as-is in that case.
#
# No jq dependency (not guaranteed present, e.g. plain Windows Git Bash) —
# JSON fields are pulled with grep/sed, which is safe here since we only
# need flat string values with no embedded quotes/escapes.

set -euo pipefail

DEFAULT_SOURCE_REPO="/c/Users/aigbe/Documents/agent-harness"
SOURCE_REPO="${AGENT_HARNESS_SOURCE_REPO:-$DEFAULT_SOURCE_REPO}"

if [ -t 0 ]; then INPUT="{}"; else INPUT=$(cat); fi

json_str_field() {
  # $1 = field name, $2 = JSON text
  printf '%s' "$2" | grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 \
    | sed -E "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"([^\"]*)\"/\1/"
}

SKILL_ARG=$(json_str_field "skill" "$INPUT")
[ -n "$SKILL_ARG" ] || exit 0

# Strip an optional "plugin-name:" prefix (e.g. "agent-harness:foo" -> "foo")
SKILL_NAME="${SKILL_ARG##*:}"

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-}"
[ -n "$PLUGIN_ROOT" ] || exit 0
[ -d "$SOURCE_REPO" ] || exit 0
[ "$SOURCE_REPO" != "$PLUGIN_ROOT" ] || exit 0

# Guard: confirm SOURCE_REPO is actually agent-harness (not some other repo
# that happens to sit at that path, e.g. after a machine reconfig).
MANIFEST="${SOURCE_REPO}/.claude-plugin/plugin.json"
[ -f "$MANIFEST" ] || exit 0
NAME=$(json_str_field "name" "$(cat "$MANIFEST")")
[ "$NAME" = "agent-harness" ] || exit 0

SRC="${SOURCE_REPO}/skills/${SKILL_NAME}"
DST="${PLUGIN_ROOT}/skills/${SKILL_NAME}"

if [ -d "$SRC" ]; then
  if [ ! -d "$DST" ] || ! diff -rq "$SRC" "$DST" >/dev/null 2>&1; then
    mkdir -p "$DST"
    cp -rf "$SRC/." "$DST/"
    echo "[agent-harness] Synced installed copy of '${SKILL_NAME}' from dev repo (was stale)." >&2
  fi
fi

# Also resync this skill's slash-command wrappers across all three CLI
# targets — they're separate files that have drifted out of sync with the
# skill body before (e.g. still instructing Mermaid after the skill itself
# was updated to drop it), and nothing else keeps them in lockstep.
for pair in \
  ".claude/commands/${SKILL_NAME}.md" \
  ".gemini/commands/${SKILL_NAME}.toml" \
  "commands/${SKILL_NAME}.toml"
do
  CSRC="${SOURCE_REPO}/${pair}"
  CDST="${PLUGIN_ROOT}/${pair}"
  [ -f "$CSRC" ] || continue
  if [ ! -f "$CDST" ] || ! diff -q "$CSRC" "$CDST" >/dev/null 2>&1; then
    mkdir -p "$(dirname "$CDST")"
    cp -f "$CSRC" "$CDST"
    echo "[agent-harness] Synced installed copy of '${pair}' from dev repo (was stale)." >&2
  fi
done

exit 0
