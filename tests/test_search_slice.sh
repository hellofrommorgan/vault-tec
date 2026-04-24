#!/usr/bin/env bash
# tests/test_search_slice.sh
# Runtime witness for the NORTH STAR "queried" step.
#
# Anti-cheat: compile a temp vault, delete ops/raw/, then prove
# bin/vault-search returns hits from COMPILED artifacts only. This
# prevents the dishonest implementation where "search" just greps
# ops/raw/ or the repo as a whole.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/ops/raw"

# seed raw with a deliberately rare token
RARE="zxqvault42token"
cat > "$TMP/ops/raw/learning.md" <<EOF
# Learning

Brief overview.

## Cognitive Load

The concept ${RARE} appears here as a rare probe.

## Retrieval Practice

Retrieval practice strengthens recall.
EOF

# --- compile first (depends on slice 1 replayer) ---
bin/vault-compile-replay "$TMP" >/dev/null \
  || { echo "FAIL: replay failed before search test"; exit 1; }

# sanity: compiled notes exist
if ! find "$TMP/notes" -type f -name '*.md' | grep -q .; then
  echo "FAIL: no compiled notes produced, cannot test search"
  exit 1
fi

# --- anti-cheat: scrub raw so hits can only come from compiled artifacts ---
rm -rf "$TMP/ops/raw"

# --- contract: vault-search exists + executable ---
test -x bin/vault-search \
  || { echo "FAIL: bin/vault-search missing or not executable"; exit 1; }

# --- hit case ---
HIT_OUT="$(bin/vault-search "$TMP" "$RARE" 2>&1)" || {
  echo "FAIL: vault-search returned non-zero on real hit"
  echo "$HIT_OUT" | sed 's/^/    /'
  exit 1
}

if ! printf '%s' "$HIT_OUT" | grep -q "notes/"; then
  echo "FAIL: hit output does not reference notes/ path"
  printf '%s\n' "$HIT_OUT" | sed 's/^/    /'
  exit 1
fi

if printf '%s' "$HIT_OUT" | grep -q "ops/raw/"; then
  echo "FAIL: hit output references ops/raw/ — search cheated"
  exit 1
fi

# --- miss case: non-zero exit, fail loud on stderr ---
MISS_ERR="$(bin/vault-search "$TMP" "no-such-token-xyz" 2>&1 1>/dev/null || true)"
MISS_RC=0
bin/vault-search "$TMP" "no-such-token-xyz" >/dev/null 2>&1 || MISS_RC=$?
if [ "$MISS_RC" = "0" ]; then
  echo "FAIL: vault-search should exit non-zero on no hits"
  exit 1
fi
if [ -z "$MISS_ERR" ]; then
  echo "FAIL: vault-search silent on miss; P10 requires fail-loud stderr"
  exit 1
fi

# --- empty-vault case: fail loud ---
EMPTY="$(mktemp -d)"
trap 'rm -rf "$TMP" "$EMPTY"' EXIT
EMPTY_ERR="$(bin/vault-search "$EMPTY" "anything" 2>&1 1>/dev/null || true)"
EMPTY_RC=0
bin/vault-search "$EMPTY" "anything" >/dev/null 2>&1 || EMPTY_RC=$?
if [ "$EMPTY_RC" = "0" ]; then
  echo "FAIL: vault-search should fail on empty/no-notes vault"
  exit 1
fi
if ! printf '%s' "$EMPTY_ERR" | grep -qi 'notes'; then
  echo "FAIL: empty-vault error should mention missing notes dir"
  exit 1
fi

echo "PASS: search slice witness complete"
