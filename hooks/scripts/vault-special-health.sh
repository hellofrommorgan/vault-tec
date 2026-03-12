#!/bin/bash
# ╔══════════════════════════════════════════════════════════╗
# ║  VAULT-TEC S.P.E.C.I.A.L. HEALTH DASHBOARD             ║
# ║  War never changes. But your vault's health can.        ║
# ╚══════════════════════════════════════════════════════════╝
#
# Computes seven health metrics for an Obsidian knowledge vault:
#   S — Structure     (schema compliance)
#   P — Propagation   (connection density)
#   E — Evergreen %   (maturity ratio)
#   C — Coverage      (map coverage)
#   I — Intake        (inbox health, inverted)
#   A — Activity      (metabolic rate)
#   L — Longevity     (reweave freshness)
#
# Usage: vault-special-health.sh [vault-path]
#
# Optimized for macOS (bash 3.2, BSD awk). No gawk/bash4 features.
# Target: < 5 seconds on a 1000-note vault.

set -euo pipefail

# Load vault-tec config
VTCONFIG="$HOME/.vault-tec/config.sh"
[ -f "$VTCONFIG" ] && source "$VTCONFIG"
VAULT="${1:-${VAULT_PATH:-}}"
[ -z "$VAULT" ] && echo "ERROR: No vault path configured" && exit 1

NOTES_DIR="$VAULT/notes"
INBOX_DIR="$VAULT/ops/inbox"

if [ ! -d "$NOTES_DIR" ]; then
    echo "ERROR: Notes directory not found at $NOTES_DIR"
    exit 1
fi

