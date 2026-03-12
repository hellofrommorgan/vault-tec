---
description: Interactive tutorial and help for vault-tec
allowed-tools: Read, Grep, Glob
argument-hint: [optional: topic]
---

Provide interactive guidance, tutorials, and help for vault-tec. This merges the tutorial and help functions from arscontexta.

## If no arguments provided — show overview:

```
VAULT-TEC — Obsidian Vault Forge
═════════════════════════════════

COMMANDS:
  /vault-tec:setup [vault-path]          — Interactive onboarding & config
  /vault-tec:create-vault [name] [path]  — Create a new vault
  /vault-tec:seed [topic] [vault-path]   — Seed with deep research
  /vault-tec:health [vault-path]         — Run diagnostics
  /vault-tec:ask [question]              — Query methodology
  /vault-tec:evolve [vault-path]         — Architecture evolution
  /vault-tec:guide [topic]               — This help screen

SKILLS (auto-triggered):
  vault-architect    — Vault structure and generation knowledge
  research-seeder    — Deep research and note generation
  vault-methodology  — 83 research claims backing every decision
  vault-health       — Diagnostics and quality enforcement
  vault-evolution    — Architecture evolution patterns

AGENT:
  knowledge-guide    — Proactive guidance during vault work

QUICK START:
  1. /vault-tec:setup                       (configure vault-tec)
  2. /vault-tec:create-vault MyResearch ~/   (build the vault)
  3. /vault-tec:seed "quantum computing" ~/MyResearch
  4. /vault-tec:health ~/MyResearch

Type /vault-tec:guide [topic] for deep dives on any concept.
```

## If topic provided — interactive tutorial:

Read the topic from `$ARGUMENTS` and provide an experiential tutorial. Available topics:

### Core Concepts
- **three-spaces** — self/, notes/, ops/ and why separation matters
- **atomic-notes** — the single-idea principle and why it works
- **mocs** — Maps of Content as navigational hubs
- **wiki-links** — spreading activation and connection theory
- **6r-pipeline** — Record, Reduce, Reflect, Reweave, Verify, Rethink
- **kernel** — the 15 kernel primitives and what they enforce
- **schema** — YAML frontmatter and why structured metadata matters

### Workflows
- **seeding** — how research seeding works end-to-end
- **processing** — turning inbox captures into evergreen notes
- **evolution** — when and how to evolve vault architecture
- **maintenance** — keeping a vault healthy over time

### Philosophy
- **methodology** — the research backing behind vault-tec
- **derivation** — why we derive from conversation, not copy from templates
- **cognitive-load** — how vault structure reduces cognitive overhead

For each topic, load relevant reference files from the appropriate skill and present:
1. A clear explanation of the concept
2. The research backing (with citations)
3. A practical example using the user's own vault (if one exists)
4. Suggested hands-on exercise
5. Links to related topics
