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

# The path shown to the model must be in whatever form its own file-reading
# tool expects on this host (e.g. a native C:\... path on Windows) — that's
# whatever the host itself set in CURSOR_PLUGIN_ROOT/CLAUDE_PLUGIN_ROOT, not
# necessarily the POSIX-style $PLUGIN_ROOT this script derived above for its
# own internal `cat`/file access.
DISPLAY_ROOT="${CURSOR_PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT:-$PLUGIN_ROOT}}"
# Strip a trailing separator, then join with whichever separator this root
# already uses, so the example paths below don't mix slash styles.
DISPLAY_ROOT="${DISPLAY_ROOT%/}"
DISPLAY_ROOT="${DISPLAY_ROOT%\\}"
case "$DISPLAY_ROOT" in
  *\\*) SEP='\' ;;
  *) SEP='/' ;;
esac

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
path_note='PATH NOTE (read before ever opening a "references/..." path mentioned by a skill or agent file): this plugin'"'"'s shared references'"${SEP}"' directory is NOT inside any individual skill'"'"'s own directory. Its absolute path in this installation is exactly: '"${DISPLAY_ROOT}${SEP}"'references'"${SEP}"' -- so "references/coding-patterns.md" means '"${DISPLAY_ROOT}${SEP}"'references'"${SEP}"'coding-patterns.md, never '"${DISPLAY_ROOT}${SEP}"'skills'"${SEP}"'<skill-name>'"${SEP}"'references'"${SEP}"'coding-patterns.md. If a Read at that path ever fails, the fix is to re-check this exact prefix -- never fall back to a filesystem-wide find/grep across "/", which is slow and has repeatedly timed out in practice.'
path_note_escaped=$(escape_for_json "$path_note")
session_context="<EXTREMELY_IMPORTANT>\n${path_note_escaped}\n\nYou have agent-harness superpowers.\n\n**Below is the full content of your 'agent-harness:using-agent-harness' meta-skill - your introduction to using agent-harness skills. For all other skills, use the 'Skill' tool:**\n\n${skill_escaped}\n</EXTREMELY_IMPORTANT>"

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
