#!/bin/bash
# agent-harness PostToolUse hook
# Fires after every tool call. Sets a flag when files are edited and injects
# a contextual verification reminder for UI / auth / functional changes.

TOOL="${CLAUDE_TOOL_NAME:-}"

# Only act on file-editing tools
if [[ "$TOOL" != "Edit" && "$TOOL" != "Write" && "$TOOL" != "NotebookEdit" ]]; then
  exit 0
fi

# Set the flag so the Stop hook knows files were touched this turn
FLAG="${TMPDIR:-/tmp}/claude-agent-harness-edited.flag"
touch "$FLAG"

# Emit a targeted reminder for UI / auth / form changes
INPUT="${CLAUDE_TOOL_INPUT:-}"

is_ui_auth=0
if echo "$INPUT" | grep -qiE \
  "(login|signup|sign-up|register|auth|password|form|page|component|\.tsx|\.jsx|\.vue|\.svelte|\.html|\.css|\.scss|privacy|footer|nav|modal|tab)"; then
  is_ui_auth=1
fi

if [ "$is_ui_auth" -eq 1 ]; then
  if command -v jq >/dev/null 2>&1; then
    jq -cn '{
      priority: "IMPORTANT",
      message: "UI / auth / form file just edited. When all edits are done:\n→ Run /verify — open the app in a browser and confirm:\n  • Page loads without errors\n  • No console errors (especially Failed to fetch, 401, 404)\n  • Forms submit and show correct feedback\n  • Other pages / flows not broken\n\nDo NOT skip this step. Do NOT claim it works without running it."
    }'
  else
    echo '{"priority":"IMPORTANT","message":"UI/auth file edited. Use /verify before claiming this works."}'
  fi
fi
