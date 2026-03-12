# Note Templates

Complete YAML frontmatter schemas for all 7 note types. These templates are the single source of truth for note structure — every note in the vault must conform to its type's template.

## 1. Atomic Note

The fundamental unit of knowledge. One idea, fully explained, properly connected.

```yaml
---
type: atomic-note
domain: [primary domain]
created: [YYYY-MM-DD]
status: seed | growing | evergreen
connections:
  - "[[Related Concept A]]"
  - "[[Related Concept B]]"
sources:
  - "[[Source Note Reference]]"
tags: []
confidence: low | medium | high
---

# [Concept Name]

[Clear explanation of the single concept. 100-300 words.]

## Key Insight

[The core takeaway in 1-2 sentences.]

## Connections

- Related to [[Concept A]] because [reason]
- Builds on [[Concept B]] by [relationship]
- Contrasts with [[Concept C]] in [dimension]
```

### Worked Example (v0.7.0)

```yaml
---
type: atomic-note
domain: cognitive-science
created: 2026-01-15
status: growing
connections:
  - "[[Working Memory Capacity Limits]]"
  - "[[Levels of Processing Framework]]"
  - "[[Schema Theory of Reading Comprehension]]"
sources:
  - "[[Source — Craik and Lockhart 1972]]"
tags: [memory, encoding, depth]
confidence: high
---

# Depth of Processing Effect

Information processed at deeper semantic levels is retained longer and more accurately than information processed at shallow structural levels. "Deep" means attending to meaning, associations, and implications rather than surface features like font or sound. This effect emerged from studies comparing incidental learning conditions — subjects who judged words for meaning (deep) vs. rhyme (shallow) showed dramatically higher retention, even when surprise-tested with no expectation of recall. The effect persists across word lists, narratives, and complex domain knowledge.

## Key Insight

Encoding quality depends on the *type* of processing, not the *amount* of time spent. A moment of genuine understanding outlasts hours of rote repetition.

## Connections

- Extends [[Levels of Processing Framework]] by providing the empirical mechanism — it's not just a model, it's a measurable effect with effect sizes d=1.2 to d=2.1 across conditions
- Challenges assumptions in [[Working Memory Capacity Limits]] because depth can compensate for limited capacity through rich encoding
- Informs the design of [[Schema Theory of Reading Comprehension]] — schemas provide the deep structure that enables deep processing during comprehension
- Contradicts [[Spacing Effect]] on one dimension but complements it on another — depth and spacing are orthogonal benefits
```

### Validation Rules (v0.7.0)

| Rule | Check | Error Message |
|------|-------|---------------|
| **Title** | Must be composable noun phrase (3-10 words, no leading verb, no question mark) | "Title reads as a question or command — make it a claim" |
| **Body** | 100-300 words explaining exactly one idea | "Body is {actual} words — too short to explain, too long for atomicity" |
| **Connections** | ≥2 wiki-links in body text, each with explicit context phrase | "Found {N} connections — minimum 2 required, each must explain the relationship" |
| **Sources** | ≥1 source reference for any empirical claim | "Empirical claims require source citations" |
| **Confidence** | Must match source strength (high = peer-reviewed, medium = single study, low = theoretical) | "Confidence '{actual}' doesn't match source tier" |
| **Domain** | Must match one of vault's active domains | "Domain '{actual}' not in active domain list" |
| **Atomicity test** | "This note argues that [title]" must be a coherent sentence | "Title doesn't work as a prose claim when linked from other notes" |
| **Status** | One of: seed \| growing \| evergreen | "Status must indicate lifecycle stage" |

**Auto-fix suggestions**:
- Title too long? Convert to a claim: "Concept name and its definition" → "the definition of concept X"
- Body too short? Add the "why" and "when" — under what conditions does this apply?
- Missing connections? Search the vault for related concepts before writing


## 2. Map of Content (MOC)

Navigation hub that organizes notes by conceptual relationship.

```yaml
---
type: moc
domain: [domain]
created: [YYYY-MM-DD]
scope: master | domain | topic
parent_moc: "[[_MOC-Parent]]"
note_count: [number]
last_updated: [YYYY-MM-DD]
---

# [Topic/Domain] — Map of Content

[1-2 sentence overview of what this MOC covers.]

## Core Concepts
- [[Concept A]] — [brief description]
- [[Concept B]] — [brief description]

## Frameworks & Models
- [[Framework X]] — [brief description]

## Open Questions
- [Questions this domain hasn't resolved yet]

## Sub-MOCs
- [[_MOC-Subtopic]] — [scope]
```

