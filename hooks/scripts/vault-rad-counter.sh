#!/usr/bin/env bash
# vault-rad-counter.sh — Contamination level calculator for the vault
# Calculates "millirem" (mR) contamination from various vault health issues.
# Must complete in <10s on a 1000-note vault.
# Usage: vault-rad-counter.sh [vault-path]

set -euo pipefail

# Load vault-tec config
VTCONFIG="$HOME/.vault-tec/config.sh"
[ -f "$VTCONFIG" ] && source "$VTCONFIG"
VAULT="${1:-${VAULT_PATH:-}}"
[ -z "$VAULT" ] && echo "☢ CONTAMINATION REPORT" && echo "  No vault configured" && exit 0

NOTES_DIR="$VAULT/notes"
INBOX_DIR="$VAULT/ops/inbox"

# Bail if vault doesn't exist
if [ ! -d "$NOTES_DIR" ]; then
  echo "☢ CONTAMINATION REPORT"
  echo "  No vault found at $VAULT"
  exit 0
fi

# --- Weights (from config or defaults) ---
ORPHAN_WEIGHT="${RAD_ORPHAN_WEIGHT:-2}"
DANGLING_WEIGHT="${RAD_DANGLING_WEIGHT:-3}"
INBOX_WEIGHT="${RAD_INBOX_WEIGHT:-0.5}"
STALE_WEIGHT="${RAD_STALE_WEIGHT:-1}"
SCHEMA_WEIGHT="${RAD_SCHEMA_WEIGHT:-2}"

# --- Levels (from config or defaults) ---
LEVEL_CLEAN="${RAD_CLEAN:-5}"
LEVEL_LOW="${RAD_LOW:-15}"
LEVEL_MODERATE="${RAD_MODERATE:-40}"
LEVEL_ELEVATED="${RAD_ELEVATED:-80}"

TMPDIR_RAD=$(mktemp -d)
trap 'rm -rf "$TMPDIR_RAD"' EXIT

# ============================================================
# 1. Orphaned notes (no incoming links from other .md files)
# ============================================================
# All note basenames (without .md), sorted — use sed not -exec basename
find "$NOTES_DIR" -maxdepth 1 -name "*.md" \
  | sed 's|.*/||;s|\.md$||' \
  | sort > "$TMPDIR_RAD/all_notes.txt"

# Extract all wiki-link targets from notes/ and self/
# Handles [[target]], [[target#heading]], [[target|alias]]
grep -roh --include="*.md" '\[\[[^]]*\]\]' "$NOTES_DIR" "$VAULT/self" 2>/dev/null \
  | sed 's/\[\[//;s/\]\]//;s/#.*//;s/|.*//' \
  | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
  | grep -v '^$' \
  | sort -u > "$TMPDIR_RAD/linked_targets.txt"

# Orphans = notes NOT appearing as link targets
ORPHAN_COUNT=$(comm -23 "$TMPDIR_RAD/all_notes.txt" "$TMPDIR_RAD/linked_targets.txt" | wc -l | tr -d ' ')

# ============================================================
# 2. Dangling links (wiki-links to nonexistent files)
# ============================================================
# All .md basenames anywhere in the vault
find "$VAULT" -name "*.md" -not -path "*/\.*" \
  | sed 's|.*/||;s|\.md$||' \
  | sort -u > "$TMPDIR_RAD/all_vault_files.txt"

# Dangling = link targets with no matching file
DANGLING_COUNT=$(comm -23 "$TMPDIR_RAD/linked_targets.txt" "$TMPDIR_RAD/all_vault_files.txt" | wc -l | tr -d ' ')