# ── Count total notes ────────────────────────────────────────
TOTAL_NOTES=$(find "$NOTES_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
if [ "$TOTAL_NOTES" -eq 0 ]; then
    echo "ERROR: No notes found in $NOTES_DIR"
    exit 1
fi

# ══════════════════════════════════════════════════════════════
# S — Structure (schema compliance)
# ══════════════════════════════════════════════════════════════
# Fast: grep -rl for each field, intersect with comm
has_desc=$(grep -rl '^description:' "$NOTES_DIR"/ --include="*.md" 2>/dev/null | sort)
has_topics=$(grep -rl '^topics:' "$NOTES_DIR"/ --include="*.md" 2>/dev/null | sort)
compliant=$(comm -12 <(echo "$has_desc") <(echo "$has_topics") | wc -l | tr -d ' ')

S_pct=$((compliant * 100 / TOTAL_NOTES))
S_score=$((S_pct / 10))
if [ "$S_score" -gt 10 ]; then S_score=10; fi

# ══════════════════════════════════════════════════════════════
# P — Propagation (connection density)
# ══════════════════════════════════════════════════════════════
total_links=$(grep -roh '\[\[' "$NOTES_DIR"/ --include="*.md" 2>/dev/null | wc -l | tr -d ' ')
P_avg=$(awk "BEGIN { printf \"%.1f\", $total_links / $TOTAL_NOTES }")
P_score=$(awk "BEGIN { s = int($total_links / $TOTAL_NOTES * 2); if (s>10) s=10; print s }")

# ══════════════════════════════════════════════════════════════
# E — Evergreen % (maturity ratio)
# ══════════════════════════════════════════════════════════════
evergreen_count=$(grep -rl '^status: evergreen' "$NOTES_DIR"/ --include="*.md" 2>/dev/null | wc -l | tr -d ' ')
E_pct=$((evergreen_count * 100 / TOTAL_NOTES))
E_score=$((E_pct / 5))
if [ "$E_score" -gt 10 ]; then E_score=10; fi

# ══════════════════════════════════════════════════════════════
# C — Coverage (map coverage)
# ══════════════════════════════════════════════════════════════
map_files=$(grep -rl '^type: map' "$NOTES_DIR"/ --include="*.md" 2>/dev/null || true)
TOTAL_MAPS=$(echo "$map_files" | grep -c '.' 2>/dev/null || echo 0)

# Extract all link targets from maps
covered_targets=""
if [ "$TOTAL_MAPS" -gt 0 ]; then
    covered_targets=$(echo "$map_files" \
        | xargs grep -oh '\[\[[^]]*\]\]' 2>/dev/null \
        | sed 's/\[\[//g; s/\]\]//g' \
        | sort -u)
fi

# Get basenames
map_bnames=$(echo "$map_files" | xargs -I{} basename {} .md 2>/dev/null | sort -u)
all_bnames=$(find "$NOTES_DIR" -maxdepth 1 -name "*.md" -type f -exec basename {} .md \; | sort -u)
non_map_names=$(comm -23 <(echo "$all_bnames") <(echo "$map_bnames"))
non_map_total=$(echo "$non_map_names" | grep -c '.' 2>/dev/null || echo 0)

covered_count=0
if [ -n "$covered_targets" ] && [ "$non_map_total" -gt 0 ]; then
    covered_count=$(echo "$non_map_names" | grep -cxF -f <(echo "$covered_targets") 2>/dev/null || echo 0)
fi

if [ "$non_map_total" -gt 0 ]; then
    C_pct=$((covered_count * 100 / non_map_total))
else
    C_pct=0
fi
C_score=$((C_pct / 10))
if [ "$C_score" -gt 10 ]; then C_score=10; fi

# ══════════════════════════════════════════════════════════════
# I — Intake (inbox health, inverted)
# ══════════════════════════════════════════════════════════════
inbox_count=$(find "$INBOX_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
if [ "$inbox_count" -ge 30 ]; then     I_score=0
elif [ "$inbox_count" -ge 20 ]; then   I_score=1
elif [ "$inbox_count" -ge 10 ]; then   I_score=$((5 - (inbox_count - 10) * 3 / 10))
elif [ "$inbox_count" -ge 3 ]; then    I_score=$((8 - (inbox_count - 3) * 3 / 7))
elif [ "$inbox_count" -ge 1 ]; then    I_score=9
else                                    I_score=10
fi
if [ "$I_score" -lt 0 ]; then I_score=0; fi

# ══════════════════════════════════════════════════════════════
# A — Activity (metabolic rate)
# ══════════════════════════════════════════════════════════════
recent_7d=$(find "$NOTES_DIR" -maxdepth 1 -name "*.md" -type f -mtime -7 2>/dev/null | wc -l | tr -d ' ')
if [ "$recent_7d" -ge 30 ]; then       A_score=10
elif [ "$recent_7d" -ge 15 ]; then     A_score=$((6 + (recent_7d - 15) * 4 / 15))
elif [ "$recent_7d" -ge 5 ]; then      A_score=$((3 + (recent_7d - 5) * 3 / 10))
elif [ "$recent_7d" -ge 1 ]; then      A_score=$((1 + (recent_7d - 1) * 2 / 4))
else                                    A_score=0
fi
if [ "$A_score" -gt 10 ]; then A_score=10; fi

# ══════════════════════════════════════════════════════════════
# L — Longevity (reweave freshness)
# ══════════════════════════════════════════════════════════════
# Threshold: 30 days ago as YYYY-MM-DD (string comparison works)
threshold_date=$(date -v-30d "+%Y-%m-%d" 2>/dev/null \
    || date -d "30 days ago" "+%Y-%m-%d" 2>/dev/null \
    || echo "1970-01-01")

# Extract created dates from all notes in one grep pass
# Format: "YYYY-MM-DD:filepath"
date_map=$(grep -rH '^created:' "$NOTES_DIR"/ --include="*.md" 2>/dev/null \
    | sed 's/:created: */:/; s/"//g; s/ *$//' \
    | awk -F: '{ print $2 ":" $1 }')

# Filter to notes created before threshold
OLD_FILE=$(mktemp)
echo "$date_map" | awk -F: -v thresh="$threshold_date" '$1 < thresh && $2 != "" { print $2 }' > "$OLD_FILE"
old_count=$(wc -l < "$OLD_FILE" | tr -d ' ')

rewoven=0
L_pct=0
if [ "$old_count" -gt 0 ]; then
    # Check which old files were modified in the last 30 days
    ref_file=$(mktemp)
    touch -t "$(date -v-30d '+%Y%m%d%H%M.%S' 2>/dev/null || date -d '30 days ago' '+%Y%m%d%H%M.%S' 2>/dev/null)" "$ref_file" 2>/dev/null
    while IFS= read -r f; do
        [ -z "$f" ] && continue
        if [ "$f" -nt "$ref_file" ] 2>/dev/null; then
            rewoven=$((rewoven + 1))
        fi
    done < "$OLD_FILE"
    rm -f "$ref_file"
    L_pct=$((rewoven * 100 / old_count))
    L_score=$((L_pct / 5))
else
    L_score=10  # No old notes = nothing to reweave
fi
rm -f "$OLD_FILE"
if [ "$L_score" -gt 10 ]; then L_score=10; fi
if [ "$L_score" -lt 0 ]; then L_score=0; fi

# ══════════════════════════════════════════════════════════════
# Composite & Recommendation
# ══════════════════════════════════════════════════════════════
composite=$(awk "BEGIN { printf \"%.1f\", ($S_score + $P_score + $E_score + $C_score + $I_score + $A_score + $L_score) / 7.0 }")

comp_int=${composite%.*}
if [ "$comp_int" -ge 8 ]; then      rating="OUTSTANDING"
elif [ "$comp_int" -ge 6 ]; then    rating="GOOD"
elif [ "$comp_int" -ge 4 ]; then    rating="FAIR"
elif [ "$comp_int" -ge 2 ]; then    rating="POOR"
else                                 rating="CRITICAL"
fi

# Find lowest stat
lowest_key="S"; lowest_val=$S_score
for pair in "P:$P_score" "E:$E_score" "C:$C_score" "I:$I_score" "A:$A_score" "L:$L_score"; do
    key="${pair%%:*}"; val="${pair##*:}"
    if [ "$val" -lt "$lowest_val" ]; then lowest_val=$val; lowest_key=$key; fi
done

case "$lowest_key" in
    S) rec="Schema gaps detected. Run /vault-tec:health to find notes missing description or topics." ;;
    P) rec="Low link density. Run /vault-tec:reweave on recent notes to strengthen connections." ;;
    E) rec="Few evergreen notes. Review growing notes and promote mature ones to evergreen status." ;;
    C) rec="Notes drifting outside map coverage. Create or update maps to cover orphaned notes." ;;
    I) rec="Inbox pressure building. Process inbox items through the pipeline before capturing more." ;;
    A) rec="Low metabolic rate. The vault needs active tending -- revisit, reflect, or seed new material." ;;
    L) rec="Old notes going stale. Run /vault-tec:reweave on notes untouched for 30+ days." ;;
