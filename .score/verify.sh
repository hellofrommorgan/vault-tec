#!/usr/bin/env bash
# score verify — THE gate. Runs tests and atomically updates score.json.
# The passes field is script-owned. The agent calls this but cannot game the result.
set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo "Usage: score verify <feature-id>"
  echo "Run tests and update pass/fail for a feature in score.json."
  echo "Runs global test_command and optional per-feature test_script unless require_global is false."
  exit 0
fi

ROOT_HINT="${SCORE_ROOT:-$(cd "$(dirname "$0")/.." && pwd -P)}"
REPO_ROOT="$(python3 - <<'PY' "$ROOT_HINT"
import os, sys
print(os.path.realpath(sys.argv[1]))
PY
)"
SCORE_JSON="$REPO_ROOT/score.json"
STATE_DIR="$REPO_ROOT/.score/state"
BASELINE_FILE="$STATE_DIR/verification-baselines.tsv"

run_check() {
  local cmd="$1"
  if [[ -z "$cmd" || "$cmd" == "null" ]]; then
    return 2
  fi
  if (cd "$REPO_ROOT" && eval "$cmd"); then
    return 0
  fi
  return 1
}

normalize_path() {
  local path="$1"
  python3 - <<'PY' "$path"
import os, re, sys
path = sys.argv[1]
path = re.sub(r'^\./+', '', path)
print(os.path.normpath(path))
PY
}

