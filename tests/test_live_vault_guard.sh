#!/usr/bin/env bash
# tests/test_live_vault_guard.sh
#
# Guard witness: vault-compile-replay must refuse live ~/Mind-style vaults
# unless the operator explicitly opts in. Scratch/test vaults still compile.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
COMPILE="$ROOT/bin/vault-compile-replay"

TMP="$(mktemp -d -t vt-live-guard.XXXXXX)"
trap 'rm -rf "$TMP"' EXIT

SCRATCH="$TMP/scratch-vault"
mkdir -p "$SCRATCH/ops/raw" "$SCRATCH/notes" "$SCRATCH/ops/reports"
cat > "$SCRATCH/ops/raw/seed.md" <<'EOF'
# Seed

## Claim
body
EOF

"$COMPILE" "$SCRATCH" >/dev/null
[ -f "$SCRATCH/notes/Claim-concept.md" ] || { echo "FAIL: scratch compile did not produce expected note"; find "$SCRATCH/notes" -maxdepth 1 -type f -print; exit 1; }

LIVE="$TMP/Mind"
mkdir -p "$LIVE/ops/raw" "$LIVE/notes" "$LIVE/ops/reports"
cat > "$LIVE/AGENTS.md" <<'EOF'
# CLAUDE.md — ~/Mind

`~/Mind/` is the vault.
EOF
cat > "$LIVE/ops/raw/seed.md" <<'EOF'
# Seed

## Claim
body
EOF

if "$COMPILE" "$LIVE" >/tmp/vt-live-guard.out 2>/tmp/vt-live-guard.err; then
  echo "FAIL: live Mind-shaped vault compile was not refused"
  exit 1
fi

grep -q "refusing live Mind vault" /tmp/vt-live-guard.err \
  || { echo "FAIL: live guard refusal message missing"; cat /tmp/vt-live-guard.err; exit 1; }

[ ! -f "$LIVE/notes/Claim.md" ] || { echo "FAIL: live guard wrote into notes before refusing"; exit 1; }

VAULT_TEC_ALLOW_LIVE_COMPILE=1 "$COMPILE" "$LIVE" >/dev/null
[ -f "$LIVE/notes/Claim-concept.md" ] || { echo "FAIL: explicit live opt-in did not compile"; find "$LIVE/notes" -maxdepth 1 -type f -print; exit 1; }

echo "PASS: live vault guard refuses Mind-shaped vaults unless explicitly opted in"
