#!/usr/bin/env bash
# tests/test_hermes_session_digest.sh
# F17 runtime witness: Option D+ digest mode for bin/vault-ingest-hermes-session
#
# Contract:
#   - default invocation (no flag) writes ONLY the raw transcript — no digest
#   - --mode=digest writes exactly the digest file, not the raw transcript
#   - --mode=both writes both files, distinct deterministic filenames
#   - digest is sha-idempotent (re-run = byte-identical)
#   - digest body contains: role_counts, tools_used, first_user_message,
#     final_assistant_message, approx_char_count
#   - digest body contains NO wall-clock / timestamp field
#   - after drain, digest lands in ops/raw/ with provenance; re-drain → no dupes

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

test -x bin/vault-ingest-hermes-session \
  || { echo "FAIL: bin/vault-ingest-hermes-session missing"; exit 1; }
test -x bin/vault-inbox-drain \
  || { echo "FAIL: bin/vault-inbox-drain missing"; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/ops/inbox"

RARE="zdigesttokqq77"
cat > "$TMP/session_dig.json" <<EOF
{
  "session_id": "digest-sess-01",
  "model": "test/model",
  "session_start": "2026-04-24T00:00:00Z",
  "messages": [
    {"role": "user", "content": "first user ask about $RARE please"},
    {"role": "assistant", "content": "ok I will call tools",
     "tool_calls": [{"function": {"name": "search_files"}}, {"function": {"name": "read_file"}}]},
    {"role": "tool", "name": "search_files", "content": "tool result"},
    {"role": "assistant", "content": [{"type":"text","text":"final answer about $RARE"}]}
  ]
}
EOF

# 1. default invocation: only raw, no digest
OUT_DEFAULT=$(bin/vault-ingest-hermes-session "$TMP/session_dig.json" "$TMP")
[ -f "$OUT_DEFAULT" ] || { echo "FAIL: default ingest produced no file"; exit 1; }
case "$(basename "$OUT_DEFAULT")" in
  session-digest-*) echo "FAIL: default mode wrote digest filename"; exit 1 ;;
esac
# no digest file should exist
if ls "$TMP/ops/inbox"/session-digest-* >/dev/null 2>&1; then
  echo "FAIL: default mode emitted a digest file"; exit 1
fi