### Worked Example (v0.7.0)

```yaml
---
type: moc
domain: cognitive-science
created: 2026-01-10
scope: topic
parent_moc: "[[_MOC-Cognitive-Science]]"
note_count: 8
last_updated: 2026-01-20
---

# Memory Encoding — Map of Content

How information gets into memory — the mechanisms, conditions, and strategies that determine encoding quality and retention curves.

## Core Concepts
- [[Depth of Processing Effect]] — deeper semantic processing creates stronger memories with better retention curves
- [[Encoding Specificity Principle]] — retrieval cues must match encoding context for optimal recall performance
- [[Generation Effect in Learning]] — self-generated information is better retained than passive reading (d ≈ 0.8)
- [[Transfer Appropriate Processing]] — encoding should match expected retrieval demands to avoid transfer failures

## Frameworks & Models
- [[Levels of Processing Framework]] — the foundational model explaining why deep encoding works (Craik & Lockhart 1972)
- [[Elaborative Encoding Strategies]] — systematic methods for deepening processing (imagery, linking, analogies)
- [[Schema Theory of Memory]] — how prior knowledge structures affect encoding and retrieval

## Open Questions
- Does depth of processing apply identically to procedural vs. declarative knowledge?
- How does the generation effect interact with distributed practice? Do they amplify or compete?
- Can encoding depth be reliably increased for boring mandatory material (compliance training, safety protocols)?
- What neurobiological markers distinguish deep from shallow encoding in real-time?

## Sub-MOCs
- [[_MOC-Encoding-Strategies]] — practical techniques derived from encoding research for learning design
- [[_MOC-Memory-Disorders]] — clinical applications when encoding fails systematically

## Related Domains
- Connects to [[_MOC-Retrieval]] via the encoding-retrieval interaction — encoding quality predicts what retrieval cues will work
- Informs [[_MOC-Learning-Science]] by explaining why certain instructional designs work better
- Feeds [[_MOC-Neuroscience]] with behavioral predictions that neuroscience can measure
```

### Validation Rules (v0.7.0)

| Rule | Check | Error Message |
|------|-------|---------------|
| **Scope** | One of: master \| domain \| topic | "Scope must be master, domain, or topic" |
| **parent_moc** | Required for domain and topic MOCs; master MOCs have no parent | "Domain/topic MOCs must specify parent_moc" |
| **note_count** | Must match actual count of linked notes ±1 | "note_count={actual} but {N} notes are linked — update or reconcile" |
| **Entries** | Each linked note must have a context phrase (not just a bare link) | "Notes at line {N} lack context descriptions" |
| **Size lower** | Warning if <3 notes | "MOC has only {N} notes — consider merging with parent or converting to atomic note" |
| **Size upper** | Warning if >35 notes | "MOC has {N} notes — approaching split threshold. Consider sub-MOCs" |
| **Size critical** | Error if >100 notes | "MOC exceeds 100 notes — MUST split into sub-MOCs immediately" |
| **Reachability** | Every note in vault's domain should be reachable from this MOC within 3 hops | "Orphan notes detected in this domain — add links or create sub-MOCs" |
| **Title format** | Should match "[Topic] — Map of Content" | "Title should indicate this is a MOC navigation hub" |

**Auto-fix suggestions**:
- Too small? Add related concepts from adjacent topics or mark for merging
- Too large? Extract 15-25 related notes into a sub-MOC and link it
- Missing context? Review each link and add 8-15 word description explaining why it belongs


## 3. Source Note

Documentation of an external source — article, paper, book, website.

```yaml
---
type: source-note
domain: [domain]
created: [YYYY-MM-DD]
source_type: article | paper | book | website | video | podcast
author: [author name]
year: [publication year]
url: [url if available]
title: [full title]
status: unread | reading | processed
key_claims: []
---

# [Source Title]

**Author**: [author] | **Year**: [year] | **Type**: [type]

## Summary
[2-3 sentence summary of the source's core argument]

## Key Claims
1. [Claim] — supports [[Atomic Note]]
2. [Claim] — challenges [[Another Note]]

## Relevance
[Why this source matters for this vault's domain]

## Quotes & Evidence
> [Notable quote with page/timestamp reference]
```

