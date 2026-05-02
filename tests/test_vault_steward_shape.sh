#!/usr/bin/env bash
# tests/test_vault_steward_shape.sh
#
# LM-only steward witness: vault-tec may provide a prompt and a dumb runner,
# but it must not grow a semantic scanner/runtime around the ritual.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PROMPT="prompts/vault-steward.md"
RUNNER="bin/vault-steward"

[ -f "$PROMPT" ] || { echo "FAIL: missing $PROMPT"; exit 1; }
[ -x "$RUNNER" ] || { echo "FAIL: missing executable $RUNNER"; exit 1; }

# Prompt must encode the council's parsimony/safety contract.
grep -q "Vault Steward Brief" "$PROMPT" || { echo "FAIL: prompt missing ritual name"; exit 1; }
grep -q "/Users/morgan/Mind/AGENTS.md" "$PROMPT" || { echo "FAIL: prompt must require AGENTS.md"; exit 1; }
grep -q "/Users/morgan/Mind/notes/" "$PROMPT" || { echo "FAIL: prompt must name notes/ as canonical"; exit 1; }
grep -q "/Users/morgan/Mind/ops/vault-tec" "$PROMPT" || { echo "FAIL: prompt must write only ops/vault-tec report"; exit 1; }
grep -q "write exactly one Markdown report" "$PROMPT" || { echo "FAIL: prompt must require one dated Markdown report"; exit 1; }
grep -q "Do not edit notes" "$PROMPT" || { echo "FAIL: prompt must forbid notes edits"; exit 1; }
grep -q "Do not produce JSON" "$PROMPT" || { echo "FAIL: prompt must forbid JSON"; exit 1; }
grep -q "caches, ledgers, snapshots, or context packs" "$PROMPT" || { echo "FAIL: prompt must forbid extra artifact classes"; exit 1; }
grep -q "No cited note evidence, no finding" "$PROMPT" || { echo "FAIL: prompt must enforce cited evidence"; exit 1; }

# Runner is allowed to be a clock+pipe only. It must not inspect/rank the graph.
grep -q 'date +%F' "$RUNNER" || { echo "FAIL: runner must compute an ISO dated report path"; exit 1; }
grep -q '\.md' "$RUNNER" || { echo "FAIL: runner report path must be Markdown"; exit 1; }
grep -q '/Users/morgan/Mind' "$RUNNER" || { echo "FAIL: runner must default to /Users/morgan/Mind"; exit 1; }
if grep -Eq '\b(grep|find|python|jq|sqlite3|rg)\b' "$RUNNER"; then
  echo "FAIL: vault-steward runner must not scan or compute over the vault"
  exit 1
fi
if grep -Eq 'json|ledger|snapshot|context-pack|score|inbound|topology|confidence' "$RUNNER"; then
  echo "FAIL: vault-steward runner leaked semantic/runtime machinery"
  exit 1
fi

echo "PASS: LM-only vault steward shape is prompt + dumb runner only"
