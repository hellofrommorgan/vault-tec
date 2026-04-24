#!/usr/bin/env bash
# tests/test_compile_contract.sh
#
# F18 witness: vault-compile-replay honors raw-file frontmatter
#   compile: whole|sections|skip
#
# Asserts:
#   - whole    => exactly one note named after raw stem; no fragment notes;
#                 no MOC; transcript headings preserved verbatim in body
#   - sections => current behavior: section notes + MOC
#   - skip     => no notes emitted from that raw
#   - missing  => default sections behavior (legacy compat)
#   - invalid  => fail loud (non-zero rc)

set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
COMPILE="$ROOT/bin/vault-compile-replay"

VAULT="$(mktemp -d -t vt-contract.XXXXXX)"
trap 'rm -rf "$VAULT"' EXIT
mkdir -p "$VAULT/ops/raw" "$VAULT/notes" "$VAULT/ops/reports"
echo "# vault" > "$VAULT/AGENTS.md"
mkdir -p "$VAULT/self"

# 1. whole-mode raw with many ### headings
cat > "$VAULT/ops/raw/session-whole-fixture.md" <<'EOF'
---
title: Session Whole Fixture
compile: whole
---

# Session Whole Fixture

### 1. user
hello

### 2. assistant
hi

### 3. tool
result
EOF

# 2. sections-mode raw
cat > "$VAULT/ops/raw/digest-sections-fixture.md" <<'EOF'
---
title: Digest Sections Fixture
compile: sections
---

# Digest Sections Fixture

## role_counts

- user: 1

## tools_used

- foo
EOF

# 3. skip-mode raw
cat > "$VAULT/ops/raw/skip-fixture.md" <<'EOF'
---
compile: skip
---

# Skip Fixture
should not appear in notes/
EOF

# 4. legacy raw with no compile key
cat > "$VAULT/ops/raw/legacy-default-fixture.md" <<'EOF'
# Legacy Default Fixture

## Section A
body A

## Section B
body B
EOF

"$COMPILE" "$VAULT" >/dev/null

# whole-mode assertions
WHOLE_NOTE="$VAULT/notes/session-whole-fixture.md"
[ -f "$WHOLE_NOTE" ] || { echo "FAIL: whole-mode note missing: $WHOLE_NOTE"; exit 1; }
grep -q "^compile_mode: whole$" "$WHOLE_NOTE" || { echo "FAIL: whole note missing compile_mode frontmatter"; exit 1; }
grep -q "^### 1. user$" "$WHOLE_NOTE" || { echo "FAIL: whole note must preserve transcript headings verbatim"; exit 1; }
# no fragment seed notes from whole-mode raw
if ls "$VAULT/notes" | grep -E '^(1|2|3)-(user|assistant|tool)\.md$' >/dev/null; then
  echo "FAIL: whole-mode created fragment notes"; ls "$VAULT/notes"; exit 1
fi
# no MOC for whole-mode raw
if ls "$VAULT/notes" | grep -i 'session.*whole.*moc' >/dev/null; then
  echo "FAIL: whole-mode emitted MOC"; ls "$VAULT/notes"; exit 1
fi

# sections-mode assertions
ls "$VAULT/notes" | grep -i 'rolecounts' >/dev/null \
  || { echo "FAIL: sections-mode did not emit role_counts section note"; ls "$VAULT/notes"; exit 1; }
ls "$VAULT/notes" | grep -i 'Digest-Sections-Fixture-MOC' >/dev/null \
  || { echo "FAIL: sections-mode did not emit MOC"; ls "$VAULT/notes"; exit 1; }

# skip-mode assertions
if ls "$VAULT/notes" | grep -i 'skip-fixture\|Skip Fixture' >/dev/null; then
  echo "FAIL: skip-mode emitted notes"; ls "$VAULT/notes"; exit 1
fi

# legacy default behavior
ls "$VAULT/notes" | grep -i 'section-a\|Section-A' >/dev/null \
  || { echo "FAIL: legacy default did not split sections"; ls "$VAULT/notes"; exit 1; }

# invalid mode = fail loud
cat > "$VAULT/ops/raw/bad-mode.md" <<'EOF'
---
compile: bogus
---
# bad
EOF
if "$COMPILE" "$VAULT" >/dev/null 2>&1; then
  echo "FAIL: invalid compile mode did not fail loud"; exit 1
fi
rm -f "$VAULT/ops/raw/bad-mode.md"

echo "PASS: compile contract witness (whole|sections|skip|missing|invalid) green"
