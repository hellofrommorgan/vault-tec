#!/usr/bin/env bash
# vault-session-start.sh — SessionStart vault-tec hook
# Runs at every session start. Must complete in <30s.

# Load vault-tec config
VTCONFIG="$HOME/.vault-tec/config.sh"
[ -f "$VTCONFIG" ] && source "$VTCONFIG"
VAULT="${VAULT_PATH:-}"
[ -z "$VAULT" ] && exit 0

# Detect vault: check for CLAUDE.md + self/ + notes/
if [ ! -f "$VAULT/CLAUDE.md" ] || [ ! -d "$VAULT/self" ] || [ ! -d "$VAULT/notes" ]; then
  exit 0
fi

# Set env vars if CLAUDE_ENV_FILE is available
if [ -n "$CLAUDE_ENV_FILE" ]; then
  echo "export VAULT_PATH=\"$VAULT\"" >> "$CLAUDE_ENV_FILE"
  echo "export VAULT_ACTIVE=1" >> "$CLAUDE_ENV_FILE"
fi

# Count notes by status
THOUGHTS_DIR="$VAULT/notes"
SEED_COUNT=0
GROWING_COUNT=0
EVERGREEN_COUNT=0
TOTAL_COUNT=0

if [ -d "$THOUGHTS_DIR" ]; then
  TOTAL_COUNT=$(find "$THOUGHTS_DIR" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  SEED_COUNT=$(grep -rl "status: seed" "$THOUGHTS_DIR" 2>/dev/null | wc -l | tr -d ' ')
  GROWING_COUNT=$(grep -rl "status: growing" "$THOUGHTS_DIR" 2>/dev/null | wc -l | tr -d ' ')
  EVERGREEN_COUNT=$(grep -rl "status: evergreen" "$THOUGHTS_DIR" 2>/dev/null | wc -l | tr -d ' ')
fi

# Count inbox items
INBOX_COUNT=0
if [ -d "$VAULT/ops/inbox" ]; then
  INBOX_COUNT=$(find "$VAULT/ops/inbox" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
fi

INBOX_THRESHOLD="${INBOX_PRESSURE_THRESHOLD:-3}"
INBOX_LINE="Inbox: $INBOX_COUNT items"
if [ "$INBOX_COUNT" -gt "$INBOX_THRESHOLD" ] 2>/dev/null; then
  INBOX_LINE="Inbox: $INBOX_COUNT items · PRESSURE"
fi

# Find active patterns
PATTERNS_LINE="Patterns: none"
if [ -d "$VAULT/ops/patterns" ]; then
  PATTERN_LIST=$(grep -rl "strength: strong\|strength: forming" "$VAULT/ops/patterns/" 2>/dev/null \
    | xargs -I{} basename {} .md 2>/dev/null \
    | tr '\n' ', ' \
    | sed 's/, $//')
  if [ -n "$PATTERN_LIST" ]; then
    PATTERNS_LINE="Patterns: $PATTERN_LIST"
  fi
fi

# Run Pip-Boy status line (fast pulse) and rad counter
HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
PIPBOY_LINE=""
if [ -x "$HOOK_DIR/vault-pipboy-status.sh" ]; then
  PIPBOY_LINE=$("$HOOK_DIR/vault-pipboy-status.sh" "$VAULT" 2>/dev/null || true)
fi

RAD_REPORT=""
if [ -x "$HOOK_DIR/vault-rad-counter.sh" ]; then
  RAD_REPORT=$("$HOOK_DIR/vault-rad-counter.sh" "$VAULT" 2>/dev/null || true)
fi

# Read working-memory.md (skip YAML frontmatter, take first 15 lines of content)
WORKING_MEMORY=""
if [ -f "$VAULT/self/working-memory.md" ]; then
  WORKING_MEMORY=$(awk '
    BEGIN { in_fm=0; past_fm=0; count=0 }
    /^---$/ && !past_fm {
      if (!in_fm) { in_fm=1; next }
      else { past_fm=1; in_fm=0; next }
    }
    past_fm && count < 15 {
      print
      count++
    }
  ' "$VAULT/self/working-memory.md")
fi

# Build the additionalContext string
VAULT_DISPLAY="${VAULT_NAME:-$(basename "$VAULT")}"
CONTEXT="VAULT ORIENTATION — ${VAULT_DISPLAY}"

# Pip-Boy status line first (fast one-liner pulse)
if [ -n "$PIPBOY_LINE" ]; then
  CONTEXT="$CONTEXT
$PIPBOY_LINE"
fi

CONTEXT="$CONTEXT
$TOTAL_COUNT notes · $SEED_COUNT seed / $GROWING_COUNT growing / $EVERGREEN_COUNT evergreen
$INBOX_LINE
$PATTERNS_LINE"

# Add rad counter report if available
if [ -n "$RAD_REPORT" ]; then
  CONTEXT="$CONTEXT
$RAD_REPORT"
fi

CONTEXT="$CONTEXT
---
$WORKING_MEMORY"

# Output valid JSON
printf '{"additionalContext": %s}\n' "$(printf '%s' "$CONTEXT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
