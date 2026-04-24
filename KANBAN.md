# KANBAN — Autonomous Council Loop

> Live execution ledger. Append-only.
> Canonical tracker is score.json for *features*; this file tracks *slices* inside the council loop.

## Context

- Branch: auto/council-20260424-0508-northstar
- Goal: iterate vault-tec toward the CORRECT North Star direction from VISION.md
- Operator: unattended, agentic. Pause only for true steering (convention changes, destructive ops, ambiguous canonical source).

## Stopping criteria

Loop halts cleanly when ONE of:
1. **bar met** — a concrete runtime witness for the North Star loop (`raw → compiled wiki → queried → rendered → refiled`) exists end-to-end for at least ONE path, proven by a failing-test-then-green commit chain. "At least one path" means: a user can drop raw input into a documented location, run a single command, and observe atomic notes + MOC updates or a Q&A answer grounded in user content.
2. **substrate improved, runtime did not** — honest partial: features F2/F3 flipped to passes=true via actual work on the gate (not self-grade), or a subtractive cleanup landed, but no North Star path closed. Loop halts.
3. **blocked: <specific constraint>** — e.g. council names an architectural fork requiring human steering.
4. **thrash: council could not converge** — 2× same slice or 3× A↔B oscillation.

Forbidden outcomes:
- Self-graded `passes=true` on any feature without `./.score/score verify <id>` green.
- Adding daemons, databases, or frameworks (violates P8).
- Leaking vault-tec voice into shared machinery (violates P9).
- Silent swallowed errors in new hooks/scripts (violates P10).

## Runtime witness baseline (pre-loop)

Captured 2026-04-24T05:08Z on branch auto/council-20260424-0508-northstar @ d210a52:

- `./verify.sh` → exit 0, 5/5 gating checks PASS.
- `./.score/score audit` → AUDIT PASS, 2/2 passed features re-verified (F1, F8).
- `./.score/score status --brief` → 8 features, 2 passed, 6 ready, 0 blocked.
- Features ready but unverified: F2 hooks-shellcheck-clean, F3 frontmatter-lint-clean, F4 wiki-search-cli, F5 ask-the-wiki-prototype, F6 pdf-ingest-skill, F7 raw-compile-command.
- No executable test suite beyond `verify.sh` (0 `*.bats` / `test_*.sh` files).
- North Star artifacts present: VISION.md (lists 7 gaps), golden-principles.md (10 Ps), CLAUDE.md (SOP).
- North Star artifacts MISSING: no `raw/` dir, no `bin/vault-search`, no `commands/compile.md`, no `commands/query.md`, no `skills/pdf-ingest/`.

Baseline hash (to detect substrate drift): `$(cd ~/Projects/vault-tec && ./verify.sh 2>&1 | tail -10 | shasum -a 256 | awk '{print $1}')`

## Slice log

### slice 1 — compile-slice deterministic witness (F9)

- Council: 20260424T051644Z, 9/9 seats, chairman=claude-opus-4.7__executor (borda 46).
- SLICE: add commands/compile.md + bin/vault-compile-replay + ops/raw/ so raw markdown becomes observable status:seed notes + topic MOC via bash tests/test_compile_slice.sh.
- TDD: tests/test_compile_slice.sh written FIRST, failed for the right reason (commands/compile.md missing).
- Min-diff to green: commands/compile.md (contract + human UX), bin/vault-compile-replay (rule-based heading-split replayer, no LLM — preserves P8 fresh-clone-safe-ness), ops/raw/README.md.
- Wired as gating check #7 in verify.sh (6/6 PASS).
- Score ledger: F9 added, verified via `./.score/score verify 9` (tamper baseline re-seeded for verify.sh after honest rewrite). F7 rescored to depend_on=[9] + stricter criterion note (semantic sibling-weaving requires agent-driven /compile, not replay).
- Audit: 3/3 passed features re-verified (F1, F8, F9).
- Runtime witness (before → after):
  - before: `ls commands/compile.md bin/vault-compile-replay ops/raw` → all missing, `./tests/test_compile_slice.sh` → FAIL
  - after: `./tests/test_compile_slice.sh` → `PASS: compile slice witness complete`
  - sample run (/tmp/vt-witness): 3 seeds + 1 MOC + compile-report.md with `orphan_count=0`
- Collective blind spot surfaced + respected: council flagged that markdown-only `/compile` is not a runtime witness because it requires Claude at runtime. Correction: ship a deterministic bash replayer alongside the markdown command so `verify.sh` can gate on REAL output shape without an LLM.
- Honest partial: replay does NOT fabricate sibling links; F7 "≥2 links/note" stays false until agent-driven /compile lands.
- Halt reason: bar met for slice 1. Pausing for operator review before slice 2.

