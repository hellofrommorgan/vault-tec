#!/bin/bash
# vault-session-end.sh — SessionEnd vault-tec hook
# Logs session end and reminds Claude to persist vault state

# Load vault-tec config
VTCONFIG="$HOME/.vault-tec/config.sh"
[ -f "$VTCONFIG" ] && source "$VTCONFIG"
VAULT="${VAULT_PATH:-}"
[ -z "$VAULT" ] && exit 0

if [ ! -f "$VAULT/CLAUDE.md" ]; then
  exit 0
fi

INPUT=$(cat)
REASON=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('reason','unknown'))" 2>/dev/null || echo "unknown")

# Rotate heartbeat log if over 1000 lines
HEARTBEAT="$VAULT/ops/heartbeat.log"
if [ -f "$HEARTBEAT" ]; then
  LINE_COUNT=$(wc -l < "$HEARTBEAT" | tr -d ' ')
  if [ "$LINE_COUNT" -gt 1000 ]; then
    tail -500 "$HEARTBEAT" > "$HEARTBEAT.tmp" && mv "$HEARTBEAT.tmp" "$HEARTBEAT"
  fi
fi

echo "[$(date '+%Y-%m-%d %H:%M')] SESSION_END reason=$REASON vault=active" >> "$HEARTBEAT"

TODAY=$(date '+%Y-%m-%d')
CONTEXT="SESSION ENDING (reason: ${REASON}) — If vault work happened this session: update self/working-memory.md with active threads and next move. Create ops/sessions/session-${TODAY}.md if substantive work occurred. Update ops/patterns/ if any themes shifted."

printf '{"additionalContext": %s}\n' "$(printf '%s' "$CONTEXT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
