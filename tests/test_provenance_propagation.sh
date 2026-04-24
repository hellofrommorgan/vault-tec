#!/usr/bin/env bash
# tests/test_provenance_propagation.sh
# Runtime witness that bin/vault-compile-replay propagates refile
# provenance (original_sha256, refiled_from) from ops/raw/ frontmatter
# into EVERY compiled note (seed + MOC) frontmatter.
#
# Closes the honest-contract gap flagged in F11: after refile→compile,
# compiled notes must carry the SHA of the original external source, so
# operators can reason about lineage in notes/ alone.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

VAULT="$TMP/vault"
mkdir -p "$VAULT/ops/raw"

# stage an external artifact and refile it so the raw carries provenance fm
SRC="$TMP/external-insight.md"
cat > "$SRC" <<'EOF'
# Provenance Topic

Body text with token zxqprov77token.

## Decision

Sunset the legacy thing.
EOF

SHA="$(shasum -a 256 "$SRC" | awk '{print $1}')"

REFILED_BY=tester bin/vault-refile-append "$SRC" "$VAULT" >/dev/null \
  || { echo "FAIL: precondition — refile failed"; exit 1; }

RAW_LANDED="$(find "$VAULT/ops/raw" -type f -name '*.md' | head -1)"
REL_LANDED="ops/raw/$(basename "$RAW_LANDED")"

# sanity: raw has provenance fm (that's F11's contract; re-assert so this
# test fails loudly if F11 ever regresses)
grep -q "^original_sha256: $SHA$" "$RAW_LANDED" \
  || { echo "FAIL: precondition — raw lacks original_sha256"; exit 1; }

# --- compile ---
bin/vault-compile-replay "$VAULT" >/dev/null \
  || { echo "FAIL: vault-compile-replay exited non-zero"; exit 1; }

# there should be >= 2 compiled notes (seed + MOC; split by headings)
NOTE_COUNT="$(find "$VAULT/notes" -type f -name '*.md' | wc -l | tr -d ' ')"
test "$NOTE_COUNT" -ge 2 \
  || { echo "FAIL: expected >=2 compiled notes, got $NOTE_COUNT"; exit 1; }

# --- assertion: EVERY compiled note carries the provenance keys ---
MISSING=0
for n in "$VAULT/notes"/*.md; do
  if ! grep -q "^original_sha256: $SHA$" "$n"; then
    echo "FAIL: note $(basename "$n") missing original_sha256 fm key"
    MISSING=1
  fi
  if ! grep -qE "^refiled_from: $REL_LANDED\$" "$n"; then
    echo "FAIL: note $(basename "$n") missing 'refiled_from: $REL_LANDED' fm key"
    MISSING=1
  fi
done
test "$MISSING" = "0" || exit 1

# --- honesty: raw without provenance fm should NOT inject fake provenance ---
# seed an orphan raw with no provenance and re-run; new notes from it must
# NOT carry original_sha256 (prevents compiler from manufacturing fake SHAs)
cat > "$VAULT/ops/raw/handwritten.md" <<'EOF'
# Handwritten

## Idea

A locally authored idea, never refiled.
EOF

bin/vault-compile-replay "$VAULT" >/dev/null \
  || { echo "FAIL: second compile exited non-zero"; exit 1; }

HAND_NOTES="$(find "$VAULT/notes" -type f -name '*.md' -newer "$VAULT/ops/raw/handwritten.md")"
# simpler: check the specific MOC we expect
HAND_MOC="$VAULT/notes/handwritten-MOC.md"
test -f "$HAND_MOC" || { echo "FAIL: handwritten-MOC.md not produced"; exit 1; }

if grep -q '^original_sha256:' "$HAND_MOC"; then
  echo "FAIL: handwritten-MOC.md carries original_sha256 but raw had no provenance"
  grep '^original_sha256:' "$HAND_MOC" | sed 's/^/    /'
  exit 1
fi
if grep -q '^refiled_from:' "$HAND_MOC"; then
  echo "FAIL: handwritten-MOC.md carries refiled_from but raw had no provenance"
  exit 1
fi

# and the provenance-bearing notes from the refiled source must STILL
# carry their provenance after the second compile (idempotent propagation)
for n in "$VAULT/notes"/*.md; do
  case "$(basename "$n")" in
    handwritten-MOC.md|Handwritten-MOC.md|Handwritten-concept.md|Idea-concept.md)
      continue ;;
  esac
  grep -q "^original_sha256: $SHA$" "$n" \
    || { echo "FAIL: after 2nd compile, note $(basename "$n") lost provenance"; exit 1; }
done

echo "PASS: provenance propagation witness complete"
