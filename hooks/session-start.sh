#!/bin/bash
# agent-harness session start hook
# Injects the using-agent-harness meta-skill into every new session

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$(dirname "$SCRIPT_DIR")/skills"
META_SKILL="$SKILLS_DIR/using-agent-harness/SKILL.md"

if [ ! -f "$META_SKILL" ]; then
  echo '{"priority": "INFO", "message": "agent-harness: using-agent-harness meta-skill not found. Skills may still be available individually."}'
  exit 0
fi

emit_json() {
  local skill_file="$1"
  local preamble="agent-harness loaded. Use the skill discovery flowchart to find the right skill for your task."

  if command -v jq >/dev/null 2>&1; then
    CONTENT=$(cat "$skill_file")
    jq -cn \
      --arg message "$preamble

$CONTENT" \
      '{priority: "IMPORTANT", message: $message}'
  elif command -v python3 >/dev/null 2>&1; then
    python3 - "$skill_file" "$preamble" <<'PYEOF'
import json, sys
skill_file, preamble = sys.argv[1], sys.argv[2]
with open(skill_file, encoding="utf-8") as f:
    content = f.read()
message = preamble + "\n\n" + content
print(json.dumps({"priority": "IMPORTANT", "message": message}))
PYEOF
  elif command -v python >/dev/null 2>&1; then
    python - "$skill_file" "$preamble" <<'PYEOF'
import json, sys
skill_file, preamble = sys.argv[1], sys.argv[2]
with open(skill_file) as f:
    content = f.read()
message = preamble + "\n\n" + content
print(json.dumps({"priority": "IMPORTANT", "message": message}))
PYEOF
  else
    echo '{"priority": "WARN", "message": "agent-harness: install jq or Python to enable meta-skill injection. Skills remain available individually via the Skill tool."}'
  fi
}

emit_json "$META_SKILL"