### Worked Example (v0.7.0)

```yaml
---
type: source-note
domain: cognitive-science
created: 2026-01-08
source_type: paper
author: Craik, Fergus & Lockhart, Robert S.
year: 1972
url: https://doi.org/10.1037/a0025958
title: "Levels of Processing: A Framework for Memory Research"
status: processed
key_claims: 
  - "Encoding quality depends on type of processing, not time"
  - "Semantic (deep) processing yields better retention than structural processing"
  - "Transfer appropriate processing — retrieval context should match encoding"
---

# Levels of Processing: A Framework for Memory Research

**Author**: Craik & Lockhart | **Year**: 1972 | **Type**: peer-reviewed paper

## Summary

This foundational paper challenges the prevailing "levels of processing" model of memory, proposing instead that memory performance depends on the *depth* and *nature* of processing operations performed on incoming information. Subjects who process words semantically (asking "does this word rhyme with dog?") show dramatically better retention than those processing structurally (asking "is this word in capitals?"), even when both groups spend equal time. The authors argue memory traces are a byproduct of perceptual and cognitive processing, not separate storage mechanisms.

## Key Claims

1. **Encoding quality is determined by processing type, not duration** — supports [[Depth of Processing Effect]] by providing the theoretical foundation; effect sizes d=1.2 to d=2.1 across incidental learning paradigms
2. **Semantic processing produces stronger, more retrievable traces** — challenges [[Working Memory Capacity Limits]] by showing capacity limitations can be overcome through encoding richness
3. **Transfer-appropriate processing principle** — the optimal encoding depends on future retrieval context; surfaces the critical interaction between encoding and retrieval
4. **Memory performance reflects cognitive operations, not fixed storage** — reframes [[Memory Architecture Models]] from structural (stores) to functional (processes)

## Relevance

This is the kernel paper for modern understanding of learning effectiveness. It explains why deep study works, why cramming fails, and why instructional design choices matter. It's cited 15,000+ times and remains the theoretical foundation for learning science, cognitive load theory, and educational psychology.

## Quotes & Evidence

> "The level of analysis which the subject applies to the material will determine the memory traces, and consequently, the retention of that information." (p. 405)

> "A short exposure to an item in a deeply encoded condition (semantic) produces better memory than a longer exposure in a shallowly encoded condition (structural)." (Figure 2 results)

## Connection to Vault

- Core source for [[Depth of Processing Effect]]
- Cited in [[Levels of Processing Framework]]
- Provides empirical foundation for [[elaborative encoding strategies]]
- Contradicted in one dimension by [[Automation Complacency]] research (Thengrane 2019) — deep processing can fail if automated
```

### Validation Rules (v0.7.0)

| Rule | Check | Error Message |
|------|-------|---------------|
| **author** | Required, non-empty string | "Author must be specified" |
| **year** | Required, valid 4-digit year (1900-2099) | "Year must be valid YYYY format" |
| **source_type** | One of: article \| paper \| book \| website \| video \| podcast | "source_type must be from enum" |
| **title** | Full title, ≥5 words, non-empty | "Title must be full source title (≥5 words)" |
| **status** | One of: unread \| reading \| processed | "Status must indicate reading stage" |
| **key_claims** | For processed sources: ≥3 claims; for unread: empty list | "Processed sources need ≥3 key_claims extracted" |
| **Bidirectional links** | Atomic notes citing this source should list it in connections | "This source is cited but not listed as source in citing notes" |
| **Summary quality** | 2-3 sentences capturing core argument | "Summary should be 2-3 sentences, not {actual}" |
| **Quotes** | ≥1 significant quote with page/timestamp | "Include at least 1 representative quote with location" |

**Auto-fix suggestions**:
- Status "unread"? Schedule reading and set reminder
- key_claims empty? Don't mark as processed — it's still reading status
- No quotes? Add 2-3 at key points before marking processed
- Missing connection? Search vault for notes about this claim and add bidirectional links


## 4. Reflection

Metacognitive note — thinking about thinking, connecting patterns across domains.

