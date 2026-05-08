#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

test -x bin/vault-inbox-drain || { echo "FAIL: bin/vault-inbox-drain missing"; exit 1; }
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/ops/inbox"
cat > "$TMP/ops/inbox/automated-seed.md" <<'EOF'
---
type: seed
seed_role: lab
seed_status: inbox
human_touched: false
sources: "fixture"
topics: ["[[agent-memory-and-context]]"]
---
# automated seed

#seed/lab

This generated seed must not be promoted by inbox drain.
EOF

bin/vault-inbox-drain "$TMP" >/tmp/vault-seed-guard.out 2>/tmp/vault-seed-guard.err

if [ ! -f "$TMP/ops/inbox/automated-seed.md" ]; then
  echo "FAIL: untouched automated seed was moved out of active inbox"
  find "$TMP" -maxdepth 4 -type f | sort
  exit 1
fi
if find "$TMP/ops/raw" -type f -name '*.md' 2>/dev/null | grep -q .; then
  echo "FAIL: untouched automated seed was refiled into ops/raw"
  find "$TMP/ops/raw" -type f -maxdepth 2 -print
  exit 1
fi
if ! grep -q 'SKIP_SEED' "$TMP/ops/inbox/drain.log"; then
  echo "FAIL: drain log did not record SKIP_SEED"
  cat "$TMP/ops/inbox/drain.log" 2>/dev/null || true
  exit 1
fi

python3 - <<'PY' "$TMP/ops/inbox/automated-seed.md"
from pathlib import Path
import sys
p=Path(sys.argv[1])
t=p.read_text()
t=t.replace('human_touched: false', 'human_touched: true')
p.write_text(t)
PY

bin/vault-inbox-drain "$TMP" >/tmp/vault-seed-guard2.out 2>/tmp/vault-seed-guard2.err
if [ -f "$TMP/ops/inbox/automated-seed.md" ]; then
  echo "FAIL: human-touched seed was still skipped"
  exit 1
fi
if ! find "$TMP/ops/raw" -type f -name '*.md' 2>/dev/null | grep -q .; then
  echo "FAIL: human-touched seed did not enter ops/raw"
  exit 1
fi

echo "PASS: inbox-drain skips untouched automated seeds and accepts human-touched seeds"
