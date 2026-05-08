#!/usr/bin/env bash
# tests/test_compile_slice.sh
# Deterministic runtime witness for the North Star compile loop.
# Runs on a fresh clone with no LLM available — uses bin/vault-compile-replay
# as a rule-based (heading-split) replayer proving the vault SHAPE and write
# contract, not the semantic LLM body-fill.
#
# Honest disclosure: this test does NOT prove Claude can compile well. It
# proves the compile command surface, the seed-note contract, the MOC
# contract, and the orphan-report contract are all observable on disk.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/ops/raw" "$TMP/notes" "$TMP/ops/reports"

cat > "$TMP/ops/raw/sample.md" <<'EOF'
# Spaced Repetition

Spaced repetition improves retention by increasing review intervals.

## Retrieval Practice

Retrieval practice strengthens recall.

## Desirable Difficulty

Harder recall can improve long-term learning when still manageable.
EOF

# --- contract: deterministic replay harness exists and is executable ---
test -x bin/vault-compile-replay \
  || { echo "FAIL: bin/vault-compile-replay missing or not executable"; exit 1; }

# --- execute the replay against an isolated temp vault ---
bin/vault-compile-replay "$TMP" \
  || { echo "FAIL: vault-compile-replay exited non-zero"; exit 1; }

# --- witnesses on disk ---

# at least one seed note was produced
if ! find "$TMP/notes" -type f -name '*.md' | grep -q .; then
  echo "FAIL: no notes produced under $TMP/notes"
  exit 1
fi

# produced notes are status: seed (frontmatter line)
if ! grep -R -E '^status:[[:space:]]*seed$' "$TMP/notes" >/dev/null; then
  echo "FAIL: no 'status: seed' frontmatter in produced notes"
  exit 1
fi

# a topic MOC file was produced
if ! find "$TMP/notes" -type f -iname '*MOC*.md' | grep -q .; then
  echo "FAIL: no *MOC*.md produced under $TMP/notes"
  exit 1
fi

# MOC contains wiki-links back to seed notes (P4/P5 spirit)
moc_file="$(find "$TMP/notes" -type f -iname '*MOC*.md' | head -1)"
if ! grep -qE '\[\[[^]]+\]\]' "$moc_file"; then
  echo "FAIL: MOC $moc_file has no [[wiki-links]]"
  exit 1
fi

# compile-report emitted with orphan_count= line (P10: fail loud, report)
test -f "$TMP/ops/reports/compile-report.md" \
  || { echo "FAIL: ops/reports/compile-report.md missing"; exit 1; }
grep -qE '^orphan_count=[0-9]+' "$TMP/ops/reports/compile-report.md" \
  || { echo "FAIL: compile-report.md missing orphan_count=N line"; exit 1; }

echo "PASS: compile slice witness complete"