```yaml
---
type: reflection
domain: [domain or "cross-domain"]
created: [YYYY-MM-DD]
status: seed | growing | evergreen
trigger: [what prompted this reflection]
connections:
  - "[[Note that sparked insight]]"
tags: [meta, insight, pattern]
---

# [Reflection Title]

## Observation
[What pattern, connection, or insight emerged]

## Context
[What was happening when this insight arose]

## Implications
[What this means for understanding, for the vault, for future work]

## Action
[Any concrete next steps this reflection suggests]
```

### Worked Example (v0.7.0)

```yaml
---
type: reflection
domain: cross-domain
created: 2026-01-18
status: growing
trigger: "Noticed depth-of-processing research contradicts findings in automation complacency literature"
connections:
  - "[[Depth of Processing Effect]]"
  - "[[Automation Complacency]]"
  - "[[Transfer Appropriate Processing]]"
tags: [meta, contradiction, learning-design]
---

# Deep Processing Can Fail When Cognitive Demand is Automated Away

## Observation

The classical depth-of-processing effect (Craik & Lockhart 1972) is assumed to work universally — deeper semantic processing always produces better retention. But [[Automation Complacency]] research (Thengrane 2019, Parasuraman 2010) shows that when learners can offload cognitive demand to a tool or system, they disengage from the semantic processing that would normally produce depth. The contradiction isn't real — but the boundary condition is critical and often missed in learning design.

The pattern: learners facing high cognitive demand + low automation = deep processing + strong retention. But learners given easy access to answers/solutions = shallow processing despite high material complexity. The automation isn't the problem; the automatic route is.

## Context

This insight emerged when designing a learning intervention for compliance training. The traditional advice was "make learners think deeply about scenarios" (apply depth-of-processing research). But pilots showed that when scenarios had "easy out" options (templates, checklists, auto-complete), learners used them instead of struggling through semantic processing. They got the "right answer" but didn't retain the principle — and transferred poorly to novel situations.

The research isn't contradicted; it's revealed to depend on a boundary condition: willingness to engage with difficult processing. Systems that reduce difficulty can paradoxically reduce depth.

## Implications

1. **Learning design**: Don't just follow depth-of-processing recommendations in isolation. Pair them with [[Transfer Appropriate Processing]] and cognitive load principles — the goal is optimal challenge, not arbitrary depth
2. **Vault structure**: This is a case where two solid research streams (encoding quality + human factors) need explicit connection to avoid dead-end conclusions
3. **Tool design**: Systems designed to help learners can undermine the cognitive engagement that makes help useful. Tools that increase difficulty slightly (hint systems instead of answers) may be more effective than tools that remove difficulty entirely

## Action

- Add [[boundary condition]] note: "depth of processing requires willingness to engage difficulty — automation can undermine both"
- Create [[Design Pattern: Progressive Difficulty]] linking depth-of-processing to scaffolding research
- Add contraindication to [[elaborative encoding strategies]]: list scenarios where each fails (when automated, when disengaging)
- Search vault for other one-sided research claims that might have hidden boundary conditions
```

### Validation Rules (v0.7.0)

| Rule | Check | Error Message |
|------|-------|---------------|
| **trigger** | Required, non-empty — what prompted this? | "Trigger is missing — what sparked this reflection?" |
| **domain** | Can be "cross-domain" for reflections spanning multiple areas | "Domain must match active domains or be cross-domain" |
| **Connections** | ≥1 link to note(s) that sparked the reflection | "Must link to at least 1 source note that triggered this" |
| **Observation clarity** | 1-2 paragraphs describing the pattern/connection | "Observation should clearly state what pattern emerged" |
| **Action concreteness** | Should contain ≥1 concrete next step (even if "no action needed") | "Action section needs at least one specific, testable item" |
| **Status** | One of: seed \| growing \| evergreen | "Reflections should indicate their maturity stage" |

**Auto-fix suggestions**:
- Missing trigger? Go back and document what actually prompted this — without context it's orphaned
- Only abstract insights? Add concrete next step — "review X," "search for Y," "test hypothesis Z"
- Too vague? Rewrite observation as "I noticed [specific pattern] when [specific condition]"


## 5. Seed Task

A research seeding task in the ops/ task queue.