# clean inbox for isolated digest run
rm -f "$TMP/ops/inbox"/*.md

# 2. --mode=digest: only digest
OUT_DIG=$(bin/vault-ingest-hermes-session --mode=digest "$TMP/session_dig.json" "$TMP")
[ -f "$OUT_DIG" ] || { echo "FAIL: digest mode produced no file"; exit 1; }
case "$(basename "$OUT_DIG")" in
  session-digest-session_dig-json.md) : ;;
  *) echo "FAIL: unexpected digest filename: $(basename "$OUT_DIG")"; exit 1 ;;
esac
# no raw file
if ls "$TMP/ops/inbox"/session-session_dig-*.md >/dev/null 2>&1; then
  echo "FAIL: digest mode also wrote raw transcript"; exit 1
fi

# body assertions
grep -q "## role_counts"            "$OUT_DIG" || { echo "FAIL: digest missing role_counts"; exit 1; }
grep -q "^- user: "                 "$OUT_DIG" || { echo "FAIL: digest missing user role count"; exit 1; }
grep -q "^- assistant: "            "$OUT_DIG" || { echo "FAIL: digest missing assistant role count"; exit 1; }
grep -q "## tools_used"             "$OUT_DIG" || { echo "FAIL: digest missing tools_used"; exit 1; }
grep -q "search_files"              "$OUT_DIG" || { echo "FAIL: digest missing extracted tool name"; exit 1; }
grep -q "read_file"                 "$OUT_DIG" || { echo "FAIL: digest missing second tool name"; exit 1; }
grep -q "## first_user_message"     "$OUT_DIG" || { echo "FAIL: digest missing first_user_message"; exit 1; }
grep -q "## final_assistant_message" "$OUT_DIG" || { echo "FAIL: digest missing final_assistant_message"; exit 1; }
grep -q "approx_char_count"         "$OUT_DIG" || { echo "FAIL: digest missing approx_char_count"; exit 1; }
grep -q "$RARE"                     "$OUT_DIG" || { echo "FAIL: digest missing rare token (first user excerpt)"; exit 1; }
grep -q "final answer about $RARE"  "$OUT_DIG" || { echo "FAIL: digest missing final_assistant excerpt"; exit 1; }

# NO wall-clock fields (UTC ISO timestamps of form YYYY-MM-DDTHH:MM:SSZ
# are allowed ONLY if they came from the input session_start). The ingested_at
# / digested_at / rendered_at style fields must NEVER appear.
if grep -qE "^- (ingested_at|digested_at|rendered_at|emitted_at):" "$OUT_DIG"; then
  echo "FAIL: digest contains wall-clock timestamp field"; exit 1
fi

# 3. sha-idempotent: re-running produces byte-identical output
SHA1=$(shasum "$OUT_DIG" | awk '{print $1}')
OUT_DIG2=$(bin/vault-ingest-hermes-session --mode=digest "$TMP/session_dig.json" "$TMP")
[ "$OUT_DIG" = "$OUT_DIG2" ] || { echo "FAIL: digest filename not deterministic"; exit 1; }
SHA2=$(shasum "$OUT_DIG2" | awk '{print $1}')
[ "$SHA1" = "$SHA2" ] || { echo "FAIL: digest bytes differ across runs (sha $SHA1 vs $SHA2)"; exit 1; }

# 4. --mode=both: both files present
rm -f "$TMP/ops/inbox"/*.md
OUT_BOTH=$(bin/vault-ingest-hermes-session --mode=both "$TMP/session_dig.json" "$TMP")
# mode=both prints both paths (raw then digest)
RAW_BOTH=$(echo "$OUT_BOTH" | head -1)
DIG_BOTH=$(echo "$OUT_BOTH" | tail -1)
[ -f "$RAW_BOTH" ] || { echo "FAIL: both-mode raw file missing: $RAW_BOTH"; exit 1; }
[ -f "$DIG_BOTH" ] || { echo "FAIL: both-mode digest file missing: $DIG_BOTH"; exit 1; }
case "$(basename "$RAW_BOTH")" in session-digest-*) echo "FAIL: both printed raw second"; exit 1 ;; esac
case "$(basename "$DIG_BOTH")" in session-digest-*) : ;; *) echo "FAIL: both missing digest"; exit 1 ;; esac

# 5. drain promotes digest into ops/raw/ with provenance, re-drain no dupes
VAULT_TEC_MARKITDOWN="${VAULT_TEC_MARKITDOWN:-}" \
  bin/vault-inbox-drain "$TMP" >/dev/null 2>&1 || true

RAW_DIG=$(grep -rl "Hermes Session Digest" "$TMP/ops/raw" 2>/dev/null | head -1 || true)
[ -n "$RAW_DIG" ] || { echo "FAIL: digest did not land in ops/raw/ after drain"; exit 1; }
grep -q "original_sha256:" "$RAW_DIG" || { echo "FAIL: digest raw drop missing provenance"; exit 1; }

BEFORE=$(find "$TMP/ops/raw" -name '*.md' | wc -l | tr -d ' ')
bin/vault-ingest-hermes-session --mode=both "$TMP/session_dig.json" "$TMP" >/dev/null
VAULT_TEC_MARKITDOWN="${VAULT_TEC_MARKITDOWN:-}" \
  bin/vault-inbox-drain "$TMP" >/dev/null 2>&1 || true
AFTER=$(find "$TMP/ops/raw" -name '*.md' | wc -l | tr -d ' ')
[ "$BEFORE" = "$AFTER" ] || { echo "FAIL: re-ingest produced duplicate raw entries ($BEFORE → $AFTER)"; exit 1; }

echo "PASS: hermes session digest (default/digest/both) sha-idempotent; no wall-clock; drain-safe"
