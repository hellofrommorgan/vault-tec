#!/usr/bin/env bash
# score run — autonomous iteration loop with logs, stop reasons, and escalation
set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo "Usage: score run [max-iterations]"
  echo "Autonomous iteration loop with autopilot command hook, iteration logs, and explicit stop reasons."
  exit 0
fi

REPO_ROOT="${SCORE_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
SCORE_JSON="$REPO_ROOT/score.json"
MAX_ITERATIONS="${1:-10}"

if [[ ! -f "$SCORE_JSON" ]]; then
  echo "ERROR: score.json not found" >&2
  exit 1
fi

RUNS_DIR="$REPO_ROOT/.score/runs"
RUN_ID=$(date -u +"%Y%m%dT%H%M%SZ")
LOG_FILE="$RUNS_DIR/$RUN_ID.jsonl"
ATTEMPTS_FILE="$RUNS_DIR/$RUN_ID.attempts.tsv"
AGENT_CMD="${SCORE_AGENT_CMD:-$(jq -r '.run_command // empty' "$SCORE_JSON" 2>/dev/null || true)}"

mkdir -p "$RUNS_DIR"
: > "$ATTEMPTS_FILE"

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

next_ready_feature() {
  local feature_id feature_name feature_priority
  while IFS= read -r feature_id; do
    [[ -n "$feature_id" ]] || continue
    if feature_is_ready "$feature_id"; then
      feature_name=$(jq -r --argjson id "$feature_id" '.features[] | select(.id == $id) | .name' "$SCORE_JSON")
      feature_priority=$(jq -r --argjson id "$feature_id" '.features[] | select(.id == $id) | .priority' "$SCORE_JSON")
      printf '%s|%s|%s
' "$feature_id" "$feature_name" "$feature_priority"
      return 0
    fi
  done < <(jq -r '.features | sort_by(.priority)[] | select(.passes == false) | .id' "$SCORE_JSON")
  return 1
}

get_attempt_count() {
  local feature_id="$1"
  if [[ ! -f "$ATTEMPTS_FILE" ]]; then
    echo 0
    return 0
  fi
  awk -F '	' -v fid="$feature_id" '$1 == fid {print $2; found=1; exit} END {if (!found) print 0}' "$ATTEMPTS_FILE"
}

set_attempt_count() {
  local feature_id="$1"
  local count="$2"
  local tmpfile
  tmpfile=$(mktemp)
  if [[ -f "$ATTEMPTS_FILE" ]]; then
    awk -F '	' -v fid="$feature_id" '$1 != fid {print $1 "	" $2}' "$ATTEMPTS_FILE" > "$tmpfile"
  fi
  printf '%s	%s
' "$feature_id" "$count" >> "$tmpfile"
  mv "$tmpfile" "$ATTEMPTS_FILE"
}

stop_with_reason() {
  local reason="$1"
  local code="$2"
  echo ""
  echo "Stop reason: $reason"
  echo "Log file: $LOG_FILE"
  exit "$code"
}

log_iteration() {
  local iteration="$1"
  local feature_id="$2"
  local feature_name="$3"
  local pre_verify="$4"
  local agent_exit="$5"
  local post_verify="$6"
  local attempts="$7"
  local stop_reason="$8"
  jq -cn     --arg run_id "$RUN_ID"     --argjson iteration "$iteration"     --argjson feature_id "$feature_id"     --arg feature_name "$feature_name"     --arg pre_verify "$pre_verify"     --arg agent_exit_code "$agent_exit"     --arg post_verify "$post_verify"     --argjson attempt_count "$attempts"     --arg stop_reason "$stop_reason"     --arg timestamp "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"     '{run_id:$run_id, iteration:$iteration, attempted_feature_id:$feature_id, attempted_feature_name:$feature_name, pre_verify_result:$pre_verify, agent_exit_code:$agent_exit_code, post_verify_result:$post_verify, attempt_count_for_feature:$attempt_count, stop_reason:(if $stop_reason == "" then null else $stop_reason end), timestamp:$timestamp}' >> "$LOG_FILE"
}

echo "=== Score Run ==="
echo "Max iterations: $MAX_ITERATIONS"
echo "Run id: $RUN_ID"
echo "Log file: $LOG_FILE"
echo ""