```yaml
---
type: seed-task
domain: [target domain]
created: [YYYY-MM-DD]
status: queued | in-progress | completed | blocked
priority: low | medium | high | critical
topic: [research topic]
subtopics: []
estimated_notes: [number]
actual_notes: [number, filled after completion]
---

# Seed: [Topic]

## Objective
[What this seeding job should produce]

## Scope
- Subtopics to cover: [list]
- Depth: survey | intermediate | deep
- Target note count: [number]

## Sources to Investigate
- [Source 1]
- [Source 2]

## Completion Criteria
- [ ] All subtopics covered
- [ ] MOC created for topic
- [ ] All notes connected (no orphans)
- [ ] Source notes created for key references
```

### Worked Example (v0.7.0)

```yaml
---
type: seed-task
domain: cognitive-science
created: 2026-01-12
status: in-progress
priority: high
topic: Memory Retrieval Mechanisms
subtopics:
  - "cue-dependent retrieval"
  - "encoding specificity principle"
  - "retrieval-induced forgetting"
  - "interference (proactive & retroactive)"
estimated_notes: 12
actual_notes: 8
---

# Seed: Memory Retrieval Mechanisms

## Objective

Build comprehensive coverage of how stored information is retrieved — the mechanisms, cues, failures, and conditions that determine successful recall. Target: 12 atomic notes organized into a coherent MOC that connects retrieval to encoding and distinguishes it from recognition.

Expected deliverables:
- 12 atomic notes on retrieval mechanisms
- 1 MOC organizing retrieval by mechanism type
- 3 source notes for foundational papers
- Full bidirectional linking to encoding notes
- 0 orphans

## Scope

### Subtopics to cover
1. **Cue-dependent retrieval** — how cues guide search through memory (encoding specificity)
2. **Encoding specificity principle** — match between encoding and retrieval contexts (Tulving 1983)
3. **Retrieval-induced forgetting** — how retrieving one item suppresses related items (Anderson 1994)
4. **Proactive interference** — old learning blocks new learning (Underwood 1957)
5. **Retroactive interference** — new learning damages old memory (Melton & Irwin 1940)
6. **Recognition vs. recall** — why recognition is easier (requires less retrieval search)
7. **Tip-of-the-tongue phenomenon** — partial retrieval states (Brown & McNeill 1966)
8. **Spaced retrieval practice** — why spacing beats massing (Ebbinghaus 1885, Rohrer & Taylor 2007)

### Depth
- **Deep** — include mechanistic detail, boundary conditions, neuroscience correlates
- Target note count: 12
- Expected coverage time: 20 hours research + writing

## Sources to Investigate

Primary:
- Tulving, E. (1983). Elements of Episodic Memory
- Anderson, M.C. (1994). Retrieval-induced forgetting
- Rohrer, D. & Taylor, K. (2007). The shuffling of mathematics problems improves learning

Secondary:
- Brown & McNeill (1966) tip-of-the-tongue
- Godden & Baddeley (1975) context-dependent memory
- Bjork & Bjork (1992) new theory of disuse

## Completion Criteria

- [x] Encoding specificity principle researched
- [x] Cue-dependent retrieval note created
- [ ] Retrieval-induced forgetting note (blocked — need Anderson 1994 full text)
- [ ] Interference mechanisms covered (both types)
- [ ] Recognition vs. recall written
- [x] MOC structure drafted
- [x] 8 source notes created
- [ ] Spaced retrieval practice note (in progress)
- [x] All created notes linked (8/8)
- [ ] Final review and orphan check

## Next Steps

- Locate Anderson 1994 full text (priority: critical)
- Complete spaced retrieval practice synthesis
- Add cross-links to [[_MOC-Memory-Encoding]] (related domain)
- Audit for orphans before closing task
```

### Validation Rules (v0.7.0)

| Rule | Check | Error Message |
|------|-------|---------------|
| **priority** | One of: low \| medium \| high \| critical | "Priority must be from enum" |
| **topic** | Required, non-empty, specific (not generic) | "Topic should be specific (not just 'memory')" |
| **estimated_notes** | Required, positive integer, ≥5 | "estimate_notes should be ≥5 for a seed task" |
| **Status transitions** | queued → in-progress → completed\|blocked (no skipping) | "Can't jump from queued directly to completed" |
| **Completion criteria** | At task end: actual_notes should equal or exceed 80% of estimate | "Completed task has {actual}/{estimated} notes" |
| **Domain** | Must match active vault domain | "Domain must be in active domains list" |
| **Criteria checklist** | All criteria marked [ ] or [x] at start; must all be [x] before closing | "Completion requires all criteria checked" |

