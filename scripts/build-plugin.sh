#!/usr/bin/env bash
# Recreate agent-harness.plugin for Claude desktop upload.
#
# Builds via `git archive` from the current commit — the exclude list lives
# in .gitattributes (export-ignore), not in this script, so it stays in
# sync with build-plugin.ps1 instead of two scripts maintaining separate
# exclude lists that can silently drift apart.
#
# Note: `git archive` zips the current commit, not uncommitted working-tree
# changes — commit first if you need those reflected in the build.
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

echo "[agent-harness] Building plugin from: $REPO_ROOT"
echo "[agent-harness] Output: $OUT"

rm -f "$OUT"
git -C "$REPO_ROOT" archive --format=zip --worktree-attributes -o "$OUT" HEAD

[[ -f "$OUT" ]] || { echo "ERROR: zip creation failed - $OUT not found" >&2; exit 1; }

# Self-verify: confirm the zip actually contains the skills on disk, before
# ever treating this as a valid build.
LIVE_SKILL_COUNT="$(find "${REPO_ROOT}/skills" -mindepth 2 -maxdepth 2 -name 'SKILL.md' | wc -l | tr -d ' ')"
ZIPPED_SKILL_COUNT="$(unzip -l "$OUT" | grep -cE '[[:space:]]skills/[^/]+/SKILL\.md$' || true)"

if [[ "$ZIPPED_SKILL_COUNT" -ne "$LIVE_SKILL_COUNT" ]]; then
  rm -f "$OUT"
  echo "ERROR: Build verification failed: zip contains ${ZIPPED_SKILL_COUNT} skill(s) but skills/ has ${LIVE_SKILL_COUNT} on disk (uncommitted changes? git archive only zips HEAD). Not leaving a broken output file in place." >&2
  exit 1
fi
echo "[agent-harness] Verified: ${ZIPPED_SKILL_COUNT} skills bundled, matching skills/ on disk."

SIZE=$(du -sh "$OUT" | cut -f1)
echo "[agent-harness] Done — agent-harness.plugin ($SIZE)"
echo ""
echo "  To install on Claude desktop:"
echo "  1. Open Claude desktop → Settings → Extensions"
echo "  2. Click 'Upload local plugin'"
echo "  3. Select: $OUT"
