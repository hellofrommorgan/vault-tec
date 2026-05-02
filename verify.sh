#!/usr/bin/env bash
# vault-tec verification gate.
#
# This repo is now intentionally small: deterministic mechanics plus tests.
# Agents own semantic judgment via ~/Mind/AGENTS.md. The gate only protects
# the mechanics that move bytes across vault surfaces.

set -u

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

RED=$'\033[0;31m'
GRN=$'\033[0;32m'
YLW=$'\033[0;33m'
BLU=$'\033[0;34m'
RST=$'\033[0m'

section() { printf "\n${BLU}==> %s${RST}\n" "$1"; }
ok()      { printf "  ${GRN}✓${RST} %s\n" "$1"; }
bad()     { printf "  ${RED}✗${RST} %s\n" "$1"; }
warn()    { printf "  ${YLW}!${RST} %s\n" "$1"; }

FAIL=0
PASS_COUNT=0
TOTAL_COUNT=0

run_test() {
  name="$1"
  cmd="$2"
  TOTAL_COUNT=$((TOTAL_COUNT + 1))
  section "$TOTAL_COUNT. $name"
  if eval "$cmd" >/dev/null 2>&1; then
    ok "$cmd"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    bad "$cmd"
    eval "$cmd" 2>&1 | sed 's/^/    /'
    FAIL=1
  fi
}

section "0. executable surface"
for f in \
  bin/vault-refile-append \
  bin/vault-inbox-drain \
  bin/vault-ingest-hermes-session \
  bin/vault-ingest-pdf \
  bin/vault-compile-replay \
  bin/vault-search \
  bin/vault-render \
  scripts/hermes-vault-cron.sh; do
  if [ -x "$f" ]; then
    ok "$f"
  else
    bad "$f missing or not executable"
    FAIL=1
  fi
done

section "0b. shell syntax"
SYNTAX_FAIL=0
for f in bin/vault-* scripts/*.sh; do
  [ -f "$f" ] || continue
  case "$(head -n 1 "$f" 2>/dev/null)" in
    *python*)
      if python3 -m py_compile "$f"; then
        ok "$f parses as python"
      else
        bad "$f python syntax error"
        SYNTAX_FAIL=1
        FAIL=1
      fi
      ;;
    *)
      if bash -n "$f"; then
        ok "$f parses as shell"
      else
        bad "$f shell syntax error"
        SYNTAX_FAIL=1
        FAIL=1
      fi
      ;;
  esac
done
if [ "$SYNTAX_FAIL" = "0" ]; then
  ok "all entrypoints parse"
fi

run_test "compile slice runtime witness" "./tests/test_compile_slice.sh"
run_test "search slice runtime witness" "./tests/test_search_slice.sh"
run_test "large-vault search non-empty witness" "./tests/test_search_large_vault_nonempty.sh"
run_test "render slice runtime witness" "./tests/test_render_slice.sh"
run_test "refile slice runtime witness" "./tests/test_refile_slice.sh"
run_test "provenance propagation witness" "./tests/test_provenance_propagation.sh"
run_test "pdf ingest witness" "./tests/test_pdf_ingest_slice.sh"
run_test "end-to-end loop closure witness" "./tests/test_e2e_loop.sh"
run_test "inbox drain witness" "./tests/test_inbox_drain.sh"
run_test "Hermes session ingest witness" "./tests/test_hermes_session_ingest.sh"
run_test "Hermes session digest witness" "./tests/test_hermes_session_digest.sh"
run_test "compile frontmatter contract witness" "./tests/test_compile_contract.sh"
run_test "live Mind compile guard witness" "./tests/test_live_vault_guard.sh"
run_test "LM-only vault steward shape witness" "./tests/test_vault_steward_shape.sh"

printf "\n=========================================\n"
printf "          VAULT-TEC VERIFICATION\n"
printf "=========================================\n"
printf "  mechanics tests : %s/%s pass\n" "$PASS_COUNT" "$TOTAL_COUNT"
printf "  shell syntax    : %s\n" "$([ "$SYNTAX_FAIL" = "0" ] && printf PASS || printf FAIL)"
printf "=========================================\n"

if [ "$FAIL" = "0" ]; then
  printf "✅ PASSED\n"
  exit 0
fi

printf "❌ FAILED\n"
exit 1
