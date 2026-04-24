#!/usr/bin/env bash
# vault-tec verification gate
# Runs under bash 3.2 (macOS default). No &>, no assoc arrays.
set -u

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

FAIL_SHELLCHECK=0
FAIL_FRONTMATTER=0
FAIL_DANGLING=0
FAIL_HOOKS_JSON=0
FAIL_COPILOT_EXT=0
WIKI_BROKEN=0

RED=$'\033[0;31m'
GRN=$'\033[0;32m'
YLW=$'\033[0;33m'
BLU=$'\033[0;34m'
RST=$'\033[0m'

section() { printf "\n${BLU}==> %s${RST}\n" "$1"; }
ok()      { printf "  ${GRN}✓${RST} %s\n" "$1"; }
bad()     { printf "  ${RED}✗${RST} %s\n" "$1"; }
warn()    { printf "  ${YLW}!${RST} %s\n" "$1"; }

# ---------------------------------------------------------------------------
section "1. shellcheck: hooks/scripts/*.sh"
if ! command -v shellcheck >/dev/null 2>&1; then
  bad "shellcheck not installed"
  FAIL_SHELLCHECK=1
else
  SC_ANY=0
  for f in hooks/scripts/*.sh; do
    [ -f "$f" ] || continue
    SC_ANY=1
    # -S error: only fail on error-level (warnings OK)
    if shellcheck -S error "$f"; then
      ok "$f"
    else
      bad "$f has shellcheck errors"
      FAIL_SHELLCHECK=1
    fi
  done
  if [ "$SC_ANY" = "0" ]; then
    warn "no hooks/scripts/*.sh found"
  fi
fi

# ---------------------------------------------------------------------------
section "2. YAML frontmatter validation"

# check_frontmatter <file> <key1> <key2> ...
check_frontmatter() {
  fm_file="$1"
  shift
  # Extract frontmatter block via python3 (stdlib only)
  block="$(python3 - "$fm_file" <<'PY'
import sys, re
p = sys.argv[1]
try:
    with open(p, 'r', encoding='utf-8') as fh:
        txt = fh.read()
except Exception as e:
    sys.stderr.write("read error: %s\n" % e)
    sys.exit(2)
m = re.match(r'^---\r?\n(.*?)\r?\n---\s*\n', txt, re.DOTALL)
if not m:
    sys.exit(1)
sys.stdout.write(m.group(1))
PY
)"
  rc=$?
  if [ $rc -ne 0 ]; then
    bad "$fm_file: missing or malformed frontmatter"
    FAIL_FRONTMATTER=1
    return
  fi
  missing=""
  for key in "$@"; do
    if ! printf '%s\n' "$block" | grep -qE "^${key}[[:space:]]*:" ; then
      missing="$missing $key"
    fi
  done
  if [ -n "$missing" ]; then
    bad "$fm_file: missing keys:$missing"
    FAIL_FRONTMATTER=1
  else
    ok "$fm_file"
  fi
}

for f in commands/*.md; do
  [ -f "$f" ] || continue
  check_frontmatter "$f" description allowed-tools
done

for f in skills/*/SKILL.md; do
  [ -f "$f" ] || continue
  check_frontmatter "$f" name description
done

