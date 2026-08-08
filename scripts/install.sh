#!/usr/bin/env bash
# agent-harness installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Ghosteken/agent-harness/main/scripts/install.sh | bash
#   bash install.sh [--global | --project] [--dry-run]
set -euo pipefail

REPO_URL="https://github.com/Ghosteken/agent-harness.git"
PLUGIN_NAME="agent-harness"
VERSION="1.0.0"

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[agent-harness]${NC} $*"; }
success() { echo -e "${GREEN}[agent-harness]${NC} $*"; }
warn()    { echo -e "${YELLOW}[agent-harness]${NC} $*"; }
error()   { echo -e "${RED}[agent-harness]${NC} $*" >&2; exit 1; }

usage() {
  cat <<EOF
agent-harness installer v${VERSION}

Usage:
  install.sh [options]

Options:
  --global      Install to ~/.claude/plugins/${PLUGIN_NAME}/  (available in all projects)
  --project     Install to ./.claude/plugins/${PLUGIN_NAME}/  (current project only, default)
  --dry-run     Show what would happen without making changes
  --help        Show this help message

Examples:
  bash install.sh                    # project-level install
  bash install.sh --global           # user-level install
  bash install.sh --global --dry-run # preview global install
EOF
}

# Defaults
SCOPE="project"
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --global)   SCOPE="global"; shift ;;
    --project)  SCOPE="project"; shift ;;
    --dry-run)  DRY_RUN=true; shift ;;
    --help|-h)  usage; exit 0 ;;
    *)          error "Unknown option: $1. Run with --help for usage." ;;
  esac
done

# Resolve install directory
if [[ "$SCOPE" == "global" ]]; then
  INSTALL_DIR="${HOME}/.claude/plugins/${PLUGIN_NAME}"
  SETTINGS_FILE="${HOME}/.claude/settings.json"
else
  INSTALL_DIR="$(pwd)/.claude/plugins/${PLUGIN_NAME}"
  SETTINGS_FILE="$(pwd)/.claude/settings.json"
fi

info "agent-harness installer v${VERSION}"
info "Scope:       ${SCOPE}"
info "Install dir: ${INSTALL_DIR}"
info "Settings:    ${SETTINGS_FILE}"
echo ""

# Check dependencies
check_dep() {
  command -v "$1" &>/dev/null || error "Required dependency not found: $1. Please install it and retry."
}

check_dep git

# Optional: warn if jq is missing (used by hooks)
if ! command -v jq &>/dev/null; then
  warn "jq is not installed. The session-start hook will degrade gracefully, but installing jq is recommended."
  warn "  macOS:  brew install jq"
  warn "  Ubuntu: sudo apt-get install -y jq"
fi

# Dry-run gate
run() {
  if [[ "$DRY_RUN" == true ]]; then
    echo "  [dry-run] $*"
  else
    "$@"
  fi
}

# Check if already installed
if [[ -d "$INSTALL_DIR" && "$DRY_RUN" == false ]]; then
  warn "Plugin already exists at ${INSTALL_DIR}"
  read -r -p "  Overwrite? [y/N] " confirm
  [[ "${confirm,,}" == "y" ]] || { info "Aborted."; exit 0; }
  run rm -rf "$INSTALL_DIR"
fi

# Determine source: cloned repo or local copy
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

if [[ -f "${REPO_ROOT}/.claude-plugin/plugin.json" ]]; then
  # Running from inside the repo — copy local files
  info "Source: local clone at ${REPO_ROOT}"
  run mkdir -p "$INSTALL_DIR"
  run cp -r "${REPO_ROOT}/." "$INSTALL_DIR/"
else
  # Running via curl or outside the repo — clone from GitHub
  info "Source: cloning from ${REPO_URL}"
  run git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"
fi

# Register plugin in Claude Code settings.json
register_plugin() {
  local settings="$1"
  local plugin_path="$2"

  if [[ "$DRY_RUN" == true ]]; then
    echo "  [dry-run] Would register plugin in ${settings}"
    return
  fi

  if ! command -v jq &>/dev/null; then
    warn "jq not found — skipping automatic settings registration."
    warn "To register manually, add to ${settings}:"
    warn '  { "plugins": [{ "name": "'"${PLUGIN_NAME}"'", "path": "'"${plugin_path}"'" }] }'
    return
  fi

  mkdir -p "$(dirname "$settings")"

  if [[ ! -f "$settings" ]]; then
    echo '{}' > "$settings"
  fi

  local tmp
  tmp=$(mktemp)

  # Merge plugin entry idempotently (remove existing entry with same name, then append)
  jq --arg name "$PLUGIN_NAME" --arg path "$plugin_path" '
    .plugins = ((.plugins // []) | map(select(.name != $name))) + [{"name": $name, "path": $path}]
  ' "$settings" > "$tmp" && mv "$tmp" "$settings"

  success "Registered plugin in ${settings}"
}

if [[ "$SCOPE" == "global" ]]; then
  register_plugin "$SETTINGS_FILE" "$INSTALL_DIR"
else
  register_plugin "$SETTINGS_FILE" "$INSTALL_DIR"
fi

echo ""
success "Installation complete!"
echo ""
echo "  Plugin installed to: ${INSTALL_DIR}"
echo ""
echo "  Next steps:"
if [[ "$SCOPE" == "global" ]]; then
  echo "    1. Restart Claude Code (or run: claude --reload)"
  echo "    2. Use /spec, /plan, /build, /test, /review, /ship in any project"
else
  echo "    1. Restart Claude Code in this project (or run: claude --reload)"
  echo "    2. Use /spec, /plan, /build, /test, /review, /ship"
fi
echo "    3. See README.md for the full workflow guide"
echo ""