**Auto-fix suggestions**:
- Blocked status? Update blocking issue and next_unblock date
- actual_notes >> estimated_notes? Great! Increase estimate on similar tasks
- actual_notes << estimated_notes? Review scope assumptions — was topic too broad?
- Status in-progress >2 weeks? Tag for status check, verify not stalled


## 6. Session Log

Captures what happened in a work session.

```yaml
---
type: session-log
created: [YYYY-MM-DD]
session_number: [N]
duration: [approximate time]
focus: [primary activity]
notes_created: [count]
notes_modified: [count]
---

# Session [YYYY-MM-DD]-[N]

## Focus
[What this session aimed to accomplish]

## Activity
[What actually happened]

## Notes Created
- [[New Note A]]
- [[New Note B]]

## Insights
[Any observations about the vault or process]

## Next Session
[What to pick up next time]
```

### Worked Example (v0.7.0)

```yaml
---
type: session-log
created: 2026-01-22
session_number: 47
duration: 180 minutes
focus: "Complete seeding task on retrieval mechanisms; audit encoding-retrieval connections"
notes_created: 4
notes_modified: 7
---

# Session 2026-01-22-47

## Focus

Complete the retrieval mechanisms seeding task (8 remaining notes) and verify bidirectional linking between encoding and retrieval domains. Audit for orphans and oversized MOCs.

## Activity

1. **Completed source investigation** (45 min)
   - Located Anderson 1994 full text, extracted key claims
   - Created [[Source Note — Anderson 1994 Retrieval-Induced Forgetting]]
   - Updated seed-task status: "blocked" → "in-progress"

2. **Wrote 4 core retrieval notes** (90 min)
   - [[Retrieval-Induced Forgetting]] — mechanism and boundary conditions
   - [[Proactive Interference]] — old memories blocking new encoding
   - [[Encoding Specificity Principle]] — why context match matters for retrieval
   - [[Spacing Effect]] — why distributed practice beats massing (Rohrer & Taylor data)

3. **Reweaving backward pass** (30 min)
   - Updated [[Depth of Processing Effect]] to link forward to [[Encoding Specificity Principle]]
   - Added "retrieval dimension" to [[Transfer Appropriate Processing]]
   - Found orphan: [[Recognition vs Recall]] created 3 sessions ago, still unlinked — added to [[_MOC-Memory-Retrieval]]
   - Discovered [[Spacing Effect]] mentioned in 6 notes but no central concept note — created and backlinked

4. **Organizational maintenance** (15 min)
   - [[_MOC-Memory-Encoding]] grown to 16 notes, [[_MOC-Memory-Retrieval]] now 14 notes — both healthy
   - Created sub-MOC [[_MOC-Interference-Mechanisms]] to cluster 4 related notes
   - Verified no dangling links in new notes

## Notes Created

- [[Retrieval-Induced Forgetting]]
- [[Proactive Interference]]
- [[Encoding Specificity Principle]]
- [[Spacing Effect]]

## Notes Modified

- [[Depth of Processing Effect]] — added retrieval context link
- [[Transfer Appropriate Processing]] — expanded to cover encoding-retrieval fit
- [[Working Memory Capacity Limits]] — clarified distinction from long-term retrieval
- [[_MOC-Memory-Retrieval]] — added 4 new notes, reformatted structure
- [[Source Note — Anderson 1994]] — new created
- [[Recognition vs Recall]] — orphan rescue, connected to MOC
- [[_MOC-Interference-Mechanisms]] — new sub-MOC created

## Insights

1. **Encoding-retrieval connection is critical but wasn't explicit** — the system had both but didn't name the relationship. Created [[Transfer Appropriate Processing]] as the bridge concept. This is probably true in other domains too — check for implicit relationships that deserve explicit concepts.

2. **Orphan timing reveals process gaps** — [[Recognition vs Recall]] was written 3 sessions ago but never connected. Author had it clear in head but didn't link during writing. Need faster feedback on incomplete linking. Consider adding hook to warn on notes >2 sessions old without connections.

3. **MOC size is self-indicating** — both memory MOCs are now at 14-16 notes, subdividing naturally into subtopics. No force needed; the notes wanted to cluster. System is working as designed.

4. **Spacing effect was multiply discovered** — appears in encoding (best practices), retrieval (cuing), interference (overcoming proactive), and learning science contexts. Created central note but may need to tag as "cross-domain synthesis" for semantic search.

## Next Session

1. Close seed-task: verify all completion criteria, update actual_notes count, run final orphan check
2. Investigate orphan patterns — are there timing or context patterns that predict which notes get missed?
3. Add "cross-domain" tag to concepts that naturally span multiple knowledge areas
4. Check if other domains have implicit connections like encoding-retrieval that deserve explicit bridging concepts
```

