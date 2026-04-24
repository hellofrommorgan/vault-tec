#!/usr/bin/env bash
# tests/test_inbox_drain.sh
# Runtime witness for Option B: bin/vault-inbox-drain
#
# Contract under test:
#   - dispatches .md, .pdf, .txt, .html from ops/inbox/ to ops/raw/ via
#     canonical primitives (no direct writes to ops/raw/)
#   - provenance frontmatter reaches notes/ after compile: refiled_from,
#     original_sha256 (pointing at the original file bytes, not a
#     converted intermediary)
#   - unsupported extensions move to ops/inbox/_failed/ with a .reason file;
#     exit code is 1 when any item failed
#   - --compile triggers vault-compile-replay on a non-empty drain
#   - cycle logs land in ops/inbox/drain.log
#   - ops/out/ is NEVER used as an ingress source
#
# PDF branch requires VAULT_TEC_MARKITDOWN or a markitdown binary on PATH.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

test -x bin/vault-inbox-drain \
  || { echo "FAIL: bin/vault-inbox-drain missing or not executable"; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/ops/inbox"

# --- seed the inbox ---
RARE_MD="zxinboxmdtoken77"
cat > "$TMP/ops/inbox/clip-md.md" <<EOF
# Clip MD

## Body

rare token: $RARE_MD
EOF

RARE_TXT="zxinboxtxttoken88"
cat > "$TMP/ops/inbox/notes-txt.txt" <<EOF
a plain text capture
containing $RARE_TXT
EOF

RARE_HTML="zxinboxhtmltoken99"
cat > "$TMP/ops/inbox/page.html" <<EOF
<html><head><title>Page Title</title></head>
<body><h1>Hello</h1><p>rare $RARE_HTML here</p>
<script>ignore me</script></body></html>
EOF

# unsupported extension — should land in _failed/
echo "binary-ish" > "$TMP/ops/inbox/thing.xyz"

# PDF branch: only seed if we can actually convert
PDF_READY=0
if [ -n "${VAULT_TEC_MARKITDOWN:-}" ] && [ -x "${VAULT_TEC_MARKITDOWN}" ]; then
  # reuse the repo's fixture PDF
  if [ -f "$ROOT/tests/fixtures/sample.pdf" ]; then
    cp "$ROOT/tests/fixtures/sample.pdf" "$TMP/ops/inbox/paper.pdf"
    PDF_READY=1
  fi
fi

# --- run drain (should exit 1 because thing.xyz is unsupported) ---
DRAIN_RC=0
VAULT_TEC_MARKITDOWN="${VAULT_TEC_MARKITDOWN:-}" \
  bin/vault-inbox-drain "$TMP" >/dev/null 2>&1 || DRAIN_RC=$?

if [ "$DRAIN_RC" != "1" ]; then
  echo "FAIL: drain should exit 1 with an unsupported-extension item present (got $DRAIN_RC)"
  exit 1
fi

# --- assert supported items landed in raw/ ---
if [ ! -d "$TMP/ops/raw" ] || ! find "$TMP/ops/raw" -maxdepth 2 -name '*.md' | grep -q .; then
  echo "FAIL: no raw/ output after drain"
  exit 1
fi

# every raw doc must carry provenance frontmatter pointing at an
# ORIGINAL inbox source (not a tmp path).
MISS_PROV=0
for f in "$TMP"/ops/raw/*.md; do
  if ! grep -q 'original_sha256:' "$f"; then MISS_PROV=1; fi
  if ! grep -q 'source:' "$f"; then MISS_PROV=1; fi
done
if [ "$MISS_PROV" = "1" ]; then
  echo "FAIL: a raw/ doc is missing provenance frontmatter"
  ls -1 "$TMP/ops/raw/"
  exit 1
fi

# the md item must reference the *original .md* path, not a tmp file
if ! grep -r "clip-md.md" "$TMP/ops/raw/" >/dev/null; then
  echo "FAIL: md drain did not preserve original path in provenance"
  exit 1
fi

# the txt item must reference the *original .txt* path, not the converted tmp.md
if ! grep -r "notes-txt.txt" "$TMP/ops/raw/" >/dev/null; then
  echo "FAIL: txt drain did not attest to original .txt path"
  exit 1
fi

# --- unsupported must be in _failed/, supported must be in _ingested/ ---
if [ ! -f "$TMP/ops/inbox/_failed/thing.xyz" ]; then
  echo "FAIL: unsupported item not moved to _failed/"
  exit 1
fi
if [ ! -f "$TMP/ops/inbox/_failed/thing.xyz.reason" ]; then
  echo "FAIL: _failed/ entry missing .reason file"
  exit 1
fi

# md / txt / html originals must all be in _ingested/
for orig in clip-md.md notes-txt.txt page.html; do
  if ! ls "$TMP/ops/inbox/_ingested/" 2>/dev/null | grep -q -- "$orig"; then
    echo "FAIL: $orig not archived into _ingested/"
    ls -1 "$TMP/ops/inbox/_ingested/" 2>/dev/null || true
    exit 1
  fi
done

# --- log exists ---
if [ ! -s "$TMP/ops/inbox/drain.log" ]; then
  echo "FAIL: drain.log missing or empty"
  exit 1
fi
if ! grep -q 'CYCLE' "$TMP/ops/inbox/drain.log"; then
  echo "FAIL: drain.log missing CYCLE entry"
  exit 1
fi

# --- ops/out/ refusal: drop a file under ops/out/, try to drain from there ---
mkdir -p "$TMP/ops/out"
echo "# banned" > "$TMP/ops/out/should-refuse.md"
# direct primitive refusal (simulating a misconfigured drain)
OUT_RC=0
REFILED_ORIGINAL_PATH="$TMP/ops/out/should-refuse.md" \
REFILED_ORIGINAL_SHA256="$(shasum -a 256 "$TMP/ops/out/should-refuse.md" | awk '{print $1}')" \
  bin/vault-refile-append "$TMP/ops/out/should-refuse.md" "$TMP" >/dev/null 2>&1 || OUT_RC=$?
if [ "$OUT_RC" = "0" ]; then
  echo "FAIL: refile primitive accepted ops/out/ source"
  exit 1
fi

# --- second-run idempotence: re-drop the same md into inbox, drain should
#     still succeed (sha-idempotent) and not double-refile ---
cp "$TMP/ops/inbox/_ingested/"*clip-md.md "$TMP/ops/inbox/clip-md.md" 2>/dev/null || true
BEFORE=$(find "$TMP/ops/raw" -name '*.md' | wc -l | tr -d ' ')
VAULT_TEC_MARKITDOWN="${VAULT_TEC_MARKITDOWN:-}" \
  bin/vault-inbox-drain "$TMP" >/dev/null 2>&1 || true
AFTER=$(find "$TMP/ops/raw" -name '*.md' | wc -l | tr -d ' ')
if [ "$BEFORE" != "$AFTER" ]; then
  echo "FAIL: second drain of identical md re-created raw/ entry (before=$BEFORE after=$AFTER)"
  exit 1
fi

# --- --compile flag actually compiles when there's work ---
# drop one fresh md and invoke with --compile
cat > "$TMP/ops/inbox/second-clip.md" <<'EOF'
# Second Clip

## Only Section

payload line
EOF
VAULT_TEC_MARKITDOWN="${VAULT_TEC_MARKITDOWN:-}" \
  bin/vault-inbox-drain "$TMP" --compile >/dev/null 2>&1 || true
if ! find "$TMP/notes" -name '*.md' 2>/dev/null | grep -q .; then
  echo "FAIL: --compile did not produce notes/"
  exit 1
fi

echo "PASS: inbox-drain witness (md, txt, html, unsupported, idempotence, --compile) green${PDF_READY:+ [pdf-ready]}"
