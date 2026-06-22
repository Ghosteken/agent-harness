#!/bin/bash
# session-start-test.sh - Tests for the SessionStart hook JSON payload

set -euo pipefail

tmp_payload="$(mktemp)"
trap 'rm -f "$tmp_payload"' EXIT

# Simulate Claude Code environment so the hook uses the hookSpecificOutput format
payload="$(CLAUDE_PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)" bash hooks/session-start.sh)"
printf '%s' "$payload" > "$tmp_payload"

PAYLOAD_PATH="$tmp_payload" node <<'NODE'
const fs = require('fs');

const payload = JSON.parse(fs.readFileSync(process.env.PAYLOAD_PATH, 'utf8'));

// Claude Code format: hookSpecificOutput.additionalContext
if (!payload.hookSpecificOutput) {
  throw new Error(`expected hookSpecificOutput key, got: ${JSON.stringify(Object.keys(payload))}`);
}

if (payload.hookSpecificOutput.hookEventName !== 'SessionStart') {
  throw new Error(`expected hookEventName "SessionStart", got ${payload.hookSpecificOutput.hookEventName}`);
}

const context = payload.hookSpecificOutput.additionalContext;
if (!context) {
  throw new Error('additionalContext is empty');
}

if (!context.includes('EXTREMELY_IMPORTANT')) {
  throw new Error('additionalContext is missing EXTREMELY_IMPORTANT wrapper');
}

if (!context.includes('using-agent-harness')) {
  throw new Error('additionalContext is missing using-agent-harness reference');
}

if (!context.includes('# Using Agent Harness')) {
  throw new Error('additionalContext is missing SKILL.md content');
}

console.log('session-start JSON payload OK');
NODE