### Validation Rules (v0.7.0)

| Rule | Check | Error Message |
|------|-------|---------------|
| **session_number** | Required, positive integer, sequential | "Session number must be sequential from previous sessions" |
| **created** | YYYY-MM-DD format, should be today's date | "Created date should match session date" |
| **focus** | Required, non-empty, specific | "Focus should state what this session aimed to do" |
| **Notes Created** | All created notes must be linked with [[wiki links]] | "List all notes created as wiki links" |
| **Activity narrative** | Should describe what was done and why | "Activity should be a narrative, not just a checklist" |
| **Insights** | ≥1 observation about vault/process/learning | "What did you notice about how the system works?" |
| **Next Session** | ≥1 clear item (even if "continue current work") | "Leave a clear handoff for the next session" |
| **duration** | Approximate time in minutes, non-zero | "Track approximate session duration for metabolic rate" |

**Auto-fix suggestions**:
- Missing session_number? Make it sequential from last session
- Notes Created empty? Go back through vault edits and list all new notes
- No Insights? Think about what was surprising or what failed — that's the insight
- Vague Next Session? Convert to specific tasks: "review X," "complete Y," "test hypothesis Z"


## 7. Domain Entry

Initialization template for adding a new domain to the vault.

```yaml
---
type: domain-entry
domain: [new domain name]
created: [YYYY-MM-DD]
status: initializing | active | dormant
parent_domain: [optional, for sub-domains]
description: [1-sentence domain description]
key_questions: []
---

# Domain: [Name]

## Description
[What this knowledge domain covers and why it's in this vault]

## Key Questions
1. [Foundational question this domain seeks to answer]
2. [Another core question]

## Initial Seed Topics
- [Topic to seed first]
- [Related topic]

## Cross-Domain Connections
- Links to [[Other Domain]] via [shared concept]

## Resources
- [Key source or starting point]
```

### Worked Example (v0.7.0)