esac

# ══════════════════════════════════════════════════════════════
# Output
# ══════════════════════════════════════════════════════════════
bar() {
    local s=$1 r="" i=0
    while [ $i -lt "$s" ]; do r="${r}█"; i=$((i + 1)); done
    while [ $i -lt 10 ]; do r="${r}░"; i=$((i + 1)); done
    echo "$r"
}

vn="${VAULT_NAME:-$(basename "$VAULT")}"
S_b=$(bar $S_score); P_b=$(bar $P_score); E_b=$(bar $E_score); C_b=$(bar $C_score)
I_b=$(bar $I_score); A_b=$(bar $A_score); L_b=$(bar $L_score)

cat <<DASHBOARD

╔══════════════════════════════════════════════════════════════════════╗
║              VAULT-TEC S.P.E.C.I.A.L. DIAGNOSTICS                  ║
║              $(printf '%-40s' "Vault: $vn")                    ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  S — Structure      ${S_b}  $(printf '%-2s' $S_score)/10  $(printf '%-25s' "(${S_pct}% schema-compliant)")  ║
║  P — Propagation    ${P_b}  $(printf '%-2s' $P_score)/10  $(printf '%-25s' "(${P_avg} links/note avg)")  ║
║  E — Evergreen %    ${E_b}  $(printf '%-2s' $E_score)/10  $(printf '%-25s' "(${E_pct}% evergreen)")  ║
║  C — Coverage       ${C_b}  $(printf '%-2s' $C_score)/10  $(printf '%-25s' "(${C_pct}% map-covered)")  ║
║  I — Intake         ${I_b}  $(printf '%-2s' $I_score)/10  $(printf '%-25s' "(${inbox_count} inbox items)")  ║
║  A — Activity       ${A_b}  $(printf '%-2s' $A_score)/10  $(printf '%-25s' "(${recent_7d} notes / 7 days)")  ║
║  L — Longevity      ${L_b}  $(printf '%-2s' $L_score)/10  $(printf '%-25s' "(${L_pct}% rewoven)")  ║
║                                                                      ║
╠══════════════════════════════════════════════════════════════════════╣
║  COMPOSITE: $(printf '%-7s' "${composite}/10")  [ ${rating} ]                                    ║
╠══════════════════════════════════════════════════════════════════════╣
║  $(printf '%-4s' $TOTAL_NOTES) notes | $(printf '%-3s' $TOTAL_MAPS) maps | $(printf '%-4s' $evergreen_count) evergreen | $(printf '%-5s' $total_links) total links              ║
╚══════════════════════════════════════════════════════════════════════╝

REC: ${rec}

DASHBOARD
