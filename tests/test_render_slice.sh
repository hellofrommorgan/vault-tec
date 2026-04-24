#!/usr/bin/env bash
# tests/test_render_slice.sh
# Runtime witness for the NORTH STAR "rendered" step.
#
# Proves bin/vault-render reads COMPILED notes/ only (not ops/raw/, not
# cached output), emits a deterministic derived markdown artifact under
# ops/out/, and fails loud on missing source notes.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/ops/raw"

# intro.md has frontmatter-producing content + 2 H2 headings + a wikilink
cat > "$TMP/ops/raw/intro.md" <<'EOF'
# Intro

Brief overview.

## First Section

Some body. See [[other-concept]] for context.

## Second Section

More body. Cross reference [[other-concept]] again.
EOF

cat > "$TMP/ops/raw/other-concept.md" <<'EOF'
# Other Concept

Other content.
EOF

# compile (reuses slice 1)
bin/vault-compile-replay "$TMP" >/dev/null || {
  echo "FAIL: replay failed before render test"; exit 1; }

# sanity: compiled MOC exists as the source for render (MOCs have real H2s + wikilinks)
if ! test -f "$TMP/notes/intro-MOC.md"; then
  echo "FAIL: expected compiled notes/intro-MOC.md not found"
  ls "$TMP/notes" | sed 's/^/    /'
  exit 1
fi

# --- contract: renderer exists ---
test -x bin/vault-render \
  || { echo "FAIL: bin/vault-render missing or not executable"; exit 1; }

# pre: no ops/out
if [ -e "$TMP/ops/out/intro-MOC.rendered.md" ]; then
  echo "FAIL: ops/out/intro-MOC.rendered.md existed before render ran"
  exit 1
fi

# --- render the compiled MOC ---
bin/vault-render "$TMP" "intro-MOC" >/dev/null \
  || { echo "FAIL: vault-render exited non-zero on valid note"; exit 1; }

OUT="$TMP/ops/out/intro-MOC.rendered.md"
test -f "$OUT" || { echo "FAIL: $OUT not produced"; exit 1; }

# --- transform checks ---

# frontmatter block must be absent
if grep -qE '^---$' "$OUT"; then
  echo "FAIL: rendered output still contains YAML frontmatter delimiters"
  sed -n '1,8p' "$OUT" | sed 's/^/    /'
  exit 1
fi

# wikilinks must be rewritten
if grep -q '\[\[' "$OUT"; then
  echo "FAIL: rendered output still has [[wikilinks]]"
  grep -n '\[\[' "$OUT" | sed 's/^/    /'
  exit 1
fi
if ! grep -qE '\]\(\./[^)]+\.md\)' "$OUT"; then
  echo "FAIL: rendered output has no markdown links of form [x](./x.md)"
  sed -n '1,30p' "$OUT" | sed 's/^/    /'
  exit 1
fi

# TOC marker must be present — the renderer must emit a TOC header
if ! grep -qiE '^## (Table of Contents|TOC)$' "$OUT"; then
  echo "FAIL: no TOC header in rendered output"
  sed -n '1,10p' "$OUT" | sed 's/^/    /'
  exit 1
fi

# --- determinism: render twice, diff must be empty ---
cp "$OUT" "$TMP/.first.rendered.md"
bin/vault-render "$TMP" "intro-MOC" >/dev/null
diff -q "$TMP/.first.rendered.md" "$OUT" >/dev/null \
  || { echo "FAIL: renderer is non-deterministic"; exit 1; }

# --- anti-cheat: delete compiled note, render must fail ---
rm -f "$TMP/notes/intro-MOC.md"
set +e
bin/vault-render "$TMP" "intro-MOC" >/dev/null 2>"$TMP/.render.err"
RC=$?
set -e
if [ "$RC" = "0" ]; then
  echo "FAIL: vault-render succeeded after deleting compiled source note"
  exit 1
fi
if [ ! -s "$TMP/.render.err" ]; then
  echo "FAIL: vault-render silent on missing note (P10 fail-loud)"
  exit 1
fi

# --- misuse: no args → exit 2 ---
set +e
bin/vault-render >/dev/null 2>/dev/null
RC_MIS=$?
set -e
if [ "$RC_MIS" != "2" ]; then
  echo "FAIL: expected exit 2 on misuse, got $RC_MIS"
  exit 1
fi

echo "PASS: render slice witness complete"
