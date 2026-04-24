---
description: Compile raw markdown in ops/raw/ into atomic status:seed notes + a topic MOC, emitting an orphan report
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# /compile

> Metabolize raw user material in `ops/raw/` into atomic, linked `status: seed` notes under `notes/`, build or update a topic MOC, and emit `ops/reports/compile-report.md` with an orphan count.

## North Star position

This command is the FIRST concrete closure of the Karpathy compile loop named in `VISION.md`: **raw → compiled wiki**. Everything downstream (search, ask-the-wiki, multi-format renderers, PDF ingest, repo ingest) depends on compiled user content existing in the vault at all.

## Contract

Given `ops/raw/` contains one or more `*.md` files authored by the human:

1. Read each raw file. Split it by Markdown headings into candidate atomic notes. Each section = one atomic claim (P1).
2. Title each note as a 3–10 word noun phrase that reads as `[[wiki-link]]` (P2). Use the heading text directly if it already satisfies this shape; otherwise rewrite.
3. Write each note to `notes/<Title>.md` with YAML frontmatter:
   ```
   ---
   title: <Title>
   status: seed
   source: <relative path of ops/raw file>
   topics: [<topic inferred from source filename or top heading>]
   ---
   ```
4. Build or update `notes/<Topic>-MOC.md` (one per raw-file topic). The MOC body MUST contain `[[wiki-link]]` references to every note compiled under that topic. MOC reachability must land any seed ≤ 3 hops from `_MOC-Master.md` (P5) — link the topic MOC from the master MOC if one exists.
5. Weave sibling cross-links ONLY when the connection is explicit in the raw source. Do NOT fabricate links (P4/P10).
6. Write `ops/reports/compile-report.md` containing at minimum:
   ```
   orphan_count=<N>
   compiled_at=<UTC ISO>
   notes_created=<N>
   notes_updated=<N>
   raw_files_processed=<N>
   ```
   Orphans = produced notes with zero inbound wiki-links after the run.
7. All writes pass the normal `PreToolUse` gate (P3). Frontmatter must validate. No silent failures (P10).

## Human UX (single-operator agentic)

- **Human pauses:** drops files into `ops/raw/`, invokes `/compile`.
- **Agent continues:** reads raw, decomposes, builds MOC, weaves defensible links, emits orphan report.
- **Human pauses again:** reviews seed notes + `compile-report.md`. Because all produced notes are `status: seed`, the slice is reversible — the operator can delete, refine, or rerun.

## Deterministic replay harness

A bash helper `bin/vault-compile-replay <vault-root>` implements a rule-based heading-split replay of this command. It is NOT a replacement for the agent; it exists so `tests/test_compile_slice.sh` can prove the shape of the output on a fresh clone with no LLM available. The agent invocation of `/compile` may produce richer (better-titled, better-linked) output than the deterministic replayer. Both MUST satisfy the contract above.

## Failure modes (fail loud)

- `ops/raw/` missing → error, exit 1, don't touch `notes/`.
- Raw file produces zero sections → warn, skip file, increment report `skipped=`.
- Proposed note title does not satisfy P2 → fail loud, do not write.
- Any proposed wiki-link would dangle → fail loud (P4), drop the link, log in report.

## Steering moments

- Pause to human if raw source size exceeds ~200 sections in one invocation (cognitive-load cliff; Miller 1956, Sweller 1988) — propose batching.
- Pause to human if `orphan_count > notes_created / 2` — the raw corpus likely has no defensible internal structure yet; ask before spamming the vault.

## Out of scope for this command

- Semantic retrieval / Q&A (that is `/query` or `/ask-the-wiki`, not `/compile`).
- PDF or web ingest (those are upstream skills that land raw markdown into `ops/raw/`).
- Multi-format rendering (downstream of compile).

## Cognitive-science grounding

- P1 Atomicity: one-claim-per-note maximizes retrieval precision; ambiguous wiki-links erode graph utility (Miller 1956, Sweller 1988).
- P5 MOC reachability ≤ 3 hops: shallow reachability preserves recall paths (Collins & Loftus 1975).
- P6 three-space separation: raw metabolizes in `ops/`, compiled knowledge lives in `notes/` — crossing spaces is F3 contamination (Tulving 1985; Conway 2005).
