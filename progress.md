# Progress

## Canonical feature state

See `score.json` for the authoritative feature ledger. At the time of this update:

- F1 verify-sh-green — PASS (gate exists, 12/12 checks green)
- F2 hooks-shellcheck-clean — READY, unverified
- F3 frontmatter-lint-clean — READY, unverified
- F4 wiki-search-cli — PASS ← slice 2 (queried step)
- F5 ask-the-wiki-prototype — READY, unverified
- F6 pdf-ingest-markitdown — PASS ← slice 6 (PDF ingress via Microsoft MarkItDown)
- F7 raw-compile-command — READY, unverified (depends on F9; requires agent-driven compile, not replay)
- F8 copilot-cli-parity — PASS
- F9 compile-slice-deterministic-witness — PASS ← slice 1 (compiled step)
- F10 render-slice-deterministic-witness — PASS ← slice 3 (rendered step)
- F11 refile-slice-deterministic-witness — PASS ← slice 4 (refiled step — LOOP CLOSED)
- F12 provenance-propagation-witness — PASS ← slice 5 (lineage from notes/ alone)
- F13 e2e-loop-closure-witness — PASS ← campaign L1 (full chain refile→compile→search→render)

North Star loop — all 5 edges have concrete CLI witnesses:
  raw      ops/raw/
  compiled bin/vault-compile-replay
  queried  bin/vault-search
  rendered bin/vault-render
  refiled  bin/vault-refile-append

## North Star runtime witness

The first concrete closure of the VISION.md North Star loop (`raw → compiled wiki → queried → rendered → refiled`) is live as of F9. A user can:

1. Drop markdown into `ops/raw/`.
2. Either invoke `/compile` inside an agent session, OR run `bin/vault-compile-replay <vault-root>` deterministically.
3. Observe `status: seed` atomic notes + topic MOC appear under `notes/`, plus `ops/reports/compile-report.md` with `orphan_count=N`.

`bin/vault-compile-replay` is a rule-based heading-split replayer — it is NOT a replacement for agent-driven `/compile`. It exists so `tests/test_compile_slice.sh` can prove the SHAPE of the compile output on a fresh clone with no LLM available (preserves P8). Agent-driven `/compile` is expected to produce richer titling and defensibly-grounded sibling links; deterministic replay deliberately refuses to fabricate links (P4/P10).

## Next work item

The North Star loop has exactly ONE path closed. Downstream slices (F4 wiki-search-cli, F5 ask-the-wiki, F6 pdf-ingest, F7 semantic compile upgrade, plus renderers and raw-ingest clippers) all build on compiled user content existing. The next council run will pick the single highest-leverage follow-on.
