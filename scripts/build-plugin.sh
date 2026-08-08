#!/usr/bin/env bash
# Recreate agent-harness.plugin for Claude desktop upload.
#
# Usage:
#   bash scripts/build-plugin.sh
#   bash scripts/build-plugin.sh --out /path/to/output.plugin
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
OUT="${REPO_ROOT}/agent-harness.plugin"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --out) OUT="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

TMP_ZIP="$(mktemp /tmp/agent-harness-plugin-XXXXXX.zip)"
trap 'rm -f "$TMP_ZIP"' EXIT

echo "[agent-harness] Building plugin from: $REPO_ROOT"
echo "[agent-harness] Output: $OUT"

# Build list of items to include (exclude .git and existing .plugin)
ITEMS=()
while IFS= read -r -d '' item; do
  name="$(basename "$item")"
  [[ "$name" == ".git" || "$name" == "agent-harness.plugin" ]] && continue
  ITEMS+=("$item")
done < <(find "$REPO_ROOT" -maxdepth 1 -mindepth 1 -print0)

if [[ ${#ITEMS[@]} -eq 0 ]]; then
  echo "ERROR: nothing to zip in $REPO_ROOT" >&2
  exit 1
fi

cd "$REPO_ROOT"
zip -r "$TMP_ZIP" . \
  --exclude ".git/*" \
  --exclude "agent-harness.plugin" \
  --exclude "archive/*" \
  --exclude ".claude/settings.local.json" \
  --exclude ".claude/settings.local.*" \
  2>/dev/null || true

[[ -f "$TMP_ZIP" ]] || { echo "ERROR: zip failed" >&2; exit 1; }

cp "$TMP_ZIP" "$OUT"

SIZE=$(du -sh "$OUT" | cut -f1)
echo "[agent-harness] Done — agent-harness.plugin ($SIZE)"
echo ""
echo "  To install on Claude desktop:"
echo "  1. Open Claude desktop → Settings → Extensions"
echo "  2. Click 'Upload local plugin'"
echo "  3. Select: $OUT"
