#!/usr/bin/env bash
# vault-userpromptsubmit.sh — UserPromptSubmit vault-tec hook
# Fires before every user message. Injects active patterns if message is vault-related.
# Must complete fast (<2s). No heavy operations.

# Load vault-tec config
VTCONFIG="$HOME/.vault-tec/config.sh"
[ -f "$VTCONFIG" ] && source "$VTCONFIG"
VAULT="${VAULT_PATH:-}"
[ -z "$VAULT" ] && exit 0

# Read hook input from stdin
INPUT=$(cat 2>/dev/null || echo '{}')

# Extract the user's prompt text
PROMPT=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('prompt',''))" 2>/dev/null || echo "")

# Relevance check: require vault-specific terms (not broad words like "thinking" or "writing")
if ! echo "$PROMPT" | grep -qiE "vault|notes\/|inbox|vault-tec|knowledge graph|wiki.?link|obsidian|thoughts map|seed.?note|evergreen"; then
  exit 0
fi

# Vault must exist
if [ ! -d "$VAULT/ops/patterns" ]; then
  exit 0
fi

# Collect active patterns (strong or forming)
PATTERN_LIST=""
for f in "$VAULT/ops/patterns/"*.md; do
  [ -f "$f" ] || continue
  STRENGTH=$(grep "^strength:" "$f" 2>/dev/null | head -1 | awk '{print $2}')
  if [ "$STRENGTH" = "strong" ] || [ "$STRENGTH" = "forming" ]; then
    NAME=$(basename "$f" .md)
    PATTERN_LIST="${PATTERN_LIST}${NAME} (${STRENGTH}), "
  fi
done

# Strip trailing comma+space
PATTERN_LIST="${PATTERN_LIST%, }"

if [ -z "$PATTERN_LIST" ]; then
  exit 0
fi

# Output additionalContext
printf '{"additionalContext": %s}\n' \
  "$(printf 'Active vault patterns: %s' "$PATTERN_LIST" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
