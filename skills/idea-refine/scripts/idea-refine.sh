#!/bin/bash
set -e

# This script helps initialize the ideas directory for the idea-refine skill.
# Per references/external-output-paths.md, output lives outside the project's
# repo entirely — never a path git in the project tracks or ignores.

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PROJECT_SLUG="$(basename "$PROJECT_ROOT" | tr '[:upper:] ' '[:lower:]-')"
IDEAS_DIR="${HOME}/.agent-harness/projects/${PROJECT_SLUG}/ideas"

if [ ! -d "$IDEAS_DIR" ]; then
  mkdir -p "$IDEAS_DIR"
  echo "Created directory: $IDEAS_DIR" >&2
else
  echo "Directory already exists: $IDEAS_DIR" >&2
fi

echo "{\"status\": \"ready\", \"directory\": \"$IDEAS_DIR\"}"