for f in agents/*.md; do
  [ -f "$f" ] || continue
  check_frontmatter "$f" name description
done

# ---------------------------------------------------------------------------
section "3. Dangling \${CLAUDE_PLUGIN_ROOT} references"
# Find every ${CLAUDE_PLUGIN_ROOT}/<path> and check <path> exists
# grep -oE emits one match per line
TMPREFS="$ROOT/.verify_refs.$$"
: > "$TMPREFS"
# paths: commands/ and skills/
find commands skills -type f -name '*.md' 2>/dev/null | while read -r src; do
  grep -oE '\$\{CLAUDE_PLUGIN_ROOT\}/[A-Za-z0-9_./*-]+' "$src" 2>/dev/null | \
    while read -r ref; do
      rel="${ref#\$\{CLAUDE_PLUGIN_ROOT\}/}"
      printf '%s\t%s\n' "$src" "$rel" >> "$TMPREFS"
    done
done

if [ ! -s "$TMPREFS" ]; then
  warn "no \${CLAUDE_PLUGIN_ROOT} references found"
else
  # unique by (src,rel)
  sort -u "$TMPREFS" > "$TMPREFS.u" && mv "$TMPREFS.u" "$TMPREFS"
  DANGLING=0
  while IFS="$(printf '\t')" read -r src rel; do
    case "$rel" in
      *\**)
        # glob pattern: at least one match must exist
        matches=$(cd "$ROOT" && ls $rel 2>/dev/null | head -1)
        if [ -n "$matches" ]; then
          :
        else
          bad "$src -> \${CLAUDE_PLUGIN_ROOT}/$rel (no glob matches)"
          DANGLING=$((DANGLING + 1))
        fi
        ;;
      *)
        if [ -e "$ROOT/$rel" ]; then
          :
        else
          bad "$src -> \${CLAUDE_PLUGIN_ROOT}/$rel (missing)"
          DANGLING=$((DANGLING + 1))
        fi
        ;;
    esac
  done < "$TMPREFS"
  if [ "$DANGLING" = "0" ]; then
    ok "all \${CLAUDE_PLUGIN_ROOT} references resolve"
  else
    FAIL_DANGLING=1
  fi
fi
rm -f "$TMPREFS"

# ---------------------------------------------------------------------------
section "4. hooks/hooks.json JSON validity"
if [ ! -f hooks/hooks.json ]; then
  bad "hooks/hooks.json not found"
  FAIL_HOOKS_JSON=1
elif jq empty hooks/hooks.json >/dev/null 2>&1; then
  ok "hooks/hooks.json parses"
else
  bad "hooks/hooks.json invalid JSON"
  jq empty hooks/hooks.json 2>&1 | sed 's/^/    /'
  FAIL_HOOKS_JSON=1
fi

# ---------------------------------------------------------------------------
section "5. Wiki-link integrity (informational only)"
# Scan knowledge/ for [[target]] and check that a file named target.md exists
# somewhere under knowledge/. Ignore pipe aliases [[target|alias]].
if [ -d knowledge ]; then
  WIKI_TMP="$ROOT/.verify_wiki.$$"
  : > "$WIKI_TMP"
  find knowledge -type f -name '*.md' 2>/dev/null | while read -r src; do
    # capture [[...]] contents, strip alias after |, strip anchor #...
    grep -oE '\[\[[^]]+\]\]' "$src" 2>/dev/null | \
      sed -E 's/^\[\[//; s/\]\]$//; s/\|.*$//; s/#.*$//' | \
      while read -r target; do
        [ -n "$target" ] || continue
        printf '%s\t%s\n' "$src" "$target" >> "$WIKI_TMP"
      done
  done
  if [ -s "$WIKI_TMP" ]; then
    sort -u "$WIKI_TMP" > "$WIKI_TMP.u" && mv "$WIKI_TMP.u" "$WIKI_TMP"
    while IFS="$(printf '\t')" read -r src target; do
      # try exact basename match anywhere under knowledge/
      hit="$(find knowledge -type f -name "${target}.md" 2>/dev/null | head -1)"
      if [ -z "$hit" ]; then
        warn "$src: broken wiki-link [[$target]]"
        WIKI_BROKEN=$((WIKI_BROKEN + 1))
      fi
    done < "$WIKI_TMP"
    if [ "$WIKI_BROKEN" = "0" ]; then
      ok "all wiki-links resolve"
    fi
  else
    warn "no wiki-links found"
  fi
  rm -f "$WIKI_TMP"
else
  warn "no knowledge/ directory — skipping"
fi

# ---------------------------------------------------------------------------
section "6. Copilot CLI extension: node --check + scripts symlink"
if [ -f copilot-extension/extension.mjs ]; then
  if command -v node >/dev/null 2>&1; then
    if node --check copilot-extension/extension.mjs 2>/dev/null; then
      ok "copilot-extension/extension.mjs parses as ESM"
    else
      bad "copilot-extension/extension.mjs has syntax errors"
      node --check copilot-extension/extension.mjs 2>&1 | sed 's/^/    /'
      FAIL_COPILOT_EXT=1
    fi
  else
    warn "node not installed — skipping copilot-extension syntax check"
  fi
  if [ -L copilot-extension/scripts ]; then
    target=$(readlink copilot-extension/scripts)
    if [ -d copilot-extension/scripts/ ] && ls copilot-extension/scripts/vault-pretooluse.sh >/dev/null 2>&1; then
      ok "copilot-extension/scripts symlink resolves ($target)"
    else
      bad "copilot-extension/scripts symlink does not resolve to hooks/scripts"
      FAIL_COPILOT_EXT=1
    fi
  else
    warn "copilot-extension/scripts is not a symlink"
  fi
else
  warn "no copilot-extension/extension.mjs — skipping"
fi

# ---------------------------------------------------------------------------
FAIL_COMPILE_SLICE=0
section "7. Compile slice runtime witness (North Star: raw -> compiled wiki)"
if [ -x tests/test_compile_slice.sh ]; then
  if ./tests/test_compile_slice.sh >/dev/null 2>&1; then
    ok "tests/test_compile_slice.sh green"
  else
    bad "tests/test_compile_slice.sh failed"
    ./tests/test_compile_slice.sh 2>&1 | sed 's/^/    /'
    FAIL_COMPILE_SLICE=1
  fi
else
  warn "tests/test_compile_slice.sh not present — compile slice not wired"
fi

# ---------------------------------------------------------------------------
FAIL_SEARCH_SLICE=0
section "8. Search slice runtime witness (North Star: queried)"
if [ -x tests/test_search_slice.sh ]; then
  if ./tests/test_search_slice.sh >/dev/null 2>&1; then
    ok "tests/test_search_slice.sh green"
  else
    bad "tests/test_search_slice.sh failed"
    ./tests/test_search_slice.sh 2>&1 | sed 's/^/    /'
    FAIL_SEARCH_SLICE=1
  fi
else
  warn "tests/test_search_slice.sh not present — search slice not wired"
fi

# ---------------------------------------------------------------------------
FAIL_RENDER_SLICE=0
section "9. Render slice runtime witness (North Star: rendered)"
if [ -x tests/test_render_slice.sh ]; then
  if ./tests/test_render_slice.sh >/dev/null 2>&1; then
    ok "tests/test_render_slice.sh green"
  else
    bad "tests/test_render_slice.sh failed"
    ./tests/test_render_slice.sh 2>&1 | sed 's/^/    /'
    FAIL_RENDER_SLICE=1
  fi
else
  warn "tests/test_render_slice.sh not present — render slice not wired"
fi

# ---------------------------------------------------------------------------
FAIL_REFILE_SLICE=0
section "10. Refile slice runtime witness (North Star: refiled)"
if [ -x tests/test_refile_slice.sh ]; then
  if ./tests/test_refile_slice.sh >/dev/null 2>&1; then
    ok "tests/test_refile_slice.sh green"
  else
    bad "tests/test_refile_slice.sh failed"
    ./tests/test_refile_slice.sh 2>&1 | sed 's/^/    /'
    FAIL_REFILE_SLICE=1
  fi
else
  warn "tests/test_refile_slice.sh not present — refile slice not wired"
fi

# ---------------------------------------------------------------------------
FAIL_PROV_PROP=0
section "11. Provenance propagation witness (refile → compile lineage)"
if [ -x tests/test_provenance_propagation.sh ]; then
  if ./tests/test_provenance_propagation.sh >/dev/null 2>&1; then
    ok "tests/test_provenance_propagation.sh green"
  else
    bad "tests/test_provenance_propagation.sh failed"
    ./tests/test_provenance_propagation.sh 2>&1 | sed 's/^/    /'
    FAIL_PROV_PROP=1
  fi
else
  warn "tests/test_provenance_propagation.sh not present — provenance propagation not wired"
fi

# ---------------------------------------------------------------------------
FAIL_PDF_INGEST=0
section "12. PDF ingest witness (markitdown → ops/raw/)"
if [ -x tests/test_pdf_ingest_slice.sh ]; then
  if ./tests/test_pdf_ingest_slice.sh >/dev/null 2>&1; then
    ok "tests/test_pdf_ingest_slice.sh green"
  else
    bad "tests/test_pdf_ingest_slice.sh failed"
    ./tests/test_pdf_ingest_slice.sh 2>&1 | sed 's/^/    /'
    FAIL_PDF_INGEST=1
  fi
else
  warn "tests/test_pdf_ingest_slice.sh not present — pdf ingest not wired"
fi

# ---------------------------------------------------------------------------
FAIL_E2E_LOOP=0
section "13. End-to-end loop-closure witness (refile → compile → search → render)"
if [ -x tests/test_e2e_loop.sh ]; then
  if ./tests/test_e2e_loop.sh >/dev/null 2>&1; then
    ok "tests/test_e2e_loop.sh green"
  else
    bad "tests/test_e2e_loop.sh failed"
    ./tests/test_e2e_loop.sh 2>&1 | sed 's/^/    /'
    FAIL_E2E_LOOP=1
  fi
else
  warn "tests/test_e2e_loop.sh not present — e2e loop-closure not wired"
fi

# ---------------------------------------------------------------------------
FAIL_VAULT_DETECT=0
section "14. Vault detection witness (CLAUDE.md or AGENTS.md marker)"
if [ -x tests/test_vault_detection.sh ]; then
  if ./tests/test_vault_detection.sh >/dev/null 2>&1; then
    ok "tests/test_vault_detection.sh green"
  else
    bad "tests/test_vault_detection.sh failed"
    ./tests/test_vault_detection.sh 2>&1 | sed 's/^/    /'
    FAIL_VAULT_DETECT=1
  fi
else
  warn "tests/test_vault_detection.sh not present — vault detection not wired"
fi

# ---------------------------------------------------------------------------
FAIL_INBOX_DRAIN=0
section "15. Inbox drain witness (Option B: ops/inbox/ → ops/raw/)"
if [ -x tests/test_inbox_drain.sh ]; then
  if ./tests/test_inbox_drain.sh >/dev/null 2>&1; then
    ok "tests/test_inbox_drain.sh green"
  else
    bad "tests/test_inbox_drain.sh failed"
    ./tests/test_inbox_drain.sh 2>&1 | sed 's/^/    /'
    FAIL_INBOX_DRAIN=1
  fi
else
  warn "tests/test_inbox_drain.sh not present — inbox drain not wired"
fi

# ---------------------------------------------------------------------------
FAIL_HERMES_SESSION=0
section "16. Hermes session ingest witness (Option D: .json/.jsonl → inbox)"
if [ -x tests/test_hermes_session_ingest.sh ]; then
  if ./tests/test_hermes_session_ingest.sh >/dev/null 2>&1; then
    ok "tests/test_hermes_session_ingest.sh green"
  else
    bad "tests/test_hermes_session_ingest.sh failed"
    ./tests/test_hermes_session_ingest.sh 2>&1 | sed 's/^/    /'
    FAIL_HERMES_SESSION=1
  fi
else
  warn "tests/test_hermes_session_ingest.sh not present — hermes session ingest not wired"
fi

# ---------------------------------------------------------------------------
FAIL_HERMES_DIGEST=0
section "17. Hermes session digest witness (Option D+: extractive summary)"
if [ -x tests/test_hermes_session_digest.sh ]; then
  if ./tests/test_hermes_session_digest.sh >/dev/null 2>&1; then
    ok "tests/test_hermes_session_digest.sh green"
  else
    bad "tests/test_hermes_session_digest.sh failed"
    ./tests/test_hermes_session_digest.sh 2>&1 | sed 's/^/    /'
    FAIL_HERMES_DIGEST=1
  fi
else
  warn "tests/test_hermes_session_digest.sh not present — hermes session digest not wired"
fi

# ---------------------------------------------------------------------------
TOTAL_FAIL=$((FAIL_SHELLCHECK + FAIL_FRONTMATTER + FAIL_DANGLING + FAIL_HOOKS_JSON + FAIL_COPILOT_EXT + FAIL_COMPILE_SLICE + FAIL_SEARCH_SLICE + FAIL_RENDER_SLICE + FAIL_REFILE_SLICE + FAIL_PROV_PROP + FAIL_PDF_INGEST + FAIL_E2E_LOOP + FAIL_VAULT_DETECT + FAIL_INBOX_DRAIN + FAIL_HERMES_SESSION + FAIL_HERMES_DIGEST))

printf "\n"
printf "=========================================\n"
printf "          VAULT-TEC VERIFICATION\n"
printf "=========================================\n"
printf "  shellcheck        : %s\n"  "$([ $FAIL_SHELLCHECK  = 0 ] && echo PASS || echo FAIL)"
printf "  frontmatter       : %s\n"  "$([ $FAIL_FRONTMATTER = 0 ] && echo PASS || echo FAIL)"
printf "  plugin-root refs  : %s\n"  "$([ $FAIL_DANGLING    = 0 ] && echo PASS || echo FAIL)"
printf "  hooks.json        : %s\n"  "$([ $FAIL_HOOKS_JSON  = 0 ] && echo PASS || echo FAIL)"
printf "  copilot-extension : %s\n"  "$([ $FAIL_COPILOT_EXT = 0 ] && echo PASS || echo FAIL)"
printf "  compile slice     : %s\n"  "$([ $FAIL_COMPILE_SLICE = 0 ] && echo PASS || echo FAIL)"
printf "  search slice      : %s\n"  "$([ $FAIL_SEARCH_SLICE = 0 ] && echo PASS || echo FAIL)"
printf "  render slice      : %s\n"  "$([ $FAIL_RENDER_SLICE = 0 ] && echo PASS || echo FAIL)"
printf "  refile slice      : %s\n"  "$([ $FAIL_REFILE_SLICE = 0 ] && echo PASS || echo FAIL)"
printf "  provenance prop   : %s\n"  "$([ $FAIL_PROV_PROP = 0 ] && echo PASS || echo FAIL)"
printf "  pdf ingest        : %s\n"  "$([ $FAIL_PDF_INGEST = 0 ] && echo PASS || echo FAIL)"
printf "  e2e loop closure  : %s\n"  "$([ $FAIL_E2E_LOOP = 0 ] && echo PASS || echo FAIL)"
printf "  vault detection   : %s\n"  "$([ $FAIL_VAULT_DETECT = 0 ] && echo PASS || echo FAIL)"
printf "  inbox drain       : %s\n"  "$([ $FAIL_INBOX_DRAIN = 0 ] && echo PASS || echo FAIL)"
printf "  hermes session    : %s\n"  "$([ $FAIL_HERMES_SESSION = 0 ] && echo PASS || echo FAIL)"
printf "  hermes digest     : %s\n"  "$([ $FAIL_HERMES_DIGEST = 0 ] && echo PASS || echo FAIL)"
printf "  wiki-links (info) : %d broken\n" "$WIKI_BROKEN"
printf "=========================================\n"

if [ "$TOTAL_FAIL" = "0" ]; then
  printf "${GRN}✅ PASSED${RST} (gating checks: 16/16)\n"
  exit 0
else
  printf "${RED}❌ FAILED${RST} (%d gating check(s) failed)\n" "$TOTAL_FAIL"
  exit 1
fi
