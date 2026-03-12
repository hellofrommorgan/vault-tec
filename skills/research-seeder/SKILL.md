---
name: research-seeder
description: >
  Deep research and vault seeding engine. Use when the user asks to
  "seed a vault", "research a topic", "populate my vault", "generate notes",
  "do a deep dive into", "fill my vault with research on", "create a research
  job", or needs to automatically generate atomic notes, MOCs, and source notes
  from web research on a topic. Also triggers on "seed", "populate", and
  "research job" in vault-tec context.
version: 0.7.0
---

# Research Seeder

Engine for conducting deep research on a topic and seeding an Obsidian vault with properly structured, interconnected knowledge notes. This is NOT a surface-level dump — it's a multi-phase research operation that produces atomic notes, MOCs, source notes, and a rich connection graph.

## Seeding Philosophy

A seed job is a **generative research act**, not a copy-paste operation. The goal is to:
1. Decompose a topic into its conceptual structure
2. Research each concept to appropriate depth
3. Synthesize findings into atomic notes that follow the vault's schema
4. Connect notes into a navigable knowledge graph
5. Create MOCs that make the new knowledge discoverable

Every generated note should feel like it was written by a knowledgeable person thinking carefully, not by an AI dumping bullet points.

## Research Pipeline

Read `references/research-pipeline.md` for the full 7-phase pipeline:
1. **Decomposition** — Break topic into 5-8 conceptual subtopics
2. **Source Discovery** — Find authoritative sources for each subtopic
3. **Deep Reading** — Extract key claims, evidence, and arguments
4. **Atomic Synthesis** — Create one atomic note per key concept
5. **MOC Construction** — Build navigation structure
6. **Source Documentation** — Create source notes for key references
7. **Connection Weaving** — Link everything together, ensure no orphans

## Error Handling (v0.7.0)

Each phase can fail. Handle gracefully:

### Phase 1 (Decomposition) Failures
- **Topic too broad**: If decomposition yields >12 subtopics, ask user to narrow scope or split into multiple seed jobs.
- **Topic too narrow**: If <3 subtopics emerge, suggest broadening or embedding as a sub-seed within a larger topic.

### Phase 2 (Source Discovery) Failures
- **WebSearch fails**: Fall back to knowledge-base synthesis. Clearly mark notes as "synthesized from training data, not verified against current sources." Set confidence: low.
- **WebFetch blocked**: Use page titles and snippets from search results. Note reduced source depth in seed report.
- **Insufficient sources**: If <2 sources found for a subtopic, flag it. Options: skip subtopic, synthesize from adjacent knowledge, or ask user for sources.

### Phase 3 (Deep Reading) Failures
- **Content too dense**: If a single source yields >20 potential notes, chunk the reading into sections. Process each section separately.
- **Contradictory sources**: Create a tension note documenting the contradiction. Link both sources. Don't silently pick one side.
- **Paywalled content**: Note the paywall in the source note. Use available abstracts/summaries. Set confidence: low for claims derived from partial access.

### Phase 4 (Atomic Synthesis) Failures
- **Overproduction**: If synthesis produces >80 notes for a single seed job, pause and triage. Not every extracted claim deserves a note. Apply the "would someone search for this?" test.
- **Underproduction**: If <10 notes from a deep seed, the reading was too shallow. Return to Phase 3.
- **Title validation failure**: Every title must pass the composability test (see below). Reject and rephrase titles that fail.

### Phase 5-7 Failures
- **MOC construction with no clear clusters**: Force a flat MOC listing all notes. Flag for future reorganization.
- **Connection weaving produces orphans**: Run a second pass specifically targeting orphans. If still orphaned after 2 passes, link to the domain MOC directly.
- **Cross-subtopic connections sparse**: Explicitly search for bridge concepts. Create reflection notes for cross-cutting themes.

## Parallel Research Merge Strategy (v0.7.0)

For large seed jobs using parallel Task subagents:

### Partitioning
- Assign each subtopic to one subagent
- Each subagent follows the full pipeline (Phases 1-4) for its subtopic
- Subagents share: vault schema, identity.md voice, existing notes list
- Subagents don't share: intermediate work, partial notes

### Merge Protocol
After all subagents complete:
1. **Dedup check**: Find notes with >80% title overlap across subagents. Merge duplicates, keeping the richer version.
2. **Schema validation**: Ensure all notes from all subagents follow the same schema version.
3. **Connection weaving**: Run Phase 7 across ALL notes (not just within each subtopic). This is where cross-subtopic bridges emerge.
4. **MOC integration**: Build the topic MOC from all subtopics. Check hierarchy makes sense.
5. **Conflict resolution**: If two subagents produced contradictory notes on the same concept, create a tension note.

