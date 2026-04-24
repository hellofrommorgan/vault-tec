# Progress

## Canonical feature state

See `score.json` for the authoritative feature ledger. At the time of this update:

- F1 verify-sh-green — PASS (gate exists, 15/15 checks green)
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

## Hermes integration (Options A, B, D — landed)

Hermes does not share Claude Code's hook bus; it feeds the vault through three thin, Hermes-side surfaces that all terminate in canonical vault-tec primitives:

- **Option A — `vault-capture` skill** (`~/.hermes/skills/note-taking/vault-capture/SKILL.md`): explicit user-triggered capture (URL / text / file) drops markdown into `~/Mind/ops/inbox/`. Skill never writes to `raw/`, `notes/`, or `out/`; the drain owns all downstream transitions.
- **Option B — `bin/vault-inbox-drain <vault> [--compile]`** (F15): cron-friendly dispatcher that promotes `ops/inbox/*.{md,pdf,txt,html}` to `ops/raw/` via `vault-refile-append` / `vault-ingest-pdf`. Successful items archive to `ops/inbox/_ingested/<sha8>-<name>`; unsupported types go to `ops/inbox/_failed/` with a `.reason` sidecar; cycles append to `ops/inbox/drain.log`. `ops/out/` refusal is inherited from the refile primitive.
- **Option D — `bin/vault-ingest-hermes-session <session-file> <vault>`** (F16): shape-converts a Hermes session transcript (`~/.hermes/sessions/*.{json,jsonl}`) into a single deterministic `ops/inbox/session-<stem>-<ext>.md` drop. Raw role + content preserved; no wall-clock fields in body so sha-idempotent across re-runs.
- **Cron bridge — `scripts/hermes-vault-cron.sh`**: single entrypoint the Hermes cron calls every 15 min. Ingests the 5 newest sessions, drains the inbox, kicks off a backgrounded compile guarded by an mkdir-atomic lock under `ops/reports/cron/.compile.lockdir` (compile over a 1400-note vault takes ~2 min; drain returns in <1s). Heartbeat log: `ops/reports/cron/hermes-vault-cron.log`.

Target vault: `~/Mind` (uses `AGENTS.md` rather than `CLAUDE.md`; hook detection updated in F14 to accept either marker).

## Next work item

The North Star loop has exactly ONE path closed. Downstream slices (F4 wiki-search-cli, F5 ask-the-wiki, F6 pdf-ingest, F7 semantic compile upgrade, plus renderers and raw-ingest clippers) all build on compiled user content existing. The next council run will pick the single highest-leverage follow-on.
