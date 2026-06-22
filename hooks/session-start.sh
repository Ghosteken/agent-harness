#!/usr/bin/env bash
# agent-harness session start hook
# Injects the using-agent-harness meta-skill into every new session

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
META_SKILL="${PLUGIN_ROOT}/skills/using-agent-harness/SKILL.md"

if [ ! -f "$META_SKILL" ]; then
  exit 0
fi

skill_content=$(cat "$META_SKILL")

# Escape string for JSON embedding
escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

skill_escaped=$(escape_for_json "$skill_content")
session_context="<EXTREMELY_IMPORTANT>\nYou have agent-harness superpowers.\n\n**Below is the full content of your 'agent-harness:using-agent-harness' meta-skill - your introduction to using agent-harness skills. For all other skills, use the 'Skill' tool:**\n\n${skill_escaped}\n</EXTREMELY_IMPORTANT>"

# Output format depends on platform:
# - Cursor sets CURSOR_PLUGIN_ROOT
# - Claude Code sets CLAUDE_PLUGIN_ROOT (without COPILOT_CLI)
# - Copilot CLI sets COPILOT_CLI=1
if [ -n "${CURSOR_PLUGIN_ROOT:-}" ]; then
  printf '{\n  "additional_context": "%s"\n}\n' "$session_context" | cat
elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -z "${COPILOT_CLI:-}" ]; then
  printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$session_context" | cat
else
  printf '{\n  "additionalContext": "%s"\n}\n' "$session_context" | cat
fi

exit 0
