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

TMP_OUT="${OUT}.tmp"
rm -f "$TMP_OUT"
git -C "$REPO_ROOT" archive --format=zip --worktree-attributes -o "$TMP_OUT" HEAD

[[ -f "$TMP_OUT" ]] || { echo "ERROR: zip creation failed - $TMP_OUT not found" >&2; exit 1; }

# Self-verify against git's own committed tree (HEAD), not the raw working
# directory — git archive only ever bundles committed content, so comparing
# against uncommitted disk state produces false failures whenever there's
# WIP. This still catches a genuine zip-writer bug (a HEAD/zip mismatch),
# just not "you have an uncommitted skill" as a false positive.
HEAD_SKILL_COUNT="$(git -C "$REPO_ROOT" ls-tree -r --name-only HEAD -- skills | grep -cE '^skills/[^/]+/SKILL\.md$' || true)"
ZIPPED_SKILL_COUNT="$(unzip -l "$TMP_OUT" | grep -cE '[[:space:]]skills/[^/]+/SKILL\.md$' || true)"

if [[ "$ZIPPED_SKILL_COUNT" -ne "$HEAD_SKILL_COUNT" ]]; then
  rm -f "$TMP_OUT"
  echo "ERROR: Build verification failed: zip contains ${ZIPPED_SKILL_COUNT} skill(s) but HEAD has ${HEAD_SKILL_COUNT}. Leaving any existing $OUT untouched." >&2
  exit 1
fi

# Only replace the real output now that the new build is confirmed good —
# never delete a known-good $OUT before the replacement is verified.
mv -f "$TMP_OUT" "$OUT"
echo "[agent-harness] Verified: ${ZIPPED_SKILL_COUNT} skills bundled, matching HEAD."

UNCOMMITTED_SKILLS="$(git -C "$REPO_ROOT" status --porcelain -- skills | wc -l | tr -d ' ')"
if [[ "$UNCOMMITTED_SKILLS" -gt 0 ]]; then
  echo "[agent-harness] Note: skills/ has uncommitted changes — this build reflects HEAD, not your working tree. Commit first if you need those included."
fi

SIZE=$(du -sh "$OUT" | cut -f1)
echo "[agent-harness] Done — agent-harness.plugin ($SIZE)"
echo ""
echo "  To install on Claude desktop:"
echo "  1. Open Claude desktop → Settings → Extensions"
echo "  2. Click 'Upload local plugin'"
echo "  3. Select: $OUT"
