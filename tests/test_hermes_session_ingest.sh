#!/usr/bin/env bash
# tests/test_hermes_session_ingest.sh
# Option D runtime witness: bin/vault-ingest-hermes-session
#
# Contract:
#   - accepts .json (messages[] schema) and .jsonl sessions
#   - emits exactly one file into <vault>/ops/inbox/ with a DETERMINISTIC
#     filename (so re-running is idempotent at the fs level)
#   - preserves raw role + content text (no lossy summarization)
#   - after the drain runs, the emitted inbox file flows through
#     refile → raw/ with canonical provenance frontmatter (original_sha256
#     pointing at the emitted inbox bytes)
#   - NEVER writes to notes/, raw/, or out/ directly

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

test -x bin/vault-ingest-hermes-session \
  || { echo "FAIL: bin/vault-ingest-hermes-session missing or not executable"; exit 1; }
test -x bin/vault-inbox-drain \
  || { echo "FAIL: bin/vault-inbox-drain missing or not executable"; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/ops/inbox"

# --- fabricate a JSON session (mirrors ~/.hermes/sessions/*.json schema) ---
RARE_TOK_A="zxsesstokena11"
cat > "$TMP/session_fake.json" <<EOF
{
  "session_id": "fake-session-01",
  "model": "test/model",
  "platform": "cli",
  "session_start": "2026-04-24T00:00:00Z",
  "last_updated": "2026-04-24T00:01:00Z",
  "messages": [
    {"role": "user", "content": "hello vault — $RARE_TOK_A"},
    {"role": "assistant", "content": [{"type":"text","text":"structured reply body"}]},
    {"role": "tool",      "content": "tool output payload"}
  ]
}
EOF

# --- fabricate a JSONL session (older schema) ---
RARE_TOK_B="zxsesstokenb22"
cat > "$TMP/session_fake.jsonl" <<EOF
{"type":"session_start","session_id":"fake-jsonl-02","model":"test/model","session_start":"2026-04-24T00:00:00Z"}
{"role":"user","content":"jsonl prompt containing $RARE_TOK_B"}
{"role":"assistant","content":"jsonl reply"}
EOF

# --- ingest both ---
OUT_A=$(bin/vault-ingest-hermes-session "$TMP/session_fake.json" "$TMP")
OUT_B=$(bin/vault-ingest-hermes-session "$TMP/session_fake.jsonl" "$TMP")

for OUT in "$OUT_A" "$OUT_B"; do
  [ -f "$OUT" ] || { echo "FAIL: ingest did not produce $OUT"; exit 1; }
done

# deterministic filenames (re-run produces same name, not -2.md)
OUT_A2=$(bin/vault-ingest-hermes-session "$TMP/session_fake.json" "$TMP")
[ "$OUT_A" = "$OUT_A2" ] || { echo "FAIL: ingest filename not deterministic: $OUT_A vs $OUT_A2"; exit 1; }

# raw content preserved — rare tokens must be present in the inbox drop
grep -q "$RARE_TOK_A" "$OUT_A" || { echo "FAIL: JSON session token missing in $OUT_A"; exit 1; }
grep -q "$RARE_TOK_B" "$OUT_B" || { echo "FAIL: JSONL session token missing in $OUT_B"; exit 1; }

# role delimiters present
grep -q "^### 1. user" "$OUT_A" || { echo "FAIL: JSON session missing role-delimited transcript"; exit 1; }
grep -q "^### 1. user" "$OUT_B" || { echo "FAIL: JSONL session missing role-delimited transcript"; exit 1; }

# session metadata preserved in the body
grep -q "session_id:" "$OUT_A" || { echo "FAIL: JSON session missing session_id header"; exit 1; }

# ingest wrote into ops/inbox/ only (not raw/, not notes/, not out/)
if [ -d "$TMP/ops/raw" ] && find "$TMP/ops/raw" -type f | grep -q .; then
  echo "FAIL: ingest wrote into ops/raw/ directly"; exit 1
fi
if [ -d "$TMP/notes" ] && find "$TMP/notes" -type f | grep -q .; then
  echo "FAIL: ingest wrote into notes/ directly"; exit 1
fi

# --- now run the drain over those inbox drops ---
VAULT_TEC_MARKITDOWN="${VAULT_TEC_MARKITDOWN:-}" \
  bin/vault-inbox-drain "$TMP" --compile >/dev/null 2>&1 || true

# raw/ must now contain both session drops, with provenance frontmatter
RAW_JSON=$(grep -rl "$RARE_TOK_A" "$TMP/ops/raw" 2>/dev/null | head -1 || true)
RAW_JSONL=$(grep -rl "$RARE_TOK_B" "$TMP/ops/raw" 2>/dev/null | head -1 || true)
[ -n "$RAW_JSON" ]  || { echo "FAIL: JSON session did not land in raw/ after drain"; exit 1; }
[ -n "$RAW_JSONL" ] || { echo "FAIL: JSONL session did not land in raw/ after drain"; exit 1; }

grep -q "original_sha256:" "$RAW_JSON"  || { echo "FAIL: raw drop missing provenance frontmatter (json)"; exit 1; }
grep -q "original_sha256:" "$RAW_JSONL" || { echo "FAIL: raw drop missing provenance frontmatter (jsonl)"; exit 1; }

# sha-idempotence: re-running ingest + drain should not create a second raw entry
BEFORE=$(find "$TMP/ops/raw" -name '*.md' | wc -l | tr -d ' ')
bin/vault-ingest-hermes-session "$TMP/session_fake.json" "$TMP" >/dev/null
VAULT_TEC_MARKITDOWN="${VAULT_TEC_MARKITDOWN:-}" \
  bin/vault-inbox-drain "$TMP" >/dev/null 2>&1 || true
AFTER=$(find "$TMP/ops/raw" -name '*.md' | wc -l | tr -d ' ')
[ "$BEFORE" = "$AFTER" ] || { echo "FAIL: re-ingest of identical session produced duplicate raw entry ($BEFORE → $AFTER)"; exit 1; }

echo "PASS: hermes session ingest (json + jsonl) → inbox → raw green; sha-idempotent"
