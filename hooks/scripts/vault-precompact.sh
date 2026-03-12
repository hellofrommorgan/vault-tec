#!/usr/bin/env bash
# vault-precompact.sh — PreCompact vault-tec hook
# Fires before context compaction. Preserves critical vault state.

# Load vault-tec config
VTCONFIG="$HOME/.vault-tec/config.sh"
[ -f "$VTCONFIG" ] && source "$VTCONFIG"
VAULT="${VAULT_PATH:-}"
[ -z "$VAULT" ] && exit 0

INPUT=$(cat 2>/dev/null || echo '{}')

# Detect vault
if [ ! -f "$VAULT/CLAUDE.md" ]; then
  exit 0
fi

# Extract trigger
TRIGGER=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('trigger','auto'))" 2>/dev/null || echo "auto")

WORKING_MEMORY="$VAULT/self/working-memory.md"

# Extract working memory body (skip YAML frontmatter)
WM_BODY=$(awk 'NR>1 && /^---/{found=1; next} found{print}' "$WORKING_MEMORY" 2>/dev/null | head -20 || echo "(no working memory found)")

# Extract ## Next Move section
NEXT_MOVE=$(awk '/^## Next Move/{found=1; next} /^## /{if(found) exit} found{print}' "$WORKING_MEMORY" 2>/dev/null | head -5 || echo "(none)")

# Collect active patterns
PATTERNS=""
if [ -d "$VAULT/ops/patterns" ]; then
  for f in "$VAULT/ops/patterns/"*.md; do
    [ -f "$f" ] || continue
    n=$(basename "$f" .md)
    s=$(grep "^strength:" "$f" 2>/dev/null | head -1 | sed 's/strength: //' | tr -d '[:space:]')
    [ -n "$s" ] && PATTERNS="${PATTERNS}  - ${n} (${s})\n"
  done
fi
[ -z "$PATTERNS" ] && PATTERNS="  (none active)"

CONTEXT="PRE-COMPACTION SNAPSHOT — Preserve this across compaction:

Working memory (trigger: ${TRIGGER}):
${WM_BODY}

Active patterns:
$(printf '%b' "$PATTERNS")
Next move:
${NEXT_MOVE}"

printf '{"additionalContext": %s}\n' "$(printf '%s' "$CONTEXT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
