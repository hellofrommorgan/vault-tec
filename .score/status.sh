#!/usr/bin/env bash
# score status — show bounded orientation summary or full detail
set -euo pipefail

MODE="brief"
case "${1:-}" in
  --help|-h)
    echo "Usage: score status [--brief|--full]"
    echo "Show bounded orientation summary (--brief, default) or full detail (--full)."
    exit 0
    ;;
  --brief|"")
    MODE="brief"
    ;;
  --full)
    MODE="full"
    ;;
  *)
    echo "ERROR: Unknown option '$1'" >&2
    echo "Usage: score status [--brief|--full]" >&2
    exit 1
    ;;
esac

REPO_ROOT="${SCORE_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
SCORE_JSON="$REPO_ROOT/score.json"
PROGRESS_FILE="$REPO_ROOT/progress.md"

if [[ ! -f "$SCORE_JSON" ]]; then
  echo "ERROR: score.json not found at $SCORE_JSON" >&2
  exit 1
fi

feature_is_ready() {
  local feature_id="$1"
  local deps dep dep_pass
  deps=$(jq -r --argjson id "$feature_id" '.features[] | select(.id == $id) | (.depends_on // [])[]?' "$SCORE_JSON")
  if [[ -z "$deps" ]]; then
    return 0
  fi
  while IFS= read -r dep; do
    [[ -n "$dep" ]] || continue
    dep_pass=$(jq -r --argjson dep "$dep" '.features[] | select(.id == $dep) | .passes // false' "$SCORE_JSON")
    if [[ "$dep_pass" != "true" ]]; then
      return 1
    fi
  done <<< "$deps"
  return 0
}

