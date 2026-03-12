#!/usr/bin/env bash
# vault-pretooluse.sh — PreToolUse vault-tec hook
# Fires before Write tool. Validates schema of vault notes before they're written.

# Load vault-tec config
VTCONFIG="$HOME/.vault-tec/config.sh"
[ -f "$VTCONFIG" ] && source "$VTCONFIG"
VAULT="${VAULT_PATH:-}"
[ -z "$VAULT" ] && exit 0

VAULT_BASENAME="$(basename "$VAULT")"

# Read hook input from stdin
INPUT=$(cat 2>/dev/null || echo '{}')

# Extract file path and content
FILE_PATH=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "")
CONTENT=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('tool_input',{}).get('content',''))" 2>/dev/null || echo "")

# Scope check: must be a .md file in the vault's notes/ directory
case "$FILE_PATH" in
  *"${VAULT_BASENAME}"/notes/*.md) ;;
  *) exit 0 ;;
esac

FILENAME=$(basename "$FILE_PATH" .md)
ISSUES=""

# --- Check A: YAML frontmatter present ---
if ! echo "$CONTENT" | grep -q "^---"; then
  ISSUES="${ISSUES}missing frontmatter | "
fi

# --- Check B: description field present and non-empty ---
DESCRIPTION=$(echo "$CONTENT" | grep -m1 "^description:" | sed 's/description: *//' | tr -d '"')
if [ -z "$DESCRIPTION" ]; then
  ISSUES="${ISSUES}missing description field | "
fi

# --- Check C: topics field with at least one value (skip for type: map) ---
IS_MAP=$(echo "$CONTENT" | grep -m1 "^type:" | grep -c "map")
if [ "$IS_MAP" -eq 0 ]; then
  TOPICS=$(echo "$CONTENT" | grep -m1 "^topics:")
  if [ -z "$TOPICS" ] || echo "$TOPICS" | grep -qE ":\s*\[\s*\]|:\s*$"; then
    ISSUES="${ISSUES}empty topics field | "
  fi
fi

# --- Check D: wiki links in body (skip for type: map) ---
if [ "$IS_MAP" -eq 0 ]; then
  BODY=$(echo "$CONTENT" | awk '/^---/{c++; if(c==2){found=1; next}} found{print}')
  if ! echo "$BODY" | grep -q "\[\["; then
    ISSUES="${ISSUES}no wiki links in body | "
  fi
fi

# --- Check E: filename as prose proposition (has a verb/predicate) ---
# Simple heuristic: filename should have 4+ words (topic labels are usually 1-3 words)
WORD_COUNT=$(echo "$FILENAME" | tr '-' ' ' | wc -w | tr -d ' ')
if [ "$WORD_COUNT" -lt 4 ]; then
  ISSUES="${ISSUES}filename looks like a topic label (needs a verb/claim) | "
fi

# Strip trailing separator
ISSUES="${ISSUES%| }"
ISSUES="${ISSUES% |}"

if [ -z "$ISSUES" ]; then
  exit 0
fi

# Output additionalContext (warning only — never blocks the write)
printf '{"additionalContext": %s}\n' \
  "$(printf 'SCHEMA NOTICE — %s: %s. Fix before finalizing.' "$FILENAME" "$ISSUES" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
