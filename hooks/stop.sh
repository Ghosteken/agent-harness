#!/bin/bash
# agent-harness Stop hook
# Fires when Claude is about to finish a response.
# Injects a verification reminder if any file was edited this turn.

FLAG="${TMPDIR:-/tmp}/claude-agent-harness-edited.flag"

if [ -f "$FLAG" ]; then
  rm -f "$FLAG"

  if command -v jq >/dev/null 2>&1; then
    jq -cn '{
      priority: "IMPORTANT",
      message: "STOP — files were edited this turn. Do NOT claim completion without:\n\n1. /verify  → load the app in a browser, confirm no console errors\n2. verification-before-completion skill → evidence before any success claim\n\nQuick-fix rationalisations that are forbidden:\n  \"Should work\" / \"I believe it works\" / \"Looks correct\" — run it.\n  \"The change is simple\" — simple changes break things too.\n\nIf you cannot run /verify (no browser tool), say so explicitly — do NOT claim it works."
    }'
  else
    echo '{"priority":"IMPORTANT","message":"STOP — files were edited. Run /verify before claiming completion. No success claims without evidence."}'
  fi
fi
