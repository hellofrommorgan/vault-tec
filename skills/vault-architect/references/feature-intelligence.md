# Feature Block: Intelligence

**Merges**: semantic-search.md + methodology-knowledge.md
**Kernel Primitives**: (extends wiki-link, moc)
**Generates**: Intelligence section of CLAUDE.md

## Purpose

Define how the vault's knowledge is searched, matched, and leveraged — concept-level retrieval beyond keyword matching, and awareness of the methodology backing every architectural decision.

## Generated Content Pattern

```
## Intelligence

### Concept Matching
When searching the vault for relevant notes, use concept-level matching rather than exact keyword search:

**Search Strategy** (most specific → most general):
1. **Exact match**: Search for the exact term in note titles and frontmatter tags
2. **Synonym expansion**: Consider domain-specific synonyms and related terms
   - Example in {{DOMAIN}}: [domain-specific synonym pairs]
3. **Wiki-link traversal**: Follow links from matched notes to find conceptually adjacent ideas
4. **MOC scanning**: Check relevant MOCs for notes that might use different terminology
5. **Cross-domain bridging**: Look for the same concept expressed differently in other domains

**Vocabulary Awareness**: Different domains use different words for the same concept. When a user asks about a concept:
- Translate to domain-native terminology
- Check for the concept under its various names
- Note when the same idea appears in multiple domains under different names (these are valuable bridge concepts)

### Spreading Activation Parameters (v0.7.0)

When traversing the knowledge graph to find related concepts, use spreading activation with configurable parameters:

| Parameter | Default | Description |
|-----------|---------|-------------|
| DECAY_RATE | {{DECAY_RATE}} | Activation decreases by this factor per hop. Higher = faster decay = more focused results. |
| ACTIVATION_THRESHOLD | {{ACTIVATION_THRESHOLD}} | Minimum activation to include a note in results. Higher = fewer, more relevant results. |
| MAX_TRAVERSAL_DEPTH | {{MAX_TRAVERSAL_DEPTH}} | Maximum hops from source concept. Higher = broader search = more context consumed. |

**Task-dependent tuning**:
| Task | Decay | Threshold | Depth | Rationale |
|------|-------|-----------|-------|-----------|
| Specific fact lookup | 0.25 | 0.5 | 2 | Narrow, focused — find the exact note |
| Connection discovery | 0.10 | 0.2 | 4 | Broad, exploratory — find surprising links |
| Reweave candidate search | 0.15 | 0.3 | 3 | Balanced — find relevant but not obvious connections |
| Cross-domain bridging | 0.08 | 0.15 | 5 | Very broad — maximizes chance of cross-domain hit |

**Fan effect awareness** (Anderson, 1974): Notes with >15 outgoing links dilute activation. When a highly-connected hub is encountered during traversal, apply an additional dampening factor of `1 / log2(outgoing_links)` to prevent hub nodes from dominating results.

### Progressive Disclosure (v0.7.0)

Search results should be presented in layers, not as a flat list:

- **Layer 0** (always shown): Direct matches — notes whose title or description matches the query
- **Layer 1** (shown if <5 direct matches): One-hop neighbors — notes linked from direct matches
- **Layer 2** (shown on request): Two-hop neighbors — notes linked from Layer 1 results
- **Layer 3** (shown on explicit "go deeper"): Semantic matches — notes with similar descriptions but no direct links

Each layer adds context cost. Stop expanding when the answer is found.

### Methodology Awareness
This vault's architecture is grounded in cognitive science research. When making architectural decisions or answering questions about why the vault is structured a certain way, reference the backing methodology:

**Core Research Backing**:
- Atomic notes → Miller (1956) chunking, Kintsch (1988) propositions
- Wiki-links → Collins & Loftus (1975) spreading activation
- MOCs → Kintsch (1988) situation models
- 6R Pipeline → Craik & Lockhart (1972) levels of processing
- Three spaces → Tulving (1985) memory systems
- Session rhythm → Ebbinghaus (1885) spacing effect
- Status lifecycle → Bjork (1994) desirable difficulty
- Templates → Chi (2000) self-explanation effect
- Fan effect limit → Anderson (1974) retrieval interference
- Automation balance → Parasuraman & Manzey (2010) complacency

Use `/vault-tec:ask` to query the full methodology research graph for deeper answers.

### Retrieval Commands
- `/next` — Analyze current vault state and recommend the highest-value next action:
  - Unprocessed inbox items? → Suggest processing
  - Orphan notes? → Suggest connecting
  - Stale MOCs? → Suggest updating
  - Domain imbalance? → Suggest seeding underserved domain
  - Reweave debt? → Suggest backward maintenance
```

## Adaptation Variables

- `{{DOMAIN}}` — User's domain, for synonym examples
- `{{VOCABULARY_PAIRS}}` — Domain-specific synonym pairs to include
- `{{INCLUDE_METHODOLOGY}}` — Whether to include the research backing section (default: yes)
- `{{DECAY_RATE}}` — Spreading activation decay per hop (default: 0.15)
- `{{ACTIVATION_THRESHOLD}}` — Minimum activation to include in results (default: 0.3)
- `{{MAX_TRAVERSAL_DEPTH}}` — Maximum hops for concept search (default: 3)
