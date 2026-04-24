#!/usr/bin/env bash
# scripts/hermes-vault-cron.sh
#
# Single entrypoint for Hermes cron: drain the ~/Mind inbox (Option B) and
# ingest the latest Hermes session transcript (Option D). Emits a
# heartbeat row per run so you can audit what cron actually did.
#
# Idempotent by design:
#   - vault-inbox-drain is sha-idempotent at refile level
#   - vault-ingest-hermes-session has deterministic filenames and no
#     wall-clock fields in body, so re-ingest is a no-op
#
# Run manually:
#   ~/Projects/vault-tec/scripts/hermes-vault-cron.sh
#
# Or let Hermes cron invoke it on a schedule (see scripts/hermes-vault-cron.md).

set -euo pipefail

VAULT="${VAULT_TEC_VAULT:-$HOME/Mind}"
REPO="${VAULT_TEC_REPO:-$HOME/Projects/vault-tec}"
MARKITDOWN="${VAULT_TEC_MARKITDOWN:-}"
HB_DIR="$VAULT/ops/reports/cron"
HB_LOG="$HB_DIR/hermes-vault-cron.log"

[ -d "$VAULT" ] || { echo "hermes-vault-cron: vault not found: $VAULT" >&2; exit 2; }
[ -x "$REPO/bin/vault-inbox-drain" ] || { echo "hermes-vault-cron: missing drain in $REPO" >&2; exit 2; }
[ -x "$REPO/bin/vault-ingest-hermes-session" ] || { echo "hermes-vault-cron: missing session ingest in $REPO" >&2; exit 2; }

mkdir -p "$HB_DIR"

ts() { date -u +%Y-%m-%dT%H:%M:%SZ; }
log() { printf '%s\t%s\t%s\n' "$(ts)" "$1" "$2" >> "$HB_LOG"; }

log BEGIN "vault=$VAULT"

# 1) Session ingest: latest N hermes session files, capped so a cold box
#    doesn't dump thousands of transcripts at once.
SESSIONS_DIR="$HOME/.hermes/sessions"
SESSIONS_LIMIT="${VAULT_TEC_SESSIONS_PER_RUN:-5}"
INGESTED_SESSIONS=0

if [ -d "$SESSIONS_DIR" ]; then
  # Pick newest session files of both schemas; skip the registry.
  while IFS= read -r S; do
    [ -n "$S" ] || continue
    case "$(basename "$S")" in
      sessions.json) continue ;;
    esac
    OUT="$("$REPO/bin/vault-ingest-hermes-session" --mode=both "$S" "$VAULT" 2>/dev/null || true)"
    if [ -n "$OUT" ]; then
      INGESTED_SESSIONS=$((INGESTED_SESSIONS + 1))
      log INGEST "$(basename "$S")"
    else
      log INGEST_FAIL "$(basename "$S")"
    fi
  done < <(ls -t "$SESSIONS_DIR"/*.json "$SESSIONS_DIR"/*.jsonl 2>/dev/null \
             | grep -v '/sessions\.json$' \
             | head -n "$SESSIONS_LIMIT")
fi

# 2) Drain inbox → raw (fast). Compile is kicked off separately and
#    serialized via flock so it never overlaps with itself — on big vaults
#    compile can take minutes and we don't want cron cycles piling up.
DRAIN_RC=0
VAULT_TEC_MARKITDOWN="$MARKITDOWN" \
  "$REPO/bin/vault-inbox-drain" "$VAULT" >/dev/null 2>&1 || DRAIN_RC=$?
log DRAIN "rc=$DRAIN_RC"

COMPILE_LOCK="$HB_DIR/.compile.lockdir"
COMPILE_LAST="$HB_DIR/compile-last.log"
# Atomic lock via mkdir (POSIX, works without flock on macOS).
if mkdir "$COMPILE_LOCK" 2>/dev/null; then
  (
    echo $$ > "$COMPILE_LOCK/pid"
    log COMPILE "begin pid=$$"
    RC=0
    "$REPO/bin/vault-compile-replay" "$VAULT" >"$COMPILE_LAST" 2>&1 || RC=$?
    log COMPILE "done rc=$RC"
    rm -rf "$COMPILE_LOCK" 2>/dev/null || true
  ) &
  disown 2>/dev/null || true
else
  # Stale lock detection: if PID inside is gone, drop it so next cycle recovers.
  LPID="$(cat "$COMPILE_LOCK/pid" 2>/dev/null || echo 0)"
  if [ "$LPID" -gt 0 ] && ! kill -0 "$LPID" 2>/dev/null; then
    log COMPILE "stale-lock-cleared pid=$LPID"
    rm -rf "$COMPILE_LOCK" 2>/dev/null || true
  else
    log COMPILE "skipped (lock held pid=$LPID)"
  fi
fi

# 3) Summary row that a human can glance at.
RAW_COUNT=$(find "$VAULT/ops/raw" -maxdepth 2 -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
NOTES_COUNT=$(find "$VAULT/notes" -maxdepth 2 -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
log SUMMARY "sessions_ingested=$INGESTED_SESSIONS drain_rc=$DRAIN_RC raw_total=$RAW_COUNT notes_total=$NOTES_COUNT"

log END "ok"
exit 0
