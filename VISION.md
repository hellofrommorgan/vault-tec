# Vision

> Your knowledge, preserved for the future. The north star the agent reads to understand intent.

## What It Is

vault-tec is an opinionated Claude Code plugin that creates and manages **agent-native Obsidian knowledge vaults** — knowledge bases designed to be inhabited by an LLM, not just indexed by one. Every architectural decision traces back to cognitive science (Tulving 1985, Collins & Loftus 1975, Sweller 1988, Miller 1956) and is enforced in real time by hooks rather than left to discipline.

Today vault-tec ships **15 kernel primitives**, **83 research claims**, **11 commands**, **8 skills**, **11 hooks**, and **1 proactive knowledge-guide agent**. It establishes the three-space model (`self/` identity, `notes/` knowledge, `ops/` operations), generates a composable `CLAUDE.md` from conversation-derived config, and treats the vault as a **living cognitive substrate** — monitored by S.P.E.C.I.A.L., decontaminated by the Rad Counter, celebrated via Bobbleheads.

## Why It Matters

When LLMs are commodity, the differentiator is the **personal knowledge base you bring to them** — and most knowledge bases are filing cabinets built for human eyes, not cognitive architectures built for agent cohabitation. vault-tec's moat is **convention + methodology + real-time quality gates**: users bring the knowledge, and vault-tec builds the shelter it deserves, with write-time schema enforcement, referential-integrity checks, metabolic-rate monitoring, and a research-backed evolution playbook. The methodology is the product; the hooks make it non-negotiable.

## What It Is Not

- **Not a filing cabinet.** The vault is a cognitive runtime, not a document store.
- **Not a generic Obsidian starter.** Every primitive is opinionated and research-justified.
- **Not a framework to code against.** It's a plugin + methodology, not an SDK.
- **Not an end-to-end personal knowledge OS — yet.** See North Star.

## North Star

The Karpathy vision: a **personal knowledge OS** where user-authored raw material flows through an LLM compile loop into a living, queryable, multi-format wiki. The gaps between vault-tec-today and that future:

1. **`raw/` → wiki compile loop** — LLM-compile local corpora into atomic notes + maps
2. **Web Clipper + image pipeline** — browser capture and visual ingestion into `ops/inbox/`
3. **`/ask-the-wiki`** — Q&A over *user content*, not just the 83-claim methodology graph
4. **Multi-format renderers** — Marp decks, matplotlib viz, rendered MD, refiled into the vault
5. **CLI wiki search tool** — fast structured + semantic lookup outside Claude Code
6. **PDF / paper ingestion skill** — first-class academic source processing
7. **Dataset / repo ingestion** — pull structured corpora into vault-shaped knowledge

vault-tec already owns the **substrate** and the **quality layer**. The product mission is closing the end-to-end loop: **raw in → compiled wiki → queried, rendered, refiled.**

## Non-Goals

- Not trying to replace Obsidian's graph view — Obsidian remains the surface.
- Not building a sync service — users bring their own (iCloud, Syncthing, git).
- Not a multi-user or multi-tenant system — one Overseer per vault, by design.
- Not a RAG framework — retrieval rides on vault structure + light indexes, not a vector-DB stack.
- Not yet addressing fine-tuning or synthetic-data generation — Karpathy's final frontier is out of scope until the compile loop lands.
