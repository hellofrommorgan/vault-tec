#!/usr/bin/env bash
# tests/test_refile_slice.sh
# Runtime witness for the NORTH STAR "refiled" step.
#
# Proves bin/vault-refile-append:
#   - deposits external md into ops/raw/ with required provenance frontmatter
#   - computes original_sha256 from ORIGINAL source bytes (not post-injection)
#   - is SHA-idempotent (rerun on same source → no new file, exit 0)
#   - hard-refuses sources under <vault>/ops/out/ (no self-fueling loop)
#   - never writes to notes/ (leave compile to bin/vault-compile-replay)
#   - atomically writes (no partial files; we check absence of .tmp)
#   - emits ops/reports/refile-report.md with the landing entry

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

VAULT="$TMP/vault"
mkdir -p "$VAULT/ops/raw" "$VAULT/ops/out" "$VAULT/notes"

SRC="$TMP/external-insight.md"
cat > "$SRC" <<'EOF'
# External Insight

Captured outside the vault from a meeting transcript.
Contains token zxqrefile99token.
EOF

SHA="$(shasum -a 256 "$SRC" | awk '{print $1}')"

# --- contract: primitive exists ---
test -x bin/vault-refile-append \
  || { echo "FAIL: bin/vault-refile-append missing or not executable"; exit 1; }

RAW_BEFORE="$(find "$VAULT/ops/raw" -type f | wc -l | tr -d ' ')"

# --- first refile ---
REFILED_BY=tester bin/vault-refile-append "$SRC" "$VAULT" >/dev/null \
  || { echo "FAIL: refile exited non-zero on valid source"; exit 1; }

RAW_AFTER="$(find "$VAULT/ops/raw" -type f | wc -l | tr -d ' ')"
test "$RAW_AFTER" -eq "$((RAW_BEFORE + 1))" \
  || { echo "FAIL: expected exactly one new file in ops/raw (before=$RAW_BEFORE after=$RAW_AFTER)"; exit 1; }

LANDED="$(find "$VAULT/ops/raw" -type f | head -1)"

# --- provenance frontmatter checks ---
head -n 1 "$LANDED" | grep -qE '^---$' \
  || { echo "FAIL: landed file missing frontmatter start"; head -n 5 "$LANDED" | sed 's/^/    /'; exit 1; }

grep -q "^source: $SRC$" "$LANDED" \
  || { echo "FAIL: landed file missing 'source: $SRC'"; grep '^source' "$LANDED" | sed 's/^/    /'; exit 1; }

grep -qE '^refiled_at: [0-9]{4}-[0-9]{2}-[0-9]{2}T' "$LANDED" \
  || { echo "FAIL: landed file missing ISO refiled_at"; grep '^refiled_at' "$LANDED" | sed 's/^/    /'; exit 1; }

grep -q "^refiled_by: tester$" "$LANDED" \
  || { echo "FAIL: landed file missing 'refiled_by: tester' (env propagation)"; exit 1; }

grep -q "^original_sha256: $SHA$" "$LANDED" \
  || { echo "FAIL: original_sha256 does not match source SHA"; grep '^original_sha256' "$LANDED" | sed 's/^/    /'; echo "    expected: $SHA"; exit 1; }

# body must be preserved (original content intact beneath frontmatter)
grep -q '^# External Insight$' "$LANDED" \
  || { echo "FAIL: body H1 missing from landed file"; exit 1; }
grep -q 'zxqrefile99token' "$LANDED" \
  || { echo "FAIL: body content missing from landed file"; exit 1; }

# atomic: no .tmp stragglers
if find "$VAULT/ops/raw" -name '*.tmp' | grep -q .; then
  echo "FAIL: .tmp stragglers left in ops/raw (non-atomic write)"
  exit 1
fi

# --- anti-cheat: notes/ must be untouched ---
NOTES_AFTER="$(find "$VAULT/notes" -type f | wc -l | tr -d ' ')"
test "$NOTES_AFTER" = "0" \
  || { echo "FAIL: refile touched notes/ (must leave compile to replayer)"; exit 1; }

# --- idempotence: rerun same source, no new raw file ---
REFILED_BY=tester bin/vault-refile-append "$SRC" "$VAULT" >/dev/null \
  || { echo "FAIL: refile idempotent rerun exited non-zero"; exit 1; }

RAW_AFTER_DUP="$(find "$VAULT/ops/raw" -type f | wc -l | tr -d ' ')"
test "$RAW_AFTER_DUP" -eq "$RAW_AFTER" \
  || { echo "FAIL: idempotent rerun created $((RAW_AFTER_DUP - RAW_AFTER)) extra file(s)"; exit 1; }

# --- anti-cheat: ops/out/ source must be REFUSED ---
cp "$SRC" "$VAULT/ops/out/trap.rendered.md"
set +e
bin/vault-refile-append "$VAULT/ops/out/trap.rendered.md" "$VAULT" >/dev/null 2>"$TMP/.refile.err"
RC=$?
set -e
if [ "$RC" = "0" ]; then
  echo "FAIL: refile accepted ops/out/ source (self-fueling render→raw loop)"
  exit 1
fi
if [ ! -s "$TMP/.refile.err" ]; then
  echo "FAIL: refile silent on ops/out/ rejection (P10 fail-loud)"
  exit 1
fi

# --- refile-report must exist and list the landing ---
REPORT="$VAULT/ops/reports/refile-report.md"
test -f "$REPORT" \
  || { echo "FAIL: ops/reports/refile-report.md not emitted"; exit 1; }
grep -q "$SHA" "$REPORT" \
  || { echo "FAIL: refile-report.md missing original_sha256 entry"; exit 1; }

# --- misuse: no args → exit 2 ---
set +e
bin/vault-refile-append >/dev/null 2>/dev/null
RC_MIS=$?
set -e
test "$RC_MIS" = "2" \
  || { echo "FAIL: expected exit 2 on misuse, got $RC_MIS"; exit 1; }

echo "PASS: refile slice witness complete"
