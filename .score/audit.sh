#!/usr/bin/env bash
# score audit — re-verify all passed features match reality
set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo "Usage: score audit"
  echo "Re-verify all passed features match reality under the stronger verification contract."
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
PENDING_BASELINES=$(mktemp)
trap 'rm -f "$PENDING_BASELINES"' EXIT

run_check() {
  local cmd="$1"
  if [[ -z "$cmd" || "$cmd" == "null" ]]; then
    return 2
  fi
  if (cd "$REPO_ROOT" && eval "$cmd") > /dev/null 2>&1; then
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
  tmpfile=$(mktemp)
  if [[ -f "$BASELINE_FILE" ]]; then
    awk -F '\t' -v p="$rel_path" '$1 != p {print $1 "\t" $2}' "$BASELINE_FILE" > "$tmpfile"
  fi
  if [[ -s "$PENDING_BASELINES" ]]; then
    awk -F '\t' -v p="$rel_path" '$1 != p {print $1 "\t" $2}' "$PENDING_BASELINES" >> "$tmpfile"
  fi
  printf '%s\t%s\n' "$rel_path" "$digest" >> "$tmpfile"
  mv "$tmpfile" "$PENDING_BASELINES"
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

if [[ ! -f "$SCORE_JSON" ]]; then
  echo "ERROR: score.json not found" >&2
  exit 1
fi

GLOBAL_TEST_CMD=$(jq -r '.test_command // empty' "$SCORE_JSON")
ANY_GLOBAL_REQUIRED=false
if jq -e '.features[] | select(.passes == true) | select((.test_script // "") == "" or (if has("require_global") and (.require_global | type) == "boolean" then (.require_global != false) else true end))' "$SCORE_JSON" > /dev/null 2>&1; then
  ANY_GLOBAL_REQUIRED=true
fi
GLOBAL_TEST_PATH=$(extract_command_path_token "$GLOBAL_TEST_CMD" || true)

echo "=== Score Audit ==="
echo ""

PASSED_COUNT=$(jq '[.features[] | select(.passes == true)] | length' "$SCORE_JSON")
if [[ "$PASSED_COUNT" -eq 0 ]]; then
  echo "No features marked as passed. Nothing to audit."
  exit 0
fi

GLOBAL_RESULT="skipped"
GLOBAL_TAMPER_RESULT="pass"
GLOBAL_TRACK_STATUS=""
GLOBAL_TRACK_DIGEST=""
if [[ -n "$GLOBAL_TEST_PATH" && "$ANY_GLOBAL_REQUIRED" == "true" ]]; then
  TRACK_STATUS_CODE=0
  TRACK_OUTPUT=$(check_tracked_input "$GLOBAL_TEST_PATH") || TRACK_STATUS_CODE=$?
  if [[ $TRACK_STATUS_CODE -eq 1 ]]; then
    GLOBAL_TAMPER_RESULT="fail"
  elif [[ $TRACK_STATUS_CODE -eq 0 ]]; then
    GLOBAL_TRACK_STATUS=${TRACK_OUTPUT%%$'\t'*}
    GLOBAL_TRACK_DIGEST=${TRACK_OUTPUT#*$'\t'}
  fi
fi
if [[ "$GLOBAL_TAMPER_RESULT" == "pass" && "$ANY_GLOBAL_REQUIRED" == "true" && -n "$GLOBAL_TEST_CMD" ]]; then
  echo "--- Global Test Suite ---"
  if run_check "$GLOBAL_TEST_CMD"; then
    GLOBAL_RESULT="pass"
  else
    GLOBAL_RESULT="fail"
  fi
  echo "Global test result: $GLOBAL_RESULT"
  echo ""
fi
if [[ "$GLOBAL_RESULT" == "pass" && "$GLOBAL_TRACK_STATUS" == "MISSING" ]]; then
  set_recorded_digest "$GLOBAL_TEST_PATH" "$GLOBAL_TRACK_DIGEST"
fi

echo "--- Per-Feature Verification ---"
MISMATCHES=0
FEATURE_IDS=$(jq -r '.features[] | select(.passes == true) | .id' "$SCORE_JSON")

for FID in $FEATURE_IDS; do
  FNAME=$(jq -r --argjson id "$FID" '.features[] | select(.id == $id) | .name' "$SCORE_JSON")
  FSCRIPT=$(jq -r --argjson id "$FID" '.features[] | select(.id == $id) | .test_script // empty' "$SCORE_JSON")
  REQUIRE_GLOBAL_RAW=$(jq -r --argjson id "$FID" '.features[] | select(.id == $id) | (if has("require_global") and (.require_global | type) == "boolean" then .require_global else true end)' "$SCORE_JSON")
  REQUIRE_GLOBAL="true"
  if [[ "$REQUIRE_GLOBAL_RAW" == "false" ]]; then
    REQUIRE_GLOBAL="false"
  fi
  FEATURE_GLOBAL_REQUIRED=false
  if [[ -z "$FSCRIPT" || "$REQUIRE_GLOBAL" == "true" ]]; then
    FEATURE_GLOBAL_REQUIRED=true
  fi
  FSCRIPT_PATH=$(extract_command_path_token "$FSCRIPT" || true)

  FEATURE_RESULT="skipped"
  FEATURE_TAMPER_RESULT="pass"
  FEATURE_TRACK_STATUS=""
  FEATURE_TRACK_DIGEST=""
  if [[ -n "$FSCRIPT_PATH" ]]; then
    TRACK_STATUS_CODE=0
    TRACK_OUTPUT=$(check_tracked_input "$FSCRIPT_PATH") || TRACK_STATUS_CODE=$?
    if [[ $TRACK_STATUS_CODE -eq 1 ]]; then
      FEATURE_TAMPER_RESULT="fail"
    elif [[ $TRACK_STATUS_CODE -eq 0 ]]; then
      FEATURE_TRACK_STATUS=${TRACK_OUTPUT%%$'\t'*}
      FEATURE_TRACK_DIGEST=${TRACK_OUTPUT#*$'\t'}
    fi
  fi
  if [[ "$FEATURE_TAMPER_RESULT" == "pass" && -n "$FSCRIPT" ]]; then
    if run_check "$FSCRIPT"; then
      FEATURE_RESULT="pass"
    else
      FEATURE_RESULT="fail"
    fi
  fi
  if [[ "$FEATURE_RESULT" == "pass" && "$FEATURE_TRACK_STATUS" == "MISSING" ]]; then
    set_recorded_digest "$FSCRIPT_PATH" "$FEATURE_TRACK_DIGEST"
  fi

  FINAL_PASS=false
  if [[ "$FEATURE_TAMPER_RESULT" == "pass" ]]; then
    if [[ -n "$FSCRIPT" ]]; then
      if [[ "$FEATURE_GLOBAL_REQUIRED" == "true" ]]; then
        [[ "$FEATURE_RESULT" == "pass" && "$GLOBAL_TAMPER_RESULT" == "pass" && "$GLOBAL_RESULT" == "pass" ]] && FINAL_PASS=true
      else
        [[ "$FEATURE_RESULT" == "pass" ]] && FINAL_PASS=true
      fi
    else
      [[ "$GLOBAL_TAMPER_RESULT" == "pass" && "$GLOBAL_RESULT" == "pass" ]] && FINAL_PASS=true
    fi
  fi

  if [[ "$FINAL_PASS" == "true" ]]; then
    echo "  [PASS] #$FID: $FNAME | feature=$FEATURE_RESULT global=$GLOBAL_RESULT tamper=pass"
  else
    echo "  [FAIL] #$FID: $FNAME | feature=$FEATURE_RESULT global=$GLOBAL_RESULT tamper=global:$GLOBAL_TAMPER_RESULT,feature:$FEATURE_TAMPER_RESULT"
    MISMATCHES=$((MISMATCHES + 1))
  fi
done

echo ""
if [[ $MISMATCHES -eq 0 ]]; then
  if [[ -s "$PENDING_BASELINES" ]]; then
    mkdir -p "$STATE_DIR"
    touch "$BASELINE_FILE"
    while IFS=$'\t' read -r rel_path digest; do
      [[ -n "$rel_path" ]] || continue
      tmpfile=$(mktemp)
      if [[ -f "$BASELINE_FILE" ]]; then
        awk -F '\t' -v p="$rel_path" '$1 != p {print $1 "\t" $2}' "$BASELINE_FILE" > "$tmpfile"
      fi
      printf '%s\t%s\n' "$rel_path" "$digest" >> "$tmpfile"
      mv "$tmpfile" "$BASELINE_FILE"
    done < "$PENDING_BASELINES"
  fi
  echo "AUDIT PASS: All $PASSED_COUNT passed features verified."
  exit 0
else
  echo "AUDIT FAIL: $MISMATCHES of $PASSED_COUNT passed features have mismatches."
  echo "score.json may be out of sync with reality."
  exit 1
fi