ITERATION=0
while [[ $ITERATION -lt $MAX_ITERATIONS ]]; do
  ITERATION=$((ITERATION + 1))

  NEXT_FEATURE="$(next_ready_feature || true)"
  if [[ -z "$NEXT_FEATURE" ]]; then
    TOTAL=$(jq '.features | length' "$SCORE_JSON")
    PASSED=$(jq '[.features[] | select(.passes == true)] | length' "$SCORE_JSON")
    REMAINING=$((TOTAL - PASSED))
    if [[ "$REMAINING" -eq 0 ]]; then
      log_iteration "$ITERATION" 0 "none" "pass" "skipped" "pass" 0 "all_features_passing"
      stop_with_reason "all_features_passing" 0
    fi
    log_iteration "$ITERATION" 0 "none" "skipped" "skipped" "skipped" 0 "blocked"
    stop_with_reason "blocked" 3
  fi

  FEATURE_ID=$(echo "$NEXT_FEATURE" | cut -d'|' -f1)
  FEATURE_NAME=$(echo "$NEXT_FEATURE" | cut -d'|' -f2)
  FEATURE_PRIORITY=$(echo "$NEXT_FEATURE" | cut -d'|' -f3)

  echo "--- Iteration $ITERATION/$MAX_ITERATIONS ---"
  echo "Target: Feature #$FEATURE_ID (p$FEATURE_PRIORITY): $FEATURE_NAME"
  echo ""

  PRE_VERIFY="fail"
  if "$REPO_ROOT/.score/score" verify "$FEATURE_ID" > /tmp/score-pre-verify.log 2>&1; then
    PRE_VERIFY="pass"
    set_attempt_count "$FEATURE_ID" 0
    log_iteration "$ITERATION" "$FEATURE_ID" "$FEATURE_NAME" "$PRE_VERIFY" "skipped" "pass" 0 ""
    echo "Feature #$FEATURE_ID already passes. Moving to next."
    echo ""
    continue
  fi

  if [[ -z "$AGENT_CMD" ]]; then
    attempts=$(( $(get_attempt_count "$FEATURE_ID") + 1 ))
    set_attempt_count "$FEATURE_ID" "$attempts"
    log_iteration "$ITERATION" "$FEATURE_ID" "$FEATURE_NAME" "$PRE_VERIFY" "missing" "fail" "$attempts" "missing_agent_command"
    stop_with_reason "missing_agent_command" 4
  fi

  echo "Verification criteria:"
  jq -r --argjson id "$FEATURE_ID" '.features[] | select(.id == $id) | .verification[] | "  - \(.)"' "$SCORE_JSON"
  echo ""

  AGENT_EXIT=0
  SCORE_FEATURE_ID="$FEATURE_ID" SCORE_FEATURE_NAME="$FEATURE_NAME" SCORE_RUN_ID="$RUN_ID" SCORE_REPO_ROOT="$REPO_ROOT" bash -lc "$AGENT_CMD" || AGENT_EXIT=$?

  POST_VERIFY="fail"
  if "$REPO_ROOT/.score/score" verify "$FEATURE_ID" > /tmp/score-post-verify.log 2>&1; then
    POST_VERIFY="pass"
    set_attempt_count "$FEATURE_ID" 0
    log_iteration "$ITERATION" "$FEATURE_ID" "$FEATURE_NAME" "$PRE_VERIFY" "$AGENT_EXIT" "$POST_VERIFY" 0 ""
    if [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
      REMAINING=$(jq '[.features[] | select(.passes == false)] | length' "$SCORE_JSON")
      if [[ "$REMAINING" -eq 0 ]]; then
        log_iteration "$ITERATION" 0 "none" "pass" "skipped" "pass" 0 "all_features_passing"
        stop_with_reason "all_features_passing" 0
      fi
    fi
    continue
  fi

  attempts=$(( $(get_attempt_count "$FEATURE_ID") + 1 ))
  set_attempt_count "$FEATURE_ID" "$attempts"
  log_iteration "$ITERATION" "$FEATURE_ID" "$FEATURE_NAME" "$PRE_VERIFY" "$AGENT_EXIT" "$POST_VERIFY" "$attempts" ""
  if [[ $attempts -ge 3 ]]; then
    log_iteration "$ITERATION" "$FEATURE_ID" "$FEATURE_NAME" "$PRE_VERIFY" "$AGENT_EXIT" "$POST_VERIFY" "$attempts" "escalation_after_3_failures"
    stop_with_reason "escalation_after_3_failures" 5
  fi
done

log_iteration "$ITERATION" 0 "none" "skipped" "skipped" "skipped" 0 "iteration_cap"
stop_with_reason "iteration_cap" 1
