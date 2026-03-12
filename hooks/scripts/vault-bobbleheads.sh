#!/usr/bin/env bash
# vault-bobbleheads.sh — Vault-Tec Bobblehead Collection tracker
# Checks 14 milestone conditions against the vault and reports progress.
# Usage: bash vault-bobbleheads.sh [vault-path]
# Compatible with bash 3.2+ (macOS default)

set -euo pipefail

# Load vault-tec config
VTCONFIG="$HOME/.vault-tec/config.sh"
[ -f "$VTCONFIG" ] && source "$VTCONFIG"
VAULT="${1:-${VAULT_PATH:-}}"
[ -z "$VAULT" ] && echo "ERROR: No vault path configured" && exit 1

NOTES_DIR="$VAULT/notes"
OPS_DIR="$VAULT/ops"
BOBBLEHEAD_FILE="$OPS_DIR/bobbleheads.md"
TODAY=$(date +%Y-%m-%d)

# Configurable thresholds (from config or defaults)
TIER1="${BOBBLEHEAD_NOTES_TIER1:-100}"
TIER2="${BOBBLEHEAD_NOTES_TIER2:-500}"
TIER3="${BOBBLEHEAD_NOTES_TIER3:-1000}"
MAP_DEPTH="${BOBBLEHEAD_MAP_DEPTH:-30}"
SPRINT_COUNT="${BOBBLEHEAD_SPRINT_COUNT:-10}"
EVERGREEN_PCT="${BOBBLEHEAD_EVERGREEN_PCT:-50}"

# Temp files for state tracking
STATE_DIR=$(mktemp -d)
trap 'rm -rf "$STATE_DIR"' EXIT

# ── State Management ──────────────────────────────────────────────────────

# Parse existing bobblehead dates from state file into temp files
# Creates $STATE_DIR/date_<Name> files with the date as content
load_state() {
  if [[ -f "$BOBBLEHEAD_FILE" ]]; then
    local past_frontmatter=0
    local dash_count=0
    while IFS= read -r line; do
      if [[ "$line" == "---" ]]; then
        dash_count=$((dash_count + 1))
        if [[ "$dash_count" -ge 2 ]]; then
          past_frontmatter=1
        fi
        continue
      fi
      if [[ "$past_frontmatter" -eq 1 ]]; then
        # Parse: - **Name** — 2026-02-18 — Detail
        local name date_val
        name=$(echo "$line" | sed -n 's/^- \*\*\([^*]*\)\*\* — \([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\).*/\1/p')
        date_val=$(echo "$line" | sed -n 's/^- \*\*[^*]*\*\* — \([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\).*/\1/p')
        if [[ -n "$name" && -n "$date_val" ]]; then
          echo "$date_val" > "$STATE_DIR/date_$(echo "$name" | tr ' ' '_')"
        fi
      fi
    done < "$BOBBLEHEAD_FILE"
  fi
}

get_date() {
  local name="$1"
  local key="$STATE_DIR/date_$(echo "$name" | tr ' ' '_')"
  if [[ -f "$key" ]]; then
    cat "$key"
  fi
}

set_date() {
  local name="$1" date_val="$2"
  echo "$date_val" > "$STATE_DIR/date_$(echo "$name" | tr ' ' '_')"
}

# ── Shared Data (computed once) ───────────────────────────────────────────

# Count notes once
NOTE_COUNT=$(find "$NOTES_DIR" -maxdepth 1 -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' ')

# ── Condition Checks ──────────────────────────────────────────────────────
# Each function prints: EARNED|detail  or  PROGRESS|detail

