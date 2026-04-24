#!/usr/bin/env bash
# tests/test_vault_detection.sh
# Vault-detection compat witness: hooks accept either CLAUDE.md OR AGENTS.md
# as the vault marker, paired with self/ + notes/.
#
# Motivated by ~/Mind which uses AGENTS.md (not CLAUDE.md) but is otherwise
# a canonical vault-tec vault. Without this, session hooks silently no-op
# on AGENTS.md vaults even though their structure is valid.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Confirm the runtime grep pattern is present in every hook we touched.
for f in \
  hooks/scripts/vault-session-start.sh \
  hooks/scripts/vault-session-end.sh \
  hooks/scripts/vault-precompact.sh
do
  if ! grep -q 'AGENTS.md' "$f"; then
    echo "FAIL: $f missing AGENTS.md vault marker"
    exit 1
  fi
  if ! grep -q 'CLAUDE.md' "$f"; then
    echo "FAIL: $f lost CLAUDE.md backward compat"
    exit 1
  fi
done

# Smoke-test the start-hook guard logic by sourcing the predicate into a
# subshell with a synthetic vault. Build a CLAUDE-marked and an
# AGENTS-marked vault, and a bare dir. All three guards must short-circuit
# the hook only for the bare dir.
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

for marker in CLAUDE.md AGENTS.md NONE; do
  V="$TMP/$marker"
  mkdir -p "$V/self" "$V/notes"
  case "$marker" in
    CLAUDE.md|AGENTS.md) : > "$V/$marker" ;;
    NONE) : ;;
  esac
done

# Inline the exact predicate used by vault-session-start.sh and
# vault-session-end.sh for an honest smoke test.
check() {
  local V="$1"
  if { [ ! -f "$V/CLAUDE.md" ] && [ ! -f "$V/AGENTS.md" ]; } \
     || [ ! -d "$V/self" ] || [ ! -d "$V/notes" ]; then
    echo "no-vault"
  else
    echo "vault"
  fi
}

for marker in CLAUDE.md AGENTS.md; do
  r="$(check "$TMP/$marker")"
  if [ "$r" != "vault" ]; then
    echo "FAIL: $marker vault rejected by guard"
    exit 1
  fi
done

r="$(check "$TMP/NONE")"
if [ "$r" != "no-vault" ]; then
  echo "FAIL: bare dir (no marker) accepted as vault"
  exit 1
fi

echo "PASS: vault detection accepts CLAUDE.md and AGENTS.md; rejects unmarked dirs"
