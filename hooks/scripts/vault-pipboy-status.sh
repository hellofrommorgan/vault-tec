#!/usr/bin/env bash
# vault-pipboy-status.sh — Fast one-liner pulse check for session-start
# Prints a single Pip-Boy status bar for instant orientation.
# Must complete in <2s on a 1000-note vault. Skips Coverage & Longevity.
#
# Output: ⚡ Mind | 1049 notes | GOOD (7.1) | 3 inbox | 2 orphans | 12 mR
# Usage: vault-pipboy-status.sh [vault-path]
# NOTE: Needs chmod +x after creation.

set -euo pipefail

# ── Config ────────────────────────────────────────────────────
VTCONFIG="$HOME/.vault-tec/config.sh"
[ -f "$VTCONFIG" ] && source "$VTCONFIG"
VAULT="${1:-${VAULT_PATH:-}}"

# Exit cleanly if vault or notes dir doesn't exist
[ -z "$VAULT" ] && exit 0
[ ! -d "$VAULT/notes" ] && exit 0

NOTES_DIR="$VAULT/notes"
INBOX_DIR="$VAULT/ops/inbox"

# ── Counts ────────────────────────────────────────────────────
TOTAL_NOTES=$(find "$NOTES_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
[ "$TOTAL_NOTES" -eq 0 ] && exit 0

# ── S — Structure (schema compliance) ────────────────────────
# Count files that have BOTH description: and topics:
has_desc=$(grep -rl '^description:' "$NOTES_DIR"/ --include="*.md" 2>/dev/null | sort)
has_topics=$(grep -rl '^topics:' "$NOTES_DIR"/ --include="*.md" 2>/dev/null | sort)
compliant=$(comm -12 <(echo "$has_desc") <(echo "$has_topics") | wc -l | tr -d ' ')

S_pct=$((compliant * 100 / TOTAL_NOTES))
S_score=$((S_pct / 10))
if [ "$S_score" -gt 10 ]; then S_score=10; fi

# ── P — Propagation (connection density) ─────────────────────
total_links=$(grep -roh '\[\[' "$NOTES_DIR"/ --include="*.md" 2>/dev/null | wc -l | tr -d ' ')
P_score=$(awk "BEGIN { s = int($total_links / $TOTAL_NOTES * 2); if (s>10) s=10; print s }")

# ── E — Evergreen % (maturity ratio) ─────────────────────────
evergreen_count=$(grep -rl '^status: evergreen' "$NOTES_DIR"/ --include="*.md" 2>/dev/null | wc -l | tr -d ' ')
E_pct=$((evergreen_count * 100 / TOTAL_NOTES))
E_score=$((E_pct / 5))
if [ "$E_score" -gt 10 ]; then E_score=10; fi

# ── I — Intake (inbox health, inverted) ──────────────────────
inbox_count=0
if [ -d "$INBOX_DIR" ]; then
  inbox_count=$(find "$INBOX_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
fi

if [ "$inbox_count" -ge 30 ]; then     I_score=0
elif [ "$inbox_count" -ge 20 ]; then   I_score=1
elif [ "$inbox_count" -ge 10 ]; then   I_score=$((5 - (inbox_count - 10) * 3 / 10))
elif [ "$inbox_count" -ge 3 ]; then    I_score=$((8 - (inbox_count - 3) * 3 / 7))
elif [ "$inbox_count" -ge 1 ]; then    I_score=9
else                                    I_score=10
fi
if [ "$I_score" -lt 0 ]; then I_score=0; fi

# ── A — Activity (metabolic rate) ────────────────────────────
recent_7d=$(find "$NOTES_DIR" -maxdepth 1 -name "*.md" -type f -mtime -7 2>/dev/null | wc -l | tr -d ' ')
if [ "$recent_7d" -ge 30 ]; then       A_score=10
elif [ "$recent_7d" -ge 15 ]; then     A_score=$((6 + (recent_7d - 15) * 4 / 15))
elif [ "$recent_7d" -ge 5 ]; then      A_score=$((3 + (recent_7d - 5) * 3 / 10))
elif [ "$recent_7d" -ge 1 ]; then      A_score=$((1 + (recent_7d - 1) * 2 / 4))
else                                    A_score=0
fi
if [ "$A_score" -gt 10 ]; then A_score=10; fi

# ── Composite (5-stat average, skip C and L for speed) ───────
composite=$(awk "BEGIN { printf \"%.1f\", ($S_score + $P_score + $E_score + $I_score + $A_score) / 5.0 }")

comp_int=${composite%.*}
if [ "$comp_int" -ge 8 ]; then      rating="OUTSTANDING"
elif [ "$comp_int" -ge 6 ]; then    rating="GOOD"
elif [ "$comp_int" -ge 4 ]; then    rating="FAIR"
elif [ "$comp_int" -ge 2 ]; then    rating="POOR"
else                                 rating="CRITICAL"
fi

# ── Orphan count (fast estimate) ─────────────────────────────
# All note basenames, minus unique link targets from notes/ and self/
all_notes=$(find "$NOTES_DIR" -maxdepth 1 -name "*.md" -type f \
  | sed 's|.*/||;s|\.md$||' \
  | sort)

linked_targets=$(grep -roh --include="*.md" '\[\[[^]]*\]\]' "$NOTES_DIR" "$VAULT/self" 2>/dev/null \
  | sed 's/\[\[//;s/\]\]//;s/#.*//;s/|.*//' \
  | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
  | grep -v '^$' \
  | sort -u)

orphan_count=$(comm -23 <(echo "$all_notes") <(echo "$linked_targets") | wc -l | tr -d ' ')

# ── Quick mR estimate (orphans + inbox only) ─────────────────
ORPHAN_WEIGHT="${RAD_ORPHAN_WEIGHT:-2}"
INBOX_WEIGHT="${RAD_INBOX_WEIGHT:-0.5}"

orphan_mr=$((orphan_count * ORPHAN_WEIGHT))
inbox_mr=$(awk "BEGIN { printf \"%.0f\", $inbox_count * $INBOX_WEIGHT }")
total_mr=$((orphan_mr + inbox_mr))

# ── Output ────────────────────────────────────────────────────
vn="${VAULT_NAME:-$(basename "$VAULT")}"
echo "⚡ ${vn} | ${TOTAL_NOTES} notes | ${rating} (${composite}) | ${inbox_count} inbox | ${orphan_count} orphans | ${total_mr} mR"