check_perception() {
  local count
  count=$(find "$OPS_DIR/patterns" -name '*.md' -not -name 'README.md' 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$count" -gt 0 ]]; then
    echo "EARNED|First pattern detected"
  else
    echo "PROGRESS|No patterns detected yet"
  fi
}

check_intelligence() {
  if [[ "$NOTE_COUNT" -ge "$TIER1" ]]; then
    echo "EARNED|${NOTE_COUNT} notes"
  else
    echo "PROGRESS|${NOTE_COUNT}/${TIER1} notes"
  fi
}

check_endurance() {
  if [[ "$NOTE_COUNT" -ge "$TIER2" ]]; then
    echo "EARNED|${NOTE_COUNT} notes"
  else
    echo "PROGRESS|${NOTE_COUNT}/${TIER2} notes"
  fi
}

check_strength() {
  if [[ "$NOTE_COUNT" -ge "$TIER3" ]]; then
    echo "EARNED|${NOTE_COUNT} notes"
  else
    echo "PROGRESS|${NOTE_COUNT}/${TIER3} notes"
  fi
}

check_charisma() {
  local top count map_name
  top=$(grep -rh '^topics:' "$NOTES_DIR" 2>/dev/null \
    | grep -oE '\[\[[^]]+\]\]' \
    | sort | uniq -c | sort -rn | head -1)
  count=$(echo "$top" | awk '{print $1}')
  map_name=$(echo "$top" | sed 's/^[[:space:]]*[0-9]* //')
  if [[ -z "$count" ]]; then count=0; fi
  if [[ "$count" -ge "$MAP_DEPTH" ]]; then
    echo "EARNED|${map_name} has ${count} notes"
  else
    echo "PROGRESS|${count}/${MAP_DEPTH} notes on largest map"
  fi
}

check_agility() {
  local top_day count date_str
  top_day=$(grep -rh '^created:' "$NOTES_DIR" 2>/dev/null \
    | sed 's/created: *//; s/"//g; s/[[:space:]]*$//' \
    | sort | uniq -c | sort -rn | head -1)
  count=$(echo "$top_day" | awk '{print $1}')
  date_str=$(echo "$top_day" | awk '{print $2}')
  if [[ -z "$count" ]]; then count=0; fi
  if [[ "$count" -ge "$SPRINT_COUNT" ]]; then
    echo "EARNED|${count} notes on ${date_str}"
  else
    echo "PROGRESS|Best: ${count}/${SPRINT_COUNT} notes in one day"
  fi
}

check_luck() {
  local evergreen pct
  evergreen=$(grep -rl '^status: evergreen' "$NOTES_DIR" 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$NOTE_COUNT" -eq 0 ]]; then
    echo "PROGRESS|0%/${EVERGREEN_PCT}% evergreen"
    return
  fi
  pct=$((evergreen * 100 / NOTE_COUNT))
  if [[ "$pct" -ge "$EVERGREEN_PCT" ]]; then
    echo "EARNED|${pct}% evergreen (${evergreen}/${NOTE_COUNT})"
  else
    echo "PROGRESS|${pct}%/${EVERGREEN_PCT}% evergreen"
  fi
}

check_collector() {
  local count
  count=$(find "$OPS_DIR/inbox" -maxdepth 1 -type f 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$count" -eq 0 ]]; then
    echo "EARNED|Clean inbox"
  else
    echo "PROGRESS|${count} inbox items remaining"
  fi
}

check_wasteland_survival() {
  local earliest
  earliest=$(grep -rh '^created:' "$NOTES_DIR" 2>/dev/null \
    | sed 's/created: *//; s/"//g; s/[[:space:]]*$//' \
    | sort | head -1)
  if [[ -z "$earliest" ]]; then
    earliest=$(find "$NOTES_DIR" -name '*.md' -type f 2>/dev/null \
      | head -20 \
      | xargs stat -f '%SB' -t '%Y-%m-%d' 2>/dev/null \
      | sort | head -1)
  fi
  if [[ -z "$earliest" ]]; then
    echo "PROGRESS|Cannot determine vault age"
    return
  fi
  local earliest_epoch today_epoch diff_days
  if date -j -f '%Y-%m-%d' "$earliest" '+%s' >/dev/null 2>&1; then
    earliest_epoch=$(date -j -f '%Y-%m-%d' "$earliest" '+%s')
    today_epoch=$(date '+%s')
  else
    earliest_epoch=$(date -d "$earliest" '+%s' 2>/dev/null || echo 0)
    today_epoch=$(date '+%s')
  fi
  diff_days=$(( (today_epoch - earliest_epoch) / 86400 ))
  if [[ "$diff_days" -ge 30 ]]; then
    echo "EARNED|Vault ${diff_days} days old (since ${earliest})"
  else
    echo "PROGRESS|Vault ${diff_days}/30 days old"
  fi
}

check_nuka_cola_quantum() {
  local count
  count=$(grep -rl '^confidence: tested' "$NOTES_DIR" 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$count" -gt 0 ]]; then
    echo "EARNED|${count} tested notes"
  else
    echo "PROGRESS|No tested-confidence notes yet"
  fi
}

check_power_armor() {
  # Orphan detection — build link index once, check all notes against it
  local orphan_count=0
  local link_cache="$STATE_DIR/all_links"

  # Collect all wiki links in the vault (notes + self)
  grep -roh '\[\[[^]]*\]\]' "$NOTES_DIR" 2>/dev/null | sort -u > "$link_cache"
  grep -roh '\[\[[^]]*\]\]' "$VAULT/self" 2>/dev/null >> "$link_cache" 2>/dev/null || true

  while IFS= read -r filepath; do
    local filename
    filename=$(basename "$filepath" .md)
    if ! grep -qF "[[$filename]]" "$link_cache" 2>/dev/null; then
      orphan_count=$((orphan_count + 1))
    fi
  done < <(find "$NOTES_DIR" -maxdepth 1 -name '*.md' -type f 2>/dev/null)

  if [[ "$orphan_count" -eq 0 ]]; then
    echo "EARNED|0 orphaned notes"
  else
    echo "PROGRESS|${orphan_count} orphaned notes remaining"
  fi
}

check_pip_boy() {
  local count
  count=$(grep -rl '^type: map' "$NOTES_DIR" 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$count" -ge 10 ]]; then
    echo "EARNED|${count} maps"
  else
    echo "PROGRESS|${count}/10 maps"
  fi
}

check_fat_man() {
  # Find note with most incoming wiki-links from other files
  local top count note_name
  top=$(grep -roh '\[\[[^]]*\]\]' "$NOTES_DIR" 2>/dev/null \
    | sed 's/\[\[//; s/\]\]//' \
    | sort | uniq -c | sort -rn | head -1)
  count=$(echo "$top" | awk '{print $1}')
  note_name=$(echo "$top" | sed 's/^[[:space:]]*[0-9]* //')
  if [[ -z "$count" ]]; then count=0; fi
  if [[ "$count" -ge 10 ]]; then
    echo "EARNED|[[${note_name}]] has ${count} incoming links"
  else
    echo "PROGRESS|Best: ${count}/10 incoming links"
  fi
}

# ── Main ──────────────────────────────────────────────────────────────────

load_state

# Bobblehead definitions — parallel arrays (bash 3.2 compatible)
NAMES=(
  "Perception"
  "Intelligence"
  "Endurance"
  "Strength"
  "Charisma"
  "Agility"
  "Luck"
  "Collector"
  "Wasteland Survival"
  "Nuka-Cola Quantum"
  "Power Armor"
  "Pip-Boy"
  "Fat Man"
)

DESCS=(
  "First pattern detected"
  "${TIER1} notes"
  "${TIER2} notes"
  "${TIER3} notes"
  "${MAP_DEPTH}+ notes on a single map"
  "${SPRINT_COUNT}+ notes in one day"
  "${EVERGREEN_PCT}%+ evergreen notes"
  "Clean inbox"
  "Vault 30+ days old"
  "First tested note"
  "0 orphaned notes"
  "10+ maps"
  "10+ incoming links on one note"
)

FUNCS=(
  "check_perception"
  "check_intelligence"
  "check_endurance"
  "check_strength"
  "check_charisma"
  "check_agility"
  "check_luck"
  "check_collector"
  "check_wasteland_survival"
  "check_nuka_cola_quantum"
  "check_power_armor"
  "check_pip_boy"
  "check_fat_man"
)

# Run all checks, store results in temp files
collected_count=0
new_bobbleheads=""

for i in "${!NAMES[@]}"; do
  name="${NAMES[$i]}"
  func="${FUNCS[$i]}"
  result=$($func)
  status="${result%%|*}"
  detail="${result#*|}"

  echo "$status" > "$STATE_DIR/result_${i}"
  echo "$detail" > "$STATE_DIR/detail_${i}"

  if [[ "$status" == "EARNED" ]]; then
    collected_count=$((collected_count + 1))
    existing_date=$(get_date "$name")
    if [[ -z "$existing_date" ]]; then
      set_date "$name" "$TODAY"
      new_bobbleheads="${new_bobbleheads}${i} "
    fi
  fi
done

# Check Vault-Tec CEO
ceo_prereqs=$collected_count
ceo_idx=${#NAMES[@]}
if [[ "$collected_count" -eq ${#NAMES[@]} ]]; then
  echo "EARNED" > "$STATE_DIR/result_${ceo_idx}"
  echo "All bobbleheads collected!" > "$STATE_DIR/detail_${ceo_idx}"
  existing_date=$(get_date "Vault-Tec CEO")
  if [[ -z "$existing_date" ]]; then
    set_date "Vault-Tec CEO" "$TODAY"
    new_bobbleheads="${new_bobbleheads}${ceo_idx} "
  fi
  collected_count=$((collected_count + 1))
else
  echo "PROGRESS" > "$STATE_DIR/result_${ceo_idx}"
  echo "${ceo_prereqs}/${#NAMES[@]} prerequisites" > "$STATE_DIR/detail_${ceo_idx}"
fi

total_bobbleheads=$(( ${#NAMES[@]} + 1 ))

# Build full name list including CEO
ALL_NAMES=("${NAMES[@]}" "Vault-Tec CEO")
ALL_DESCS=("${DESCS[@]}" "All other bobbleheads collected")

# ── Output ────────────────────────────────────────────────────────────────

echo ""
echo "🎯 BOBBLEHEAD COLLECTION — ${collected_count}/${total_bobbleheads} collected"
echo ""

# Print earned bobbleheads first
for i in "${!ALL_NAMES[@]}"; do
  name="${ALL_NAMES[$i]}"
  status=$(cat "$STATE_DIR/result_${i}")
  detail=$(cat "$STATE_DIR/detail_${i}")
  earned_date=$(get_date "$name")

  if [[ "$status" == "EARNED" ]]; then
    printf "  ✅ %-22s — %-12s %s\n" "$name" "${earned_date:-$TODAY}" "$detail"
  fi
done

# Print unearned bobbleheads
for i in "${!ALL_NAMES[@]}"; do
  name="${ALL_NAMES[$i]}"
  status=$(cat "$STATE_DIR/result_${i}")
  detail=$(cat "$STATE_DIR/detail_${i}")

  if [[ "$status" == "PROGRESS" ]]; then
    printf "  ⬜ %-22s — %s\n" "$name" "$detail"
  fi
done

# Print new bobblehead celebrations
if [[ -n "$new_bobbleheads" ]]; then
  echo ""
  for idx in $new_bobbleheads; do
    if [[ "$idx" -lt ${#ALL_NAMES[@]} ]]; then
      name="${ALL_NAMES[$idx]}"
      desc="${ALL_DESCS[$idx]}"
      echo "  🎉 NEW BOBBLEHEAD: ${name}! ${desc}"
    fi
  done
fi

# Find next closest bobblehead to earn (first unearned non-CEO)
echo ""
for i in "${!ALL_NAMES[@]}"; do
  name="${ALL_NAMES[$i]}"
  status=$(cat "$STATE_DIR/result_${i}")
  detail=$(cat "$STATE_DIR/detail_${i}")

  if [[ "$status" == "PROGRESS" && "$name" != "Vault-Tec CEO" ]]; then
    hint=""
    case "$name" in
      Charisma)
        current=$(echo "$detail" | grep -oE '^[0-9]+' | head -1)
        needed=$((MAP_DEPTH - current))
        hint="${needed} more notes on your biggest map!"
        ;;
      Luck)
        hint="Keep promoting notes to evergreen status!"
        ;;
      Collector)
        count=$(echo "$detail" | grep -oE '^[0-9]+' | head -1)
        hint="Process ${count} inbox items to clear the queue!"
        ;;
      "Power Armor")
        count=$(echo "$detail" | grep -oE '^[0-9]+' | head -1)
        hint="Connect ${count} orphaned notes to the graph!"
        ;;
      "Fat Man")
        hint="Build a note into a major hub with 10+ incoming links!"
        ;;
      Intelligence)
        current=$(echo "$detail" | grep -oE '^[0-9]+' | head -1)
        needed=$((TIER1 - current))
        hint="${needed} more notes to reach ${TIER1}!"
        ;;
      Endurance)
        current=$(echo "$detail" | grep -oE '^[0-9]+' | head -1)
        needed=$((TIER2 - current))
        hint="${needed} more notes to reach ${TIER2}!"
        ;;
      Strength)
        current=$(echo "$detail" | grep -oE '^[0-9]+' | head -1)
        needed=$((TIER3 - current))
        hint="${needed} more notes to reach ${TIER3}!"
        ;;
      *)
        hint="$detail"
        ;;
    esac
    echo "  Next up: ${name} — ${hint}"
    break
  fi
done
echo ""

# ── Update State File ─────────────────────────────────────────────────────

{
  echo "---"
  echo "description: \"Vault-Tec Bobblehead collection — milestone tracker for vault growth\""
  echo "last_checked: ${TODAY}"
  echo "collected: ${collected_count}"
  echo "total: ${total_bobbleheads}"
  echo "---"
  echo ""
  echo "# Bobblehead Collection"
  echo ""
  echo "## Collected"
  echo ""

  for i in "${!ALL_NAMES[@]}"; do
    name="${ALL_NAMES[$i]}"
    status=$(cat "$STATE_DIR/result_${i}")
    if [[ "$status" == "EARNED" ]]; then
      earned_date=$(get_date "$name")
      detail=$(cat "$STATE_DIR/detail_${i}")
      echo "- **${name}** — ${earned_date:-$TODAY} — ${detail}"
    fi
  done

  echo ""
  echo "## In Progress"
  echo ""

  for i in "${!ALL_NAMES[@]}"; do
    name="${ALL_NAMES[$i]}"
    status=$(cat "$STATE_DIR/result_${i}")
    if [[ "$status" == "PROGRESS" ]]; then
      detail=$(cat "$STATE_DIR/detail_${i}")
      echo "- **${name}** — ${detail}"
    fi
  done
} > "$BOBBLEHEAD_FILE"