# ============================================================
# 3. Inbox backlog
# ============================================================
INBOX_COUNT=0
if [ -d "$INBOX_DIR" ]; then
  INBOX_COUNT=$(find "$INBOX_DIR" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
fi

# ============================================================
# 4. Stale notes (30+ days old AND <3 outgoing links)
# ============================================================
STALE_COUNT=0
while IFS= read -r stale_file; do
  [ -z "$stale_file" ] && continue
  link_count=$(grep -co '\[\[' "$stale_file" 2>/dev/null || echo "0")
  if [ "$link_count" -lt 3 ]; then
    STALE_COUNT=$((STALE_COUNT + 1))
  fi
done < <(find "$NOTES_DIR" -maxdepth 1 -name "*.md" -mtime +30 2>/dev/null)

# ============================================================
# 5. Schema violations (missing description: or topics:)
# ============================================================
# Use grep -L (files not matching) — fast single-pass per field
# Union of files missing either description: or topics:
SCHEMA_COUNT=$( {
  grep -rL '^description:' "$NOTES_DIR"/*.md 2>/dev/null
  grep -rL '^topics:' "$NOTES_DIR"/*.md 2>/dev/null
} | sort -u | wc -l | tr -d ' ')

# ============================================================
# Calculate total mR
# ============================================================
ORPHAN_MR=$((ORPHAN_COUNT * ORPHAN_WEIGHT))
DANGLING_MR=$((DANGLING_COUNT * DANGLING_WEIGHT))
INBOX_MR=$(awk "BEGIN {v=$INBOX_COUNT * $INBOX_WEIGHT; printf \"%.0f\", v}")
STALE_MR=$((STALE_COUNT * STALE_WEIGHT))
SCHEMA_MR=$((SCHEMA_COUNT * SCHEMA_WEIGHT))
TOTAL_MR=$((ORPHAN_MR + DANGLING_MR + INBOX_MR + STALE_MR + SCHEMA_MR))

# ============================================================
# Determine contamination level
# ============================================================
if [ "$TOTAL_MR" -le "$LEVEL_CLEAN" ]; then
  LEVEL="CLEAN"
elif [ "$TOTAL_MR" -le "$LEVEL_LOW" ]; then
  LEVEL="LOW"
elif [ "$TOTAL_MR" -le "$LEVEL_MODERATE" ]; then
  LEVEL="MODERATE"
elif [ "$TOTAL_MR" -le "$LEVEL_ELEVATED" ]; then
  LEVEL="ELEVATED"
else
  LEVEL="CRITICAL"
fi

# ============================================================
# Decontamination advice (top 2 sources by mR)
# ============================================================
ADVICE=""

TOP_SOURCES=$(printf '%d orphan\n%d dangling\n%d inbox\n%d stale\n%d schema\n' \
  "$ORPHAN_MR" "$DANGLING_MR" "$INBOX_MR" "$STALE_MR" "$SCHEMA_MR" \
  | sort -rn | head -2)

while IFS= read -r line; do
  mr_val=$(echo "$line" | awk '{print $1}')
  source=$(echo "$line" | awk '{print $2}')
  [ "$mr_val" -eq 0 ] 2>/dev/null && continue
  case "$source" in
    orphan)   ADVICE="${ADVICE}Run /vault-tec:reweave for orphans. " ;;
    dangling) ADVICE="${ADVICE}Fix dangling links or create missing notes. " ;;
    inbox)    ADVICE="${ADVICE}Process inbox backlog. " ;;
    stale)    ADVICE="${ADVICE}Revisit stale notes — add links or archive. " ;;
    schema)   ADVICE="${ADVICE}Run /vault-tec:health to find and fix schema violations. " ;;
  esac
done <<< "$TOP_SOURCES"

if [ -z "$ADVICE" ]; then
  ADVICE="All clear, Overseer. Vault integrity nominal."
fi

# ============================================================
# Output
# ============================================================
echo "☢ CONTAMINATION REPORT"
echo "  RAD LEVEL: $LEVEL ($TOTAL_MR mR)"
echo "  ├─ $ORPHAN_COUNT orphaned notes ($ORPHAN_MR mR)"
echo "  ├─ $DANGLING_COUNT dangling links ($DANGLING_MR mR)"
echo "  ├─ $INBOX_COUNT inbox items ($INBOX_MR mR)"
echo "  ├─ $STALE_COUNT stale notes ($STALE_MR mR)"
echo "  └─ $SCHEMA_COUNT schema violations ($SCHEMA_MR mR)"
echo ""
echo "  Decontamination: ${ADVICE}"
