#!/usr/bin/env bash
# tests/test_e2e_loop.sh
# North Star end-to-end loop-closure witness.
#
# Chains the full pipeline in one scenario and asserts each edge produced
# its expected artifact, all fed by a single seed source:
#
#   external-insight.md
#       └─ refile  → vault/ops/raw/<slug>.md (with provenance fm)
#           └─ compile → vault/notes/*.md seeds + *-MOC.md
#               └─ search → hits on the original token
#                   └─ render → vault/ops/out/*.rendered.md (derived-only)
#
# This witness exists to catch regressions that individual edge tests
# miss — e.g. a refile/compile schema drift that breaks downstream
# render or search even when their unit witnesses are green.

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

Captured from an external meeting. Discusses topic zxqe2eloop99token
and references the broader decision framework.

## Key Finding

The finding includes the token zxqe2eloop99token for unique search
matching, plus [[decision-framework]] as a wiki link.

## Recommendation

Adopt the framework.
EOF

# ---------- edge 1: refile ----------
REFILED_BY=e2etester bin/vault-refile-append "$SRC" "$VAULT" >/dev/null \
  || { echo "FAIL(e2e): refile exited non-zero"; exit 1; }

RAW_COUNT="$(find "$VAULT/ops/raw" -type f -name '*.md' | wc -l | tr -d ' ')"
test "$RAW_COUNT" -ge 1 \
  || { echo "FAIL(e2e): refile did not land a file in ops/raw/"; exit 1; }

LANDED="$(find "$VAULT/ops/raw" -type f -name '*.md' | head -1)"
grep -q "^original_sha256:" "$LANDED" \
  || { echo "FAIL(e2e): landed raw missing original_sha256 frontmatter"; exit 1; }

# ---------- edge 2: compile ----------
bin/vault-compile-replay "$VAULT" >/dev/null \
  || { echo "FAIL(e2e): vault-compile-replay exited non-zero"; exit 1; }

NOTES_COUNT="$(find "$VAULT/notes" -type f -name '*.md' | wc -l | tr -d ' ')"
test "$NOTES_COUNT" -ge 1 \
  || { echo "FAIL(e2e): compile produced no notes/*.md"; exit 1; }

# a MOC should have been emitted for the seed document
MOC_COUNT="$(find "$VAULT/notes" -type f -name '*-MOC.md' | wc -l | tr -d ' ')"
test "$MOC_COUNT" -ge 1 \
  || { echo "FAIL(e2e): compile produced no *-MOC.md"; exit 1; }

# ---------- edge 3: search ----------
HITS="$(bin/vault-search "$VAULT" zxqe2eloop99token || true)"
if [ -z "$HITS" ]; then
  echo "FAIL(e2e): search returned zero hits for seeded unique token"
  echo "notes/ contents:"; ls "$VAULT/notes" | sed 's/^/    /'
  exit 1
fi
echo "$HITS" | grep -q "zxqe2eloop99token" \
  || { echo "FAIL(e2e): search output missing the seeded token line"; exit 1; }

# search must not surface ops/raw/ or ops/out/ paths (compiled notes only)
if echo "$HITS" | grep -qE "(ops/raw/|ops/out/)"; then
  echo "FAIL(e2e): search leaked non-canonical paths (ops/raw or ops/out)"
  echo "$HITS"
  exit 1
fi

# ---------- edge 4: render ----------
# render the first MOC
MOC_PATH="$(find "$VAULT/notes" -type f -name '*-MOC.md' | head -1)"
MOC_BASENAME="$(basename "$MOC_PATH" .md)"

bin/vault-render "$VAULT" "$MOC_BASENAME" >/dev/null \
  || { echo "FAIL(e2e): vault-render exited non-zero"; exit 1; }

RENDERED_COUNT="$(find "$VAULT/ops/out" -type f -name '*.rendered.md' | wc -l | tr -d ' ')"
test "$RENDERED_COUNT" -ge 1 \
  || { echo "FAIL(e2e): render produced no ops/out/*.rendered.md"; exit 1; }

# anti-cheat: rendered artifact must not appear in notes/ (derived-only)
if find "$VAULT/notes" -type f -name '*.rendered.md' | grep -q .; then
  echo "FAIL(e2e): rendered artifact leaked into canonical notes/"
  exit 1
fi

echo "PASS: end-to-end loop-closure (refile → compile → search → render) — all 4 edges green"
