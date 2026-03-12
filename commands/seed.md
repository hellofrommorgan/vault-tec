---
description: Seed a vault with deep research on a topic
allowed-tools: Read, Write, Edit, Bash(ls:*, tree:*, find:*), Grep, Glob, WebSearch, WebFetch, Task
argument-hint: [topic] [optional: vault-path]
---

Seed an existing vault with a deep research job on the given topic. This is a long-running, multi-phase operation that generates atomic notes, MOCs, source notes, and connections — not a surface-level dump.

## Pre-flight

1. Locate the vault: if `$2` is provided, use it. Otherwise, check if there's a vault in the current working directory (look for CLAUDE.md + self/ + notes/). If no vault found, ask.
2. Read the vault's `CLAUDE.md` to understand its schema, domain structure, and personality.
3. Read `self/identity.md` and `self/methodology.md` to align with the vault's voice.
4. Load the research-seeder skill from `${CLAUDE_PLUGIN_ROOT}/skills/research-seeder/SKILL.md`.

## Phase 1: Research Planning

Given the topic `$1`:
1. Break it into 5-8 subtopics using a conceptual decomposition (not just keyword splitting — think about the knowledge structure)
2. For each subtopic, identify:
   - Core concepts that need atomic notes
   - Key sources to investigate
   - Cross-domain connections to existing vault content
3. Present the research plan to the user for approval before proceeding

## Phase 2: Deep Research

For each subtopic, use WebSearch and WebFetch to gather information:
- Search for foundational concepts, recent developments, key figures
- Prioritize primary sources, peer-reviewed work, and authoritative references
- Track all sources with full citation metadata

Use the Task tool to launch parallel research subagents for independent subtopics when possible.

## Phase 3: Atomic Note Generation

For each key concept discovered during research, create an atomic note following the vault's template schema:

```yaml
---
type: atomic-note
domain: [derived from vault domains]
created: [today's date]
status: seed
connections: []
sources: []
tags: []
---
```

Rules for atomic notes:
- ONE idea per note — if it has two ideas, split it
- Title is the concept, not a sentence
- Body explains the concept in the vault's voice/personality
- Include at least 2 potential wiki-link connections using [[double brackets]]
- Include source attribution

## Phase 4: MOC Construction

After generating atomic notes, build Maps of Content:
1. Create a domain MOC in `notes/domains/[domain]/_MOC-[Domain].md`
2. Create topic MOCs for each major subtopic
3. Link topic MOCs back to domain MOC
4. Link domain MOC to `notes/_MOC-Master.md`
5. Each MOC should organize notes by conceptual relationship, not alphabetically

## Phase 5: Source Notes

For each significant source used, create a source note:
```yaml
---
type: source-note
domain: [domain]
created: [date]
source_type: [article|paper|book|website]
author: [author]
year: [year]
url: [url if available]
---
```

Include: key claims, relevance to the vault's domain, and which atomic notes reference this source.

## Phase 6: Connection Weaving

After all notes are created:
1. Re-read every new atomic note
2. Find connections between new notes (wiki-links)
3. Find connections between new notes and any existing vault notes
4. Update the `connections:` frontmatter field in every note
5. Ensure no orphan notes exist (every note has at least one incoming or outgoing link)

## Phase 7: Report

Present a seeding report:
- Total notes created (by type: atomic, MOC, source, reflection)
- Subtopics covered
- Connection density (avg links per note)
- Suggested follow-up seeds (gaps identified during research)
- Any notes flagged as `status: seed` that need human review

Update `ops/sessions/` with a session log of this seeding operation.