### Subagent Instructions Template
```
You are seeding the subtopic "[SUBTOPIC]" within the broader topic "[TOPIC]" for vault "[VAULT_NAME]".

Voice: Read self/identity.md for personality and tone.
Schema: Follow templates in templates/ exactly.
Quality: Every note must have >=2 wiki-links, complete YAML, composable title.
Domain: [DOMAIN]
Status: All new notes start as seed.

Existing notes in this vault (do NOT duplicate):
[LIST OF EXISTING NOTE TITLES]

Produce: atomic notes, source notes, and a subtopic MOC draft.
Do NOT produce the domain MOC or master MOC (those are handled in the merge phase).
```

## Quality Gates Between Phases (v0.7.0)

Each phase must pass its gate before the next phase starts:

| Phase | Gate | Pass Condition |
|-------|------|---------------|
| 1. Decomposition | Scope check | 3-12 subtopics, user-approved |
| 2. Source Discovery | Coverage check | >=2 sources per subtopic, >=1 primary source |
| 3. Deep Reading | Extraction check | >=3 claims per subtopic, all attributable |
| 4. Atomic Synthesis | Schema + atomicity check | All notes pass schema validation, all titles composable |
| 5. MOC Construction | Reachability check | Every note reachable from a MOC in <=3 hops |
| 6. Source Documentation | Attribution check | Every claim-bearing note has >=1 source reference |
| 7. Connection Weaving | Connectivity check | 0 orphans, avg >=3 connections/note, >=3 cross-subtopic bridges |

If a gate fails: fix the issue before proceeding. Do not skip gates.

## Title Validation Rules (v0.7.0)

Every note title (the H1 heading) must be a **composable noun phrase** — it should work as a sentence fragment when linked.

### Composability Test
A title passes if:
- It does NOT start with a verb (bad: "Understanding Memory", good: "Memory Encoding Mechanisms")
- It does NOT end with a question mark (bad: "How Does Memory Work?", good: "Memory Encoding Mechanisms")
- It is 3-10 words long
- It works in the sentence: "The concept of [[TITLE]] relates to..." 
- It works as a wiki-link mid-sentence: "...because [[TITLE]] suggests that..."

### Common Title Patterns
- **Good**: "Working Memory Capacity Limits", "Spreading Activation in Semantic Networks", "Schema Theory of Reading Comprehension"
- **Bad**: "How Memory Works" (sentence), "Memory" (too vague), "A Comprehensive Overview of Schema Theory and Its Applications" (too long), "understanding schemas" (starts with verb)

### Auto-Fix Suggestions
When a title fails composability:
- Verb-initial → nominalize: "Understanding X" → "X Comprehension" or "Mechanisms of X"
- Question → declarative noun phrase: "How Does X Work?" → "X Operating Mechanisms"
- Too vague → add specificity: "Memory" → "Working Memory Capacity Limits"
- Too long → extract core concept: "A Comprehensive..." → keep the 3-5 word core

## Domain Presets

Read `references/domain-presets.md` for domain-specific research strategies:
- **Technical/Engineering** — Focus on implementations, architectures, trade-offs
- **Scientific/Research** — Focus on hypotheses, evidence, methodology, replication
- **Philosophical/Theoretical** — Focus on arguments, objections, genealogy of ideas
- **Creative/Artistic** — Focus on techniques, influences, movements, exemplars
- **Professional/Business** — Focus on frameworks, case studies, best practices

## Seed Templates

Read `references/seed-templates.md` for pre-built seed job configurations:
- **Survey Seed** — Broad coverage, shallow depth (20-30 notes)
- **Deep Seed** — Narrow focus, deep analysis (40-60 notes)
- **Bridge Seed** — Cross-domain exploration (15-25 notes connecting two domains)
- **Frontier Seed** — Cutting-edge/emerging area (10-20 notes on latest developments)

## Quality Standards

Every seeded note must:
- Have complete, valid YAML frontmatter matching its type template
- Contain exactly one atomic idea (for atomic-note type)
- Have at least 2 wiki-link connections
- Have a composable noun-phrase title (v0.7.0)
- Attribute sources properly
- Be written in the vault's voice/personality (read self/identity.md)
- Be reachable from a MOC within 3 hops

## Parallel Research

For large seed jobs, use the Task tool to launch parallel research subagents:
- Each subtopic can be researched independently
- Subagents should follow the same pipeline and quality standards
- After parallel research completes, run the Merge Protocol (v0.7.0)
- A final connection-weaving pass is needed to link across subtopics