```yaml
---
type: domain-entry
domain: neuroscience-of-learning
created: 2026-01-20
status: initializing
parent_domain: cognitive-science
description: "How neural substrates implement the cognitive mechanisms (encoding, retrieval, interference) documented in cognitive-science domain"
key_questions:
  - "What neural mechanisms implement depth of processing and why does semantic processing activate broader networks?"
  - "How does spaced retrieval practice change neural circuit dynamics compared to massed practice?"
  - "What is the neural basis of retrieval-induced forgetting — inhibition vs. weakening vs. competition?"
  - "How do cognitive load and working memory capacity limits emerge from neural architecture?"
---

# Domain: Neuroscience of Learning

## Description

This domain maps cognitive learning mechanisms onto their neural substrates. We know from cognitive-science that encoding depth matters, spacing helps, and interference can block retrieval — but *how* do brains implement these effects? This domain closes the explanation gap by connecting behavioral principles (cognitive-science) to brain mechanisms (neuroscience). Focus: learning-relevant neuroscience only, not exhaustive neurobiology.

Why it's in this vault: Understanding the neural basis of learning principles helps us recognize when principles might fail (e.g., when neural resources are depleted) and suggests novel interventions. Neuroscience also provides predictions — if encoding is mechanism X, then blocking mechanism X should impair encoding.

## Key Questions

1. **What neural mechanisms implement depth of processing?** — Why does semantic processing (meaning) beat structural processing (sound/shape)? Is it network breadth (more activation), network stability (stronger consolidation), or some combination?

2. **How does spacing change neural learning dynamics?** — Massing produces rapid learning but fast forgetting. Spacing produces slow learning but strong retention. What's different in the neural learning curves?

3. **What is the neural basis of retrieval-induced forgetting?** — Anderson's work is behaviorally clear, but is RIF caused by active inhibition, by competition, or by retrieval-practice-induced weakening of related memories?

4. **How does working memory capacity emerge from neural architecture?** — Why can we hold ~7 items? Is it refractory periods, metabolic limits, or architectural constraints in prefrontal organization?

5. **Can neural metrics predict learning success before behavior shows it?** — If we could measure neural encoding quality (e.g., pattern stability, network breadth), could we predict retention before the retention test?

## Initial Seed Topics

- **Neurobiological basis of encoding depth** — fMRI correlates of semantic vs. structural processing
- **Spaced practice and neural consolidation** — how distributed practice changes synaptic strengthening and systems consolidation
- **Prefrontal organization and working memory** — why capacity is limited and how it emerges from neural architecture
- **Retrieval-induced forgetting mechanisms** — inhibitory control, competitive retrieval, memory reconsolidation
- **Neural markers of learning transfer** — can neural patterns measured during learning predict transfer success?

## Cross-Domain Connections

- **Links to [[_MOC-Cognitive-Science]]** via [[Depth of Processing Effect]] — cognitive effect that needs neural explanation
- **Links to [[_MOC-Memory-Encoding]]** via [[Transfer Appropriate Processing]] — encoding principles that likely have neural correlates
- **Links to [[_MOC-Learning-Science]]** via learning effectiveness — neuroscience should explain why some instructional methods work
- **Feeds [[_MOC-Educational-Neuroscience]]** (if it exists) — practical implications of learning neuroscience

## Resources

**Foundational texts:**
- Anderson, M.C. et al. (2016). "Learning to Control Mental Processes" — RIF and neural control mechanisms
- Xue, G. et al. (2010). "Superior Long-Term Performance on Spatial and Verbal Memory" — systems consolidation and spacing
- D'Esposito, M. & Postle, B.R. (2015). "The Cognitive Neuroscience of Working Memory" — authoritative review on neural WM substrate

**Key research lines to investigate:**
- fMRI studies of depth-of-processing effects (Kapur et al. 1994 onwards)
- Systems consolidation literature (Squire et al. 2015)
- Inhibitory control and RIF (Anderson's UCLA lab)
- Neural basis of transfer (Bransford et al., transferred to neuroscience)

## Status

**Initializing** — domain entry created, key questions defined, seed sources identified. Ready for seeding task. No atomic notes created yet.

**Next steps:**
1. Create seed-task: "Neuroscience of Learning — Depth of Processing Neural Basis" (priority: high, estimate: 8 notes)
2. Create seed-task: "Neuroscience of Learning — Spacing and Consolidation" (priority: medium, estimate: 8 notes)
3. Create [[_MOC-Neuroscience-Learning]] once initial notes exist
```

### Validation Rules (v0.7.0)

| Rule | Check | Error Message |
|------|-------|---------------|
| **description** | Required, ≥10 words, explains what domain covers | "Description should be 1-2 sentences, ≥10 words" |
| **status** | One of: initializing \| active \| dormant | "Status must indicate domain lifecycle stage" |
| **key_questions** | Required, ≥2 substantive questions | "List ≥2 foundational questions the domain seeks to answer" |
| **parent_domain** | Optional for sub-domains; None required for top-level | "Sub-domains must specify parent, top-level domains have no parent" |
| **Directory exists** | A matching directory must exist at notes/domains/[domain-name]/ | "Create directory before domain entry: mkdir notes/domains/[domain]/" |
| **MOC creation** | Once domain has ≥3 notes, MOC should exist | "Domain with atomic notes needs a _MOC- file" |
| **Seed topics** | ≥2 specific topics to seed | "List specific seed topics, not just "initial research"" |

**Auto-fix suggestions**:
- Status "initializing" >3 months? Change to "dormant" if no progress, or "active" if being worked
- No seed topics listed? Brainstorm 5-10 and rank by dependency order
- key_questions too vague? Reframe as "What is the neural basis of..." or "How does... differ from..."
- parent_domain missing for subtopic? Link to parent domain entry


---

## Template Maintenance

Templates are the single source of truth for note structure. When you:

1. **Create a note** — validate against the relevant template section
2. **Modify schema** — update the template first, then validate existing notes
3. **Add new note type** — create template section following the pattern (Worked Example, Validation Rules)
4. **Evolve a type** — keep old template format for backward compatibility, add new section above it

Never modify notes to match tool expectations. Modify tools to match note reality.
