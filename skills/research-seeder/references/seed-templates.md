# Seed Templates

Pre-configured seed job specifications for common research patterns. Each template defines scope, depth, target note counts, and specific phase adjustments.

## Survey Seed

**Purpose**: Broad coverage of a topic area — understand the landscape
**Target notes**: 20-30 atomic + 3-5 MOCs + 5-10 source notes = 28-45 total
**Depth**: Shallow-to-moderate per concept, wide coverage
**Time estimate**: 1-2 research sessions

**Decomposition**: Cast a wide net — 6-8 subtopics covering the full breadth
**Source strategy**: 2-3 sources per subtopic, prioritize overview/survey sources
**Atomic note focus**: Definitional notes, key-concept summaries, relationship notes
**MOC structure**: One domain MOC + one topic MOC per major area

**When to use**:
- Starting a new domain from scratch
- Getting oriented in an unfamiliar field
- Building a foundation before deep dives

**Completion criteria**:
- Someone could read just the MOCs and understand the topic's landscape
- Key terminology is defined in atomic notes
- Major subtopics are identified and sketched, even if not deeply explored

## Deep Seed

**Purpose**: Comprehensive analysis of a focused topic
**Target notes**: 40-60 atomic + 5-8 MOCs + 10-15 source notes + 3-5 reflections = 58-88 total
**Depth**: Deep per concept, narrower coverage
**Time estimate**: 2-4 research sessions

**Decomposition**: Go deep — 5-6 subtopics, each decomposed into sub-subtopics
**Source strategy**: 4-6 sources per subtopic, including primary/foundational + recent
**Atomic note focus**: Mechanism explanations, evidence summaries, argument reconstructions, comparisons
**MOC structure**: Hierarchical — domain MOC → topic MOCs → sub-topic MOCs

**When to use**:
- Building expertise in a specific area
- Preparing for a research project or presentation
- Understanding a complex system or theory in depth

**Completion criteria**:
- Notes cover not just what, but why and how
- Counter-arguments and limitations are documented
- Source attribution is thorough
- Cross-concept connections reveal non-obvious relationships

## Bridge Seed

**Purpose**: Explore connections between two domains
**Target notes**: 15-25 atomic + 2-3 MOCs + 5-8 source notes + 3-5 reflections = 25-41 total
**Depth**: Moderate, focused on intersection points
**Time estimate**: 1-2 research sessions

**Decomposition**: Start from each domain's core concepts, identify overlap zones
**Source strategy**: Prioritize cross-disciplinary publications, look for researchers working at the intersection
**Atomic note focus**: Bridge concepts, vocabulary translations, synthesis insights
**MOC structure**: One bridge MOC connecting to both domain MOCs

**When to use**:
- Exploring interdisciplinary connections
- Finding novel insights by combining fields
- Building cross-domain fluency

**Completion criteria**:
- At least 5 bridge concepts identified and documented
- Vocabulary differences between domains are mapped
- Synthesis reflections capture non-obvious insights
- Both domain MOCs link to shared bridge concepts

## Frontier Seed

**Purpose**: Map the cutting edge of a rapidly evolving area
**Target notes**: 10-20 atomic + 1-2 MOCs + 5-10 source notes = 16-32 total
**Depth**: Variable — deep on latest developments, sketchy on established context
**Time estimate**: 1 research session

**Decomposition**: Focus on what's new — 3-5 subtopics around recent developments
**Source strategy**: Prioritize very recent sources (last 1-2 years), preprints, conference papers, industry announcements
**Atomic note focus**: New developments, emerging patterns, open questions, predictions
**MOC structure**: Single frontier MOC, linking back to established notes where they exist

**When to use**:
- Tracking a fast-moving field
- Updating an existing domain with recent developments
- Exploring emerging areas before they stabilize

**Completion criteria**:
- Latest significant developments are documented
- Open questions and unresolved debates are captured
- Connection to existing foundational notes (if they exist)
- Explicit confidence/certainty markers on all notes (frontier knowledge is inherently uncertain)

## Custom Seed

For seed jobs that don't fit a preset, specify:
```yaml
seed_type: custom
topic: "[topic]"
subtopic_count: [3-10]
depth: shallow | moderate | deep
target_atomic_notes: [number]
target_mocs: [number]
domain_preset: [technical | scientific | philosophical | creative | professional | interdisciplinary]
special_instructions: "[any specific requirements]"
```