is_trackable_rel_path() {
  local rel_path="$1"
  case "$rel_path" in
    ../*|..|/*) return 1 ;;
    *) return 0 ;;
  esac
}

extract_command_path_token() {
  local cmd="$1"
  local raw_token rel_path
  if [[ "$cmd" =~ ^(\./[^[:space:];\|&<>]+) ]]; then
    raw_token="${BASH_REMATCH[1]}"
    if printf '%s' "$raw_token" | grep -q '[`$"{}()\[\]*?!~\\]'; then
      return 1
    fi
    rel_path=$(normalize_path "$raw_token")
    is_trackable_rel_path "$rel_path" || return 1
    printf '%s\n' "$rel_path"
    return 0
  fi
  return 1
}

compute_digest() {
  local rel_path="$1"
  local digest
  digest=$(cd "$REPO_ROOT" && shasum -a 256 -- "$rel_path" 2>/dev/null | awk '{print $1}') || return 1
  [[ -n "$digest" ]] || return 1
  printf '%s\n' "$digest"
}

ensure_baseline_dir() {
  mkdir -p "$STATE_DIR"
  touch "$BASELINE_FILE"
}

get_recorded_digest() {
  local rel_path="$1"
  if [[ ! -f "$BASELINE_FILE" ]]; then
    return 1
  fi
  awk -F '\t' -v p="$rel_path" '$1 == p {print $2; found=1; exit} END {if (!found) exit 1}' "$BASELINE_FILE"
}

set_recorded_digest() {
  local rel_path="$1"
  local digest="$2"
  local tmpfile
  ensure_baseline_dir
  tmpfile=$(mktemp)
  if [[ -f "$BASELINE_FILE" ]]; then
    awk -F '\t' -v p="$rel_path" '$1 != p {print $1 "\t" $2}' "$BASELINE_FILE" > "$tmpfile"
  fi
  printf '%s\t%s\n' "$rel_path" "$digest" >> "$tmpfile"
  mv "$tmpfile" "$BASELINE_FILE"
}

check_tracked_input() {
  local rel_path="$1"
  local current recorded resolved_root resolved_target
  [[ -n "$rel_path" ]] || return 0
  recorded=$(get_recorded_digest "$rel_path" || true)
  if [[ ! -e "$REPO_ROOT/$rel_path" ]]; then
    if [[ -n "$recorded" ]]; then
      echo "TAMPER DETECTED: tracked verification input missing: $rel_path" >&2
      return 1
    fi
    return 2
  fi
  resolved_root=$(cd "$REPO_ROOT" && python3 - <<'PY'
import os
print(os.path.realpath('.'))
PY
)
  resolved_target=$(cd "$REPO_ROOT" && python3 - <<'PY' "$rel_path"
import os, sys
print(os.path.realpath(sys.argv[1]))
PY
)
  case "$resolved_target" in
    "$resolved_root"/*) ;;
    *)
      echo "TAMPER DETECTED: direct verification input escaped repo boundary: $rel_path" >&2
      return 1
      ;;
  esac
  current=$(compute_digest "$rel_path") || {
    echo "TAMPER DETECTED: could not hash tracked verification input: $rel_path" >&2
    return 1
  }
  if [[ -z "$recorded" ]]; then
    printf 'MISSING\t%s\n' "$current"
    return 0
  fi
  if [[ "$recorded" != "$current" ]]; then
    echo "TAMPER DETECTED: tracked verification input changed: $rel_path" >&2
    return 1
  fi
  printf 'OK\t%s\n' "$current"
  return 0
}

if [[ -z "${1:-}" ]]; then
  echo "Usage: score verify <feature-id>" >&2
  exit 1
fi

FEATURE_ID="$1"

if [[ ! -f "$SCORE_JSON" ]]; then
  echo "ERROR: score.json not found" >&2
  exit 1
fi

FEATURE_NAME=$(jq -r --argjson id "$FEATURE_ID" '.features[] | select(.id == $id) | .name' "$SCORE_JSON")
if [[ -z "$FEATURE_NAME" ]]; then
  echo "ERROR: Feature #$FEATURE_ID not found in score.json" >&2
  exit 1
fi

GLOBAL_TEST_CMD=$(jq -r '.test_command // empty' "$SCORE_JSON")
FEATURE_TEST_CMD=$(jq -r --argjson id "$FEATURE_ID" '.features[] | select(.id == $id) | .test_script // empty' "$SCORE_JSON")
REQUIRE_GLOBAL_RAW=$(jq -r --argjson id "$FEATURE_ID" '.features[] | select(.id == $id) | (if has("require_global") and (.require_global | type) == "boolean" then .require_global else true end)' "$SCORE_JSON")
REQUIRE_GLOBAL="true"
if [[ "$REQUIRE_GLOBAL_RAW" == "false" ]]; then
  REQUIRE_GLOBAL="false"
fi
GLOBAL_REQUIRED=false
if [[ -z "$FEATURE_TEST_CMD" || "$REQUIRE_GLOBAL" == "true" ]]; then
  GLOBAL_REQUIRED=true
fi
GLOBAL_TEST_PATH=$(extract_command_path_token "$GLOBAL_TEST_CMD" || true)
FEATURE_TEST_PATH=$(extract_command_path_token "$FEATURE_TEST_CMD" || true)

if [[ -z "$GLOBAL_TEST_CMD" && -z "$FEATURE_TEST_CMD" ]]; then
  echo "ERROR: No test_command defined in score.json and no test_script for feature #$FEATURE_ID" >&2
  exit 1
fi

echo "=== Verifying Feature #$FEATURE_ID: $FEATURE_NAME ==="
echo ""

FEATURE_RESULT="skipped"
GLOBAL_RESULT="skipped"
TAMPER_RESULT="pass"
FEATURE_TRACK_STATUS=""
FEATURE_TRACK_DIGEST=""
GLOBAL_TRACK_STATUS=""
GLOBAL_TRACK_DIGEST=""

if [[ -n "$FEATURE_TEST_PATH" ]]; then
  TRACK_STATUS_CODE=0
  TRACK_OUTPUT=$(check_tracked_input "$FEATURE_TEST_PATH") || TRACK_STATUS_CODE=$?
  if [[ $TRACK_STATUS_CODE -eq 1 ]]; then
    TAMPER_RESULT="fail"
  elif [[ $TRACK_STATUS_CODE -eq 0 ]]; then
    FEATURE_TRACK_STATUS=${TRACK_OUTPUT%%$'\t'*}
    FEATURE_TRACK_DIGEST=${TRACK_OUTPUT#*$'\t'}
  fi
fi
if [[ "$TAMPER_RESULT" == "pass" && "$GLOBAL_REQUIRED" == "true" && -n "$GLOBAL_TEST_PATH" ]]; then
  TRACK_STATUS_CODE=0
  TRACK_OUTPUT=$(check_tracked_input "$GLOBAL_TEST_PATH") || TRACK_STATUS_CODE=$?
  if [[ $TRACK_STATUS_CODE -eq 1 ]]; then
    TAMPER_RESULT="fail"
  elif [[ $TRACK_STATUS_CODE -eq 0 ]]; then
    GLOBAL_TRACK_STATUS=${TRACK_OUTPUT%%$'\t'*}
    GLOBAL_TRACK_DIGEST=${TRACK_OUTPUT#*$'\t'}
  fi
fi

if [[ "$TAMPER_RESULT" == "pass" && -n "$FEATURE_TEST_CMD" ]]; then
  echo "Feature test: $FEATURE_TEST_CMD"
  if run_check "$FEATURE_TEST_CMD"; then
    FEATURE_RESULT="pass"
  else
    FEATURE_RESULT="fail"
  fi
fi

if [[ "$TAMPER_RESULT" == "pass" && "$GLOBAL_REQUIRED" == "true" && -n "$GLOBAL_TEST_CMD" ]]; then
  echo "Global test:  $GLOBAL_TEST_CMD"
  if run_check "$GLOBAL_TEST_CMD"; then
    GLOBAL_RESULT="pass"
  else
    GLOBAL_RESULT="fail"
  fi
fi

PASS=false
if [[ "$TAMPER_RESULT" == "pass" ]]; then
  if [[ -n "$FEATURE_TEST_CMD" ]]; then
    if [[ "$REQUIRE_GLOBAL" == "true" ]]; then
      [[ "$FEATURE_RESULT" == "pass" && "$GLOBAL_RESULT" == "pass" ]] && PASS=true
    else
      [[ "$FEATURE_RESULT" == "pass" ]] && PASS=true
    fi
  else
    [[ "$GLOBAL_RESULT" == "pass" ]] && PASS=true
  fi
fi

if [[ "$PASS" == "true" ]]; then
  if [[ "$FEATURE_TRACK_STATUS" == "MISSING" ]]; then
    set_recorded_digest "$FEATURE_TEST_PATH" "$FEATURE_TRACK_DIGEST"
  fi
  if [[ "$GLOBAL_TRACK_STATUS" == "MISSING" ]]; then
    set_recorded_digest "$GLOBAL_TEST_PATH" "$GLOBAL_TRACK_DIGEST"
  fi
fi

TMPFILE=$(mktemp)
jq --argjson id "$FEATURE_ID" --argjson pass "$PASS" \
  '(.features[] | select(.id == $id)).passes = $pass' \
  "$SCORE_JSON" > "$TMPFILE" && mv "$TMPFILE" "$SCORE_JSON"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo ""
echo "--- Result ---"
echo "Feature:       #$FEATURE_ID — $FEATURE_NAME"
echo "Feature test:  $FEATURE_RESULT"
echo "Global test:   $GLOBAL_RESULT"
echo "Tamper check:  $TAMPER_RESULT"
if [[ "$PASS" == "true" ]]; then
  echo "Final status:  PASS"
else
  echo "Final status:  FAIL"
fi
echo "Time:          $TIMESTAMP"

if [[ "$PASS" == "true" ]]; then
  exit 0
else
  exit 1
fi
