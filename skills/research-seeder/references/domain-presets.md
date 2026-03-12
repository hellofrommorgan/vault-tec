# Domain Presets

Domain-specific research strategies that adapt the seeding pipeline to different knowledge areas. Each preset adjusts decomposition patterns, source priorities, note structure emphasis, and connection strategies.

## Technical / Engineering

**Decomposition emphasis**: Architecture → Components → Interfaces → Trade-offs → Implementations
**Source priorities**: Documentation, RFCs, reference implementations, benchmark papers, post-mortems
**Note structure emphasis**: How-it-works explanations, comparison notes (X vs Y), architecture diagrams (described), code-adjacent concepts
**Connection strategy**: Builds-on chains, alternative-to links, requires links

**Seed adaptations**:
- Include "trade-off" notes that explicitly compare alternatives
- Include "pattern" notes for recurring architectural patterns
- Create implementation-focused MOCs alongside conceptual MOCs
- Tag notes with `maturity: theoretical | experimental | production`

## Scientific / Research

**Decomposition emphasis**: Theory → Hypotheses → Evidence → Methodology → Implications → Open Questions
**Source priorities**: Peer-reviewed papers, meta-analyses, replication studies, preprints (with caveats)
**Note structure emphasis**: Claim-evidence pairs, methodology notes, replication status, effect sizes
**Connection strategy**: Supports/contradicts links, replicates links, extends links

**Seed adaptations**:
- Include explicit "evidence strength" ratings (strong, moderate, weak, contested)
- Create "controversy" notes for actively debated claims
- Track replication status where available
- Include methodology notes explaining how key findings were produced
- Connect to broader theoretical frameworks

## Philosophical / Theoretical

**Decomposition emphasis**: Thesis → Arguments → Objections → Responses → Genealogy → Contemporary State
**Source priorities**: Primary texts, Stanford Encyclopedia of Philosophy, peer commentary, historical context
**Note structure emphasis**: Argument reconstruction, objection-response pairs, conceptual distinctions, thought experiments
**Connection strategy**: Argues-for/against links, responds-to links, influences links, distinction-from links

**Seed adaptations**:
- Include "argument" notes that reconstruct reasoning formally
- Include "distinction" notes that clarify conceptual boundaries
- Track intellectual genealogy (who influenced whom)
- Create "objection" notes as first-class concepts
- Connect to practical implications where they exist

## Creative / Artistic

**Decomposition emphasis**: Technique → History → Influences → Exemplars → Theory → Practice
**Source priorities**: Primary works, artist statements, critical analysis, historical surveys, technique guides
**Note structure emphasis**: Technique descriptions, influence maps, movement timelines, aesthetic principles
**Connection strategy**: Influenced-by links, technique-shared links, movement-member links, contrasts-with links

**Seed adaptations**:
- Include "exemplar" notes documenting specific works
- Include "technique" notes with practical application guidance
- Track influence networks between creators/movements
- Create timeline-aware MOCs showing historical development
- Connect technique to theory to practice

## Professional / Business

**Decomposition emphasis**: Framework → Application → Case Studies → Metrics → Best Practices → Anti-patterns
**Source priorities**: Industry reports, case studies, practitioner guides, academic business research, post-mortems
**Note structure emphasis**: Framework summaries, case study analyses, metric definitions, decision frameworks
**Connection strategy**: Applied-in links, measured-by links, alternative-to links, prerequisite links

**Seed adaptations**:
- Include "framework" notes with clear application steps
- Include "case study" notes with situation-action-result structure
- Create decision-tree MOCs for common decision points
- Tag notes with `applicability: startup | scale-up | enterprise | universal`
- Connect theory to practice via case study evidence

## Interdisciplinary / Cross-Domain

**Decomposition emphasis**: Bridge Concepts → Domain A Perspective → Domain B Perspective → Synthesis → Novel Implications
**Source priorities**: Cross-disciplinary publications, review articles, books bridging fields, conference proceedings
**Note structure emphasis**: Translation notes (same concept in different vocabularies), bridge concepts, synthesis notes
**Connection strategy**: Same-as links (across domains), translates-to links, synthesizes links

**Seed adaptations**:
- Prioritize "bridge concept" identification
- Create vocabulary translation notes (Domain A calls it X, Domain B calls it Y)
- Use cross-domain reflection notes for synthesis insights
- Explicitly tag cross-domain connections as high-value
- Create separate domain MOCs that link to shared bridge concepts
