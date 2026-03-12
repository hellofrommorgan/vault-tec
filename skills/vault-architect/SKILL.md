---
name: vault-architect
description: >
  Core architectural knowledge for Obsidian vault creation and generation.
  Use when the user asks to "create a vault", "set up a knowledge system",
  "design vault structure", "generate a CLAUDE.md", "configure obsidian",
  "set up three spaces", "define kernel primitives", or needs guidance on
  vault architecture, note schemas, MOC design, or template configuration.
  Also triggers on "vault-tec" references to vault structure.
version: 0.1.0
---

# Vault Architect

Core knowledge for creating agent-native Obsidian vaults. This skill contains the complete architectural specification derived from arscontexta's 15 kernel primitives and 8 consolidated feature generators.

## Architecture Overview

Every vault-tec vault follows a three-space architecture separating identity, knowledge, and operations into distinct growth-rate zones:

- **self/** — Identity space. Slow growth (tens of files over months). Contains: who the agent is, how it processes knowledge, what its goals are. Files here change rarely but matter enormously.
- **notes/** — Knowledge space. Steady growth (hundreds to thousands of notes). Contains: atomic notes organized by domain, connected via wiki-links, navigated via Maps of Content (MOCs).
- **ops/** — Operations space. High churn (daily). Contains: session logs, inbox captures, task queues, maintenance reports. Disposable — the system's working memory.

Read `references/three-spaces.md` for the full theory and cognitive grounding.

## The 15 Kernel Primitives

Every vault configuration decision maps to one of 15 kernel primitives, each grounded in cognitive science research. Read `references/kernel.md` for the complete kernel specification.

The primitives are:
1. **atomic-note** — One idea per note (Miller 1956, cognitive chunking)
2. **yaml-schema** — Structured frontmatter metadata (Sweller 1988, cognitive load)
3. **wiki-link** — Bidirectional connections via [[brackets]] (Collins & Loftus 1975, spreading activation)
4. **moc** — Maps of Content as navigational hubs (Kintsch 1988, situation models)
5. **domain-namespace** — DOMAIN:type naming convention (Rosch 1975, prototype theory)
6. **three-spaces** — self/notes/ops separation (Tulving 1985, memory systems)
7. **processing-pipeline** — 6R capture-to-integration cycle (Paivio 1986, dual coding)
8. **session-rhythm** — Capture→Process→Integrate phases (Ebbinghaus 1885, spacing)
9. **status-lifecycle** — seed→growing→evergreen progression (Bjork 1994, desirable difficulty)
10. **self-space** — Agent identity persistence (Newell 1990, unified theories of cognition)
11. **personality** — Domain-native documentation voice (Clark 1996, common ground)
12. **maintenance-hooks** — Automated quality enforcement (Norman 1988, error prevention)
13. **template-system** — Note type schemas as single source of truth (Chi 2000, self-explanation)
14. **ethical-guardrails** — Safe AI interaction boundaries (Reason 1990, Swiss cheese model)
15. **evolution-tracking** — Architectural change logging (Schön 1983, reflective practice)

## CLAUDE.md Generation

The CLAUDE.md is the system prompt that lives at the vault root. It is generated — not copied — by composing 8 feature blocks adapted to the user's domain and preferences. Read `references/generator-claude-md.md` for the master template.

### The 8 Feature Blocks (Minified from 14)

Each block is a self-contained module that generates a section of the CLAUDE.md:

1. **Structure** (`references/feature-structure.md`) — Schema, atomic notes, template system. Merged from: schema.md + atomic-notes.md + templates.md
2. **Navigation** (`references/feature-navigation.md`) — MOCs, wiki-links, graph analysis. Merged from: mocs.md + wiki-links.md + graph-analysis.md
3. **Processing** (`references/feature-processing.md`) — 6R pipeline, session rhythm. Merged from: processing-pipeline.md + session-rhythm.md
4. **Intelligence** (`references/feature-intelligence.md`) — Methodology knowledge, concept matching. Merged from: semantic-search.md + methodology-knowledge.md
5. **Personality** (`references/feature-personality.md`) — Domain-native voice, self-space. Merged from: personality.md + self-space.md
6. **Quality** (`references/feature-quality.md`) — Maintenance, guardrails, helper functions. Merged from: maintenance.md + ethical-guardrails.md + helper-functions.md
7. **Domains** (`references/feature-domains.md`) — Multi-domain management. From: multi-domain.md
8. **Runtime** (`references/feature-runtime.md`) — Identity tracking, metabolic rates, reconciliation loops, desired-state gap reports. Added in v0.7.0

## Vault Creation Protocol

When creating a vault, follow this sequence:
1. Discover user's domain, style, and scale through conversation
2. Map their needs to kernel primitives (not all 15 are always needed)
3. Create directory scaffold (three spaces + templates)
4. Generate CLAUDE.md by composing relevant feature blocks
5. Initialize self/ space with derived identity
6. Create master MOC and domain MOCs
7. Validate structure

## Note Templates

Read `references/note-templates.md` for the complete template library. Every note type has a YAML frontmatter schema that serves as the single source of truth for that note's structure. Templates are stored in the vault's `templates/` directory.
