#!/usr/bin/env bash
# tests/test_search_large_vault_nonempty.sh
#
# Regression witness for pipefail + `find | head` SIGPIPE false-empty bug.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SEARCH="$ROOT/bin/vault-search"
TMP="$(mktemp -d -t vt-search-large.XXXXXX)"
trap 'rm -rf "$TMP"' EXIT
VAULT="$TMP/vault"
mkdir -p "$VAULT/notes"

# Enough files to make `find | head -1` prone to SIGPIPE under pipefail on macOS.
for i in $(seq 1 300); do
  printf -- '---\ndescription: "note"\ntopics: ["[[index]]"]\n---\n# note %s\n\nbody\n' "$i" > "$VAULT/notes/note-$i.md"
done
printf -- '---\ndescription: "target"\ntopics: ["[[index]]"]\n---\n# target\n\nunique-large-search-token\n' > "$VAULT/notes/target.md"

OUT="$($SEARCH "$VAULT" unique-large-search-token)"
echo "$OUT" | grep -q 'notes/target.md' || { echo "FAIL: search did not return target note"; echo "$OUT"; exit 1; }

echo "PASS: vault-search detects non-empty large notes/ without pipefail false negative"
