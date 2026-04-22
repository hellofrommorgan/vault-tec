#!/usr/bin/env bash
# score plan — summarized planning surface with optional full vision dump
set -euo pipefail

MODE="summary"
case "${1:-}" in
  --help|-h)
    echo "Usage: score plan [--full]"
    echo "Summarize vision, state, and knowledge for intent decomposition."
    exit 0
    ;;
  --full)
    MODE="full"
    ;;
  "")
    MODE="summary"
    ;;
  *)
    echo "ERROR: Unknown option '$1'" >&2
    echo "Usage: score plan [--full]" >&2
    exit 1
    ;;
esac

REPO_ROOT="${SCORE_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
SCORE_JSON="$REPO_ROOT/score.json"

if [[ ! -f "$SCORE_JSON" ]]; then
  echo "ERROR: score.json not found" >&2
  exit 1
fi

echo "=== Score Plan ==="
echo "Mode: $MODE"
echo ""

echo "--- Vision ---"
VISION=$(jq -r '.vision // empty' "$SCORE_JSON")
if [[ -n "$VISION" ]]; then
  echo "$VISION"
else
  echo "(no vision field in score.json)"
fi
echo ""

if [[ -f "$REPO_ROOT/VISION.md" ]]; then
  if [[ "$MODE" == "full" ]]; then
    echo "--- VISION.md ---"
    cat "$REPO_ROOT/VISION.md"
  else
    echo "--- VISION.md Summary ---"
    awk '
      /^## / {print $0}
    ' "$REPO_ROOT/VISION.md"
    WHAT_IT_IS=$(awk '/^## What It Is/{flag=1; next} /^## /{if(flag) exit} flag && NF{print; exit}' "$REPO_ROOT/VISION.md")
    if [[ -n "$WHAT_IT_IS" ]]; then
      echo ""
      echo "What It Is: $WHAT_IT_IS"
    fi
    echo ""
    echo "Use 'score plan --full' to print the full VISION.md."
  fi
  echo ""
fi

echo "--- Current State ---"
"$REPO_ROOT/.score/status.sh" --brief
echo ""

if [[ -f "$REPO_ROOT/progress.md" ]] && grep -q "## Learnings" "$REPO_ROOT/progress.md"; then
  echo "--- Recent Learnings ---"
  sed -n '/## Learnings/,/## /{ /## Learnings/d; /## [^L]/d; p; }' "$REPO_ROOT/progress.md" | head -20
  echo ""
fi

TOTAL=$(jq '.features | length' "$SCORE_JSON")
PASSED=$(jq '[.features[] | select(.passes == true)] | length' "$SCORE_JSON")
REMAINING=$((TOTAL - PASSED))

echo "--- Next Step ---"
if [[ $REMAINING -gt 0 ]]; then
  echo "There are $REMAINING incomplete features. Work on ready features first,"
  echo "or propose new features if the vision has evolved."
else
  echo "All features passing. Review the summarized vision and current state."
  echo ""
  echo "As the agent, you should now:"
  echo "  1. Identify gaps between vision and current mechanism"
  echo "  2. Propose 3-7 new features with verification criteria"
  echo "  3. Surface the proposed plan as a STEERING MOMENT for human approval"
  echo "  4. Do NOT add features to score.json until the human approves"
fi
