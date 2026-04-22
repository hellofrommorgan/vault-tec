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
TOTAL_FAIL=$((FAIL_SHELLCHECK + FAIL_FRONTMATTER + FAIL_DANGLING + FAIL_HOOKS_JSON))

printf "\n"
printf "=========================================\n"
printf "          VAULT-TEC VERIFICATION\n"
printf "=========================================\n"
printf "  shellcheck        : %s\n"  "$([ $FAIL_SHELLCHECK  = 0 ] && echo PASS || echo FAIL)"
printf "  frontmatter       : %s\n"  "$([ $FAIL_FRONTMATTER = 0 ] && echo PASS || echo FAIL)"
printf "  plugin-root refs  : %s\n"  "$([ $FAIL_DANGLING    = 0 ] && echo PASS || echo FAIL)"
printf "  hooks.json        : %s\n"  "$([ $FAIL_HOOKS_JSON  = 0 ] && echo PASS || echo FAIL)"
printf "  wiki-links (info) : %d broken\n" "$WIKI_BROKEN"
printf "=========================================\n"

if [ "$TOTAL_FAIL" = "0" ]; then
  printf "${GRN}✅ PASSED${RST} (gating checks: 4/4)\n"
  exit 0
else
  printf "${RED}❌ FAILED${RST} (%d gating check(s) failed)\n" "$TOTAL_FAIL"
  exit 1
fi