feature_unmet_deps() {
  local feature_id="$1"
  local deps dep dep_pass names=()
  deps=$(jq -r --argjson id "$feature_id" '.features[] | select(.id == $id) | (.depends_on // [])[]?' "$SCORE_JSON")
  if [[ -z "$deps" ]]; then
    return 0
  fi
  while IFS= read -r dep; do
    [[ -n "$dep" ]] || continue
    dep_pass=$(jq -r --argjson dep "$dep" '.features[] | select(.id == $dep) | .passes // false' "$SCORE_JSON")
    if [[ "$dep_pass" != "true" ]]; then
      names+=("#$dep")
    fi
  done <<< "$deps"
  if [[ ${#names[@]} -gt 0 ]]; then
    printf '%s' "${names[*]}"
  fi
}

progress_value() {
  local heading="$1"
  if [[ -f "$PROGRESS_FILE" ]]; then
    awk -v heading="$heading" '$0 == heading {getline; print; exit}' "$PROGRESS_FILE"
  fi
}

PROJECT=$(jq -r '.project' "$SCORE_JSON")
TOTAL=$(jq '.features | length' "$SCORE_JSON")
PASSED=$(jq '[.features[] | select(.passes == true)] | length' "$SCORE_JSON")
INCOMPLETE_IDS=$(jq -r '.features | sort_by(.priority)[] | select(.passes == false) | .id' "$SCORE_JSON")
READY_COUNT=0
BLOCKED_COUNT=0
NEXT_READY=""
BLOCKED_LINES=()

while IFS= read -r feature_id; do
  [[ -n "$feature_id" ]] || continue
  feature_name=$(jq -r --argjson id "$feature_id" '.features[] | select(.id == $id) | .name' "$SCORE_JSON")
  feature_priority=$(jq -r --argjson id "$feature_id" '.features[] | select(.id == $id) | .priority' "$SCORE_JSON")
  if feature_is_ready "$feature_id"; then
    READY_COUNT=$((READY_COUNT + 1))
    if [[ -z "$NEXT_READY" ]]; then
      NEXT_READY="#${feature_id}: ${feature_name}"
    fi
  else
    BLOCKED_COUNT=$((BLOCKED_COUNT + 1))
    unmet=$(feature_unmet_deps "$feature_id")
    BLOCKED_LINES+=("  [BLOCK] #${feature_id} (p${feature_priority}): ${feature_name} — waiting on ${unmet}")
  fi
done <<< "$INCOMPLETE_IDS"

REMAINING=$((TOTAL - PASSED))
CURRENT_STATE=$(progress_value "## Current State")
LAST_COMPLETED=$(progress_value "## Last Completed Feature")
NEXT_FEATURE_NOTE=$(progress_value "## Next Feature")

echo "=== Score Status: $PROJECT ==="
echo "Mode: $MODE"
echo ""

VISION=$(jq -r '.vision // empty' "$SCORE_JSON")
if [[ -n "$VISION" ]]; then
  VISION_SHORT=$(printf '%s' "$VISION" | head -c 120)
  if [[ ${#VISION} -gt 120 ]]; then
    VISION_SHORT="${VISION_SHORT}..."
  fi
  echo "Vision: $VISION_SHORT"
  echo ""
fi

if [[ -n "$CURRENT_STATE" || -n "$LAST_COMPLETED" || -n "$NEXT_FEATURE_NOTE" ]]; then
  echo "--- Progress ---"
  [[ -n "$CURRENT_STATE" ]] && echo "Current State: $CURRENT_STATE"
  [[ -n "$LAST_COMPLETED" ]] && echo "Last Completed: $LAST_COMPLETED"
  [[ -n "$NEXT_FEATURE_NOTE" ]] && echo "Progress Next: $NEXT_FEATURE_NOTE"
  echo ""
fi

echo "Features: $TOTAL total | $PASSED passed | $READY_COUNT ready | $BLOCKED_COUNT blocked | $REMAINING remaining"
echo ""

if [[ "$MODE" == "full" ]]; then
  echo "--- Feature List ---"
  ALL_FEATURE_IDS=$(jq -r '.features[] | .id' "$SCORE_JSON")
  while IFS= read -r feature_id; do
    [[ -n "$feature_id" ]] || continue
    feature_name=$(jq -r --argjson id "$feature_id" '.features[] | select(.id == $id) | .name' "$SCORE_JSON")
    feature_priority=$(jq -r --argjson id "$feature_id" '.features[] | select(.id == $id) | .priority' "$SCORE_JSON")
    feature_pass=$(jq -r --argjson id "$feature_id" '.features[] | select(.id == $id) | .passes' "$SCORE_JSON")
    if [[ "$feature_pass" == "true" ]]; then
      echo "  [PASS ] #${feature_id} (p${feature_priority}): ${feature_name}"
    elif feature_is_ready "$feature_id"; then
      echo "  [READY] #${feature_id} (p${feature_priority}): ${feature_name}"
    else
      unmet=$(feature_unmet_deps "$feature_id")
      echo "  [BLOCK] #${feature_id} (p${feature_priority}): ${feature_name} — waiting on ${unmet}"
    fi
  done <<< "$ALL_FEATURE_IDS"
  echo ""
fi

KB_COUNT=0
KB_ENTRIES=()
if [[ -d "$REPO_ROOT/knowledge" ]]; then
  for f in "$REPO_ROOT/knowledge"/*.md; do
    [[ -f "$f" ]] || continue
    [[ "$(basename "$f")" == "README.md" ]] && continue
    KB_COUNT=$((KB_COUNT + 1))
    KB_ENTRIES+=("$(basename "$f")")
  done
fi

if [[ $KB_COUNT -gt 0 ]]; then
  echo "--- Knowledge Base ($KB_COUNT entries) ---"
  KB_LIMIT=3
  [[ "$MODE" == "full" ]] && KB_LIMIT=5
  printf '%s\n' "${KB_ENTRIES[@]}" | sort -r | head -"$KB_LIMIT" | while read -r entry; do
    TITLE=$(head -1 "$REPO_ROOT/knowledge/$entry" | sed 's/^#* *//')
    echo "  - $TITLE ($entry)"
  done
  echo ""
fi

if [[ -n "$NEXT_READY" ]]; then
  echo "Next ready: $NEXT_READY"
elif [[ $REMAINING -eq 0 ]]; then
  echo "All features passing. Run 'score plan' to decompose intent into new work."
else
  echo "No ready features. Remaining work is blocked by unmet dependencies."
fi

if [[ "$MODE" == "full" && ${#BLOCKED_LINES[@]} -gt 0 ]]; then
  echo ""
  echo "--- Blocked Features ---"
  printf '%s\n' "${BLOCKED_LINES[@]}"
fi
