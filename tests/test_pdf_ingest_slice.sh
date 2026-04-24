#!/usr/bin/env bash
# tests/test_pdf_ingest_slice.sh
# Witness that bin/vault-ingest-pdf uses Microsoft markitdown to convert a
# PDF into markdown and deposits it into ops/raw/ via vault-refile-append,
# with PDF-aware provenance:
#   - source:        points to the ORIGINAL .pdf path (not the tmp .md)
#   - original_sha256: SHA of the ORIGINAL PDF bytes (not the markdown)
#   - original_format: "pdf"
#   - body:          markitdown-converted markdown text
#
# Must be SHA-idempotent on the PDF bytes, and must propagate through the
# existing compile pipeline so compiled notes carry the PDF's SHA (F12).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [ ! -x bin/vault-ingest-pdf ]; then
  echo "FAIL: bin/vault-ingest-pdf missing or not executable"
  exit 1
fi

if [ ! -f tests/fixtures/sample.pdf ]; then
  echo "FAIL: tests/fixtures/sample.pdf fixture missing"
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

VAULT="$TMP/vault"
mkdir -p "$VAULT/ops/raw"

SRC_PDF="$ROOT/tests/fixtures/sample.pdf"
PDF_SHA="$(shasum -a 256 "$SRC_PDF" | awk '{print $1}')"

# --- ingest ---
REFILED_BY=tester bin/vault-ingest-pdf "$SRC_PDF" "$VAULT" >/dev/null \
  || { echo "FAIL: bin/vault-ingest-pdf exited non-zero"; exit 1; }

RAW="$(find "$VAULT/ops/raw" -type f -name '*.md' | head -1)"
[ -n "$RAW" ] || { echo "FAIL: no file landed in ops/raw/"; exit 1; }

# provenance assertions on raw landing
grep -q "^source: $SRC_PDF$" "$RAW" \
  || { echo "FAIL: raw source: fm does not point to ORIGINAL pdf path"; grep '^source:' "$RAW"; exit 1; }
grep -q "^original_sha256: $PDF_SHA$" "$RAW" \
  || { echo "FAIL: raw original_sha256 != sha of ORIGINAL pdf bytes"; grep '^original_sha256:' "$RAW"; exit 1; }
grep -q '^original_format: pdf$' "$RAW" \
  || { echo "FAIL: raw missing 'original_format: pdf' fm key"; exit 1; }
grep -q 'pdftokenmarker' "$RAW" \
  || { echo "FAIL: raw body does not contain converted pdf text 'pdftokenmarker'"; exit 1; }

# raw filename should carry the pdf stem (human-readable)
case "$(basename "$RAW")" in
  sample*.md) : ;;
  *) echo "FAIL: landed filename does not preserve pdf stem: $(basename "$RAW")"; exit 1 ;;
esac

# --- SHA-idempotence: re-run must no-op ---
COUNT_BEFORE="$(find "$VAULT/ops/raw" -type f -name '*.md' | wc -l | tr -d ' ')"
OUT2="$(REFILED_BY=tester bin/vault-ingest-pdf "$SRC_PDF" "$VAULT" 2>&1 || true)"
COUNT_AFTER="$(find "$VAULT/ops/raw" -type f -name '*.md' | wc -l | tr -d ' ')"
test "$COUNT_BEFORE" = "$COUNT_AFTER" \
  || { echo "FAIL: 2nd ingest created a new raw file (not SHA-idempotent); before=$COUNT_BEFORE after=$COUNT_AFTER"; exit 1; }
echo "$OUT2" | grep -qi 'duplicate' \
  || { echo "FAIL: 2nd ingest did not announce duplicate/no-op. output: $OUT2"; exit 1; }

# --- no .tmp stragglers in raw ---
STRAG="$(find "$VAULT/ops/raw" -name '.refile.*' -o -name '.ingest.*' | wc -l | tr -d ' ')"
test "$STRAG" = "0" \
  || { echo "FAIL: tmp stragglers left in ops/raw/"; exit 1; }

# --- refuse missing pdf (fail-loud, exit 1) ---
set +e
bin/vault-ingest-pdf "$TMP/nope.pdf" "$VAULT" >/dev/null 2>&1
RC=$?
set -e
test "$RC" = "1" \
  || { echo "FAIL: missing-pdf should exit 1, got $RC"; exit 1; }

# --- misuse: bad argc ---
set +e
bin/vault-ingest-pdf >/dev/null 2>&1
RC=$?
set -e
test "$RC" = "2" \
  || { echo "FAIL: no-arg invocation should exit 2, got $RC"; exit 1; }

# --- propagation through compile (F12): compiled notes carry PDF's sha ---
bin/vault-compile-replay "$VAULT" >/dev/null \
  || { echo "FAIL: compile-replay failed on pdf-derived raw"; exit 1; }

MISSING=0
for n in "$VAULT/notes"/*.md; do
  grep -q "^original_sha256: $PDF_SHA$" "$n" \
    || { echo "FAIL: compiled note $(basename "$n") missing pdf original_sha256"; MISSING=1; }
done
test "$MISSING" = "0" || exit 1

echo "PASS: pdf ingest slice witness complete"
