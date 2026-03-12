# Research Pipeline

The 7-phase pipeline for seeding a vault with deep research. Each phase produces specific artifacts and has clear completion criteria.

## Phase 1: Decomposition

**Input**: A research topic (e.g., "transformer architectures in NLP")
**Output**: Conceptual decomposition tree with 5-8 subtopics

**Process**:
1. Identify the topic's core concept
2. Ask: "What are the essential sub-concepts someone needs to understand this topic?"
3. Organize into a tree:
   - **Foundational concepts** (prerequisites, building blocks)
   - **Core mechanisms** (how it works, key processes)
   - **Applications/manifestations** (where it shows up, use cases)
   - **Critiques/limitations** (known problems, open questions)
   - **Frontier/emerging** (latest developments, future directions)
4. Present decomposition to user for approval before proceeding

**Quality check**: Each subtopic should be specific enough to research but broad enough to generate 3-10 atomic notes.

## Phase 2: Source Discovery

**Input**: Approved subtopic list
**Output**: Annotated source list (5-15 sources per subtopic)

**Process**:
1. For each subtopic, search for:
   - Foundational papers/articles (the canonical works)
   - Recent developments (last 2-3 years)
   - Authoritative overviews (textbooks, review articles)
   - Contrarian/critical perspectives
2. Evaluate source quality:
   - Peer-reviewed > preprint > blog post > social media
   - Primary source > secondary source > tertiary source
   - Recent + cited > recent + uncited > old + highly cited
3. Select 3-5 best sources per subtopic for deep reading

**Quality check**: At least one foundational source and one recent source per subtopic.

## Phase 3: Deep Reading

**Input**: Selected sources
**Output**: Extracted claims, evidence, and key arguments

**Process**:
1. For each source, extract:
   - **Core thesis**: What is the main argument or finding?
   - **Key claims**: 3-5 specific claims with supporting evidence
   - **Methodology**: How did they arrive at these claims? (if applicable)
   - **Implications**: What does this mean for the broader field?
   - **Limitations**: What are the acknowledged weaknesses?
2. Note cross-references between sources (who cites whom, who disagrees with whom)
3. Identify concepts that appear across multiple sources (these become priority atomic notes)

**Quality check**: Every extracted claim should be attributable to a specific source.

## Phase 4: Atomic Synthesis

**Input**: Extracted claims and concepts
**Output**: Draft atomic notes (one per key concept)

**Process**:
1. For each key concept identified during deep reading:
   - Create an atomic note following the vault's template schema
   - Title = concept name (noun phrase, not a sentence)
   - Body = clear explanation in the vault's voice
   - Include the core insight as a one-liner
   - Mark `status: seed`
   - Set `confidence:` based on source strength
2. Apply the atomicity test: "Can I state this note's idea in one sentence?"
   - If no → split into multiple notes
   - If yes → proceed
3. Target counts by seed type:
   - Survey: 20-30 atomic notes
   - Deep: 40-60 atomic notes
   - Bridge: 15-25 atomic notes
   - Frontier: 10-20 atomic notes

**Quality check**: Every note passes the atomicity test and has complete YAML frontmatter.

## Phase 5: MOC Construction

**Input**: Draft atomic notes
**Output**: Topic MOCs + domain MOC updates

**Process**:
1. Group atomic notes by subtopic
2. For each subtopic with >3 notes, create a topic MOC:
   - Title: `_MOC-[Subtopic].md`
   - Organize notes by conceptual relationship (not alphabetically)
   - Include 1-sentence description for each linked note
   - Add "Open Questions" section
3. Create or update the domain MOC:
   - Link all topic MOCs
   - Provide domain-level overview
4. Update `_MOC-Master.md` to link to new/updated domain MOC

**Quality check**: Every atomic note is reachable from a MOC within 3 hops.

## Phase 6: Source Documentation

**Input**: Sources used during deep reading
**Output**: Source notes for key references

**Process**:
1. For each significant source (not every minor reference), create a source note:
   - Full citation metadata
   - Summary of core argument
   - Key claims extracted (linking to the atomic notes they informed)
   - Relevance to the vault's domain
2. Link source notes from the atomic notes they support (`sources:` frontmatter field)

**Quality check**: Every atomic note that makes a claim references at least one source note.

## Phase 7: Connection Weaving

**Input**: All generated notes (atomic, MOC, source)
**Output**: Fully connected knowledge graph

**Process**:
1. For each atomic note, find connections:
   - Scan all other new notes for conceptual overlap
   - Check existing vault notes for connections
   - Add wiki-links in body text where contextually appropriate
   - Update `connections:` frontmatter
2. Ensure minimum connectivity:
   - Every note has ≥2 outgoing wiki-links
   - No orphan notes (0 incoming links)
   - At least 3 cross-subtopic connections (bridge links)
3. Identify and annotate bridge concepts:
   - Notes that connect different subtopics are high-value hubs
   - Consider creating reflection notes for significant cross-domain insights

**Quality check**: Zero orphan notes. Average ≥3 connections per note. At least 3 cross-subtopic bridges.

## Completion Report

After all phases, generate a seeding report:
```
SEED REPORT: [Topic]
════════════════════
Duration: [time]
Sources consulted: [N]

Notes created:
  Atomic notes:   [N]
  MOCs:           [N]
  Source notes:    [N]
  Reflections:    [N]
  Total:          [N]

Connectivity:
  Total wiki-links:     [N]
  Avg links per note:   [N]
  Orphan notes:         [N] (should be 0)
  Cross-subtopic links: [N]

Status distribution:
  Seed:      [N] (100% — all new notes start as seeds)

Suggested follow-ups:
  - [Topic that emerged as needing deeper investigation]
  - [Cross-domain connection to explore]
  - [Open question worth dedicated research]
```

Save report to `ops/sessions/seed-[topic]-[date].md`.
