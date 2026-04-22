#!/usr/bin/env bash
# score add — add a feature to score.json from the command line
set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo "Usage: score add <feature-name> [--depends-on ids] [verification-criterion...]"
  echo "Add a feature to score.json. Auto-assigns ID and priority."
  echo "Optional additional arguments become verification criteria."
  echo "Use --depends-on 1,2 to mark unmet feature dependencies."
  exit 0
fi

REPO_ROOT="${SCORE_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
SCORE_JSON="$REPO_ROOT/score.json"

if [[ -z "${1:-}" ]]; then
  echo "Usage: score add <feature-name> [--depends-on ids] [verification-criterion...]" >&2
  echo "" >&2
  echo "Examples:" >&2
  echo "  score add 'User authentication'" >&2
  echo "  score add 'User auth' 'login works' 'logout works' 'session persists'" >&2
  echo "  score add 'Feature B' --depends-on 1,2 'feature B passes tests'" >&2
  exit 1
fi

if [[ ! -f "$SCORE_JSON" ]]; then
  echo "ERROR: score.json not found" >&2
  exit 1
fi

FEATURE_NAME="$1"
shift

DEPENDS_ON='[]'
if [[ "${1:-}" == "--depends-on" ]]; then
  if [[ -z "${2:-}" ]]; then
    echo "ERROR: --depends-on requires a comma-separated list of feature ids" >&2
    exit 1
  fi
  DEPENDS_ON=$(printf '%s' "$2" | jq -R 'split(",") | map(select(length > 0) | tonumber)')
  shift 2
fi

# Auto-assign next ID and priority
MAX_ID=$(jq '[.features[].id] | if length > 0 then max else 0 end' "$SCORE_JSON")
NEXT_ID=$((MAX_ID + 1))

MAX_PRIORITY=$(jq '[.features[].priority] | if length > 0 then max else 0 end' "$SCORE_JSON")
NEXT_PRIORITY=$((MAX_PRIORITY + 1))

# Build verification array from remaining args, or use a default
if [[ $# -gt 0 ]]; then
  VERIFICATION=$(printf '%s\n' "$@" | jq -R . | jq -s .)
else
  VERIFICATION='["TODO: define verification criteria"]'
fi

# Add the feature
TMPFILE=$(mktemp)
jq --arg name "$FEATURE_NAME" \
   --argjson id "$NEXT_ID" \
   --argjson priority "$NEXT_PRIORITY" \
   --argjson verification "$VERIFICATION" \
   --argjson depends_on "$DEPENDS_ON" \
   '.features += [{"id": $id, "name": $name, "priority": $priority, "verification": $verification, "passes": false, "depends_on": $depends_on}]' \
   "$SCORE_JSON" > "$TMPFILE" && mv "$TMPFILE" "$SCORE_JSON"

echo "Added feature #$NEXT_ID: $FEATURE_NAME (priority: $NEXT_PRIORITY, passes: false, depends_on: $(jq -c . <<< "$DEPENDS_ON"))"
