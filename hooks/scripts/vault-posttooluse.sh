#!/usr/bin/env bash
# vault-posttooluse.sh — PostToolUse vault-tec hook
# Fires after Write or Edit tool. Checks referential integrity of new/modified notes.

# Load vault-tec config
VTCONFIG="$HOME/.vault-tec/config.sh"
[ -f "$VTCONFIG" ] && source "$VTCONFIG"
VAULT="${VAULT_PATH:-}"
[ -z "$VAULT" ] && exit 0

VAULT_BASENAME="$(basename "$VAULT")"

# Read tool input from stdin
INPUT=$(cat 2>/dev/null || echo '{}')
FILE_PATH=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "")

# Scope check: must be a .md file in the vault's notes/ directory
case "$FILE_PATH" in
  *"${VAULT_BASENAME}"/notes/*.md) ;;
  *) exit 0 ;;
esac

[ -f "$FILE_PATH" ] || exit 0

FILENAME=$(basename "$FILE_PATH" .md)
NOTES_DIR="$VAULT/notes"
ISSUES=""

# --- Check 1: Dangling wiki-links ---
# Extract all [[link targets]] from the file body (skip frontmatter)
BODY=$(awk '/^---/{c++; if(c==2){found=1; next}} found{print}' "$FILE_PATH" 2>/dev/null)
LINKS=$(echo "$BODY" | grep -oE '\[\[[^]|]+' | sed 's/\[\[//' | sed 's/#.*//' | sort -u)

DANGLING=""
while IFS= read -r LINK; do
  [ -z "$LINK" ] && continue
  # Check notes/, self/, and vault root for the linked file
  if ! [ -f "$NOTES_DIR/${LINK}.md" ] && \
     ! [ -f "$VAULT/self/${LINK}.md" ] && \
     ! [ -f "$VAULT/${LINK}.md" ]; then
    DANGLING="${DANGLING}[[${LINK}]], "
  fi
done <<< "$LINKS"

DANGLING="${DANGLING%, }"

if [ -n "$DANGLING" ]; then
  COUNT=$(echo "$DANGLING" | tr ',' '\n' | grep -c '\[\[')
  ISSUES="${COUNT} dangling link(s): ${DANGLING}"
fi

# --- Check 2: Orphan detection (no incoming links) ---
INCOMING=$(grep -rl "\[\[${FILENAME}\]\]" "$NOTES_DIR" "$VAULT/self/" 2>/dev/null | grep -v "^${FILE_PATH}$" | wc -l | tr -d ' ')
if [ "$INCOMING" -eq 0 ]; then
  if [ -n "$ISSUES" ]; then
    ISSUES="${ISSUES}. No incoming links (orphan — add to a map)"
  else
    ISSUES="No incoming links yet (orphan — add to a map or link from another thought)"
  fi
fi

if [ -z "$ISSUES" ]; then
  exit 0
fi

# Output additionalContext
printf '{"additionalContext": %s}\n' \
  "$(printf 'INTEGRITY — %s: %s' "$FILENAME" "$ISSUES" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
