# Knowledge Architecture

Research on schema theory, categorization, hierarchical organization, and semantic networks. How knowledge should be structured for optimal retrieval and use.

## Schema and Categories

### Prototype Theory
**Citation**: Rosch (1975) — "Cognitive representations of semantic categories"
**Finding**: Categories are organized around prototypes (best examples), not strict boundaries. Category membership is graded, not binary.
**Implication**: Domain namespacing uses prototypical organization — a note belongs to its "best fit" domain. Cross-domain notes link to multiple domains but live in one.
**Kernel Primitive**: domain-namespace
**Confidence**: Strong

### Schema Theory and Assimilation
**Citation**: Piaget (1952) — "The origins of intelligence in children"
**Finding**: New information is assimilated into existing schemas or schemas accommodate (restructure) to fit new information. Learning is schema change.
**Implication**: Templates provide initial schemas. As the vault evolves, templates may need updating (accommodation). Evolution tracking monitors this schema change.
**Kernel Primitive**: template-system, evolution-tracking
**Confidence**: Strong

### Self-Explanation Effect
**Citation**: Chi et al. (2000) — "Self-explanations: How students study and use examples"
**Finding**: Students who explain material to themselves learn better than those who don't. Self-explanation forces deeper processing.
**Implication**: The template system with explicit fields (connections, key insight) forces self-explanation during note creation. You can't fill in "Key Insight" without explaining the concept to yourself.
**Kernel Primitive**: template-system
**Confidence**: Strong

### Basic-Level Categories
**Citation**: Rosch et al. (1976) — "Basic objects in natural categories"
**Finding**: There exists a "basic level" of categorization that maximizes information content while minimizing cognitive effort. Too abstract is useless; too specific is overwhelming.
**Implication**: Topic MOCs should target the basic level — specific enough to be useful, general enough to be manageable. Domain MOCs are superordinate; individual notes are subordinate.
**Kernel Primitive**: moc, domain-namespace
**Confidence**: Strong

## Semantic Networks

### Spreading Activation
**Citation**: Collins & Loftus (1975) — "A spreading activation theory of semantic processing"
**Finding**: When a concept is activated in a semantic network, activation spreads along the links to related concepts, making them more accessible.
**Implication**: Wiki-links ARE the semantic network. When you visit a note, its linked notes become "activated" — conceptually primed and easier to retrieve. Good links create useful activation patterns.
**Kernel Primitive**: wiki-link
**Confidence**: Strong

### ACT* Theory
**Citation**: Anderson (1983) — "The architecture of cognition"
**Finding**: Memory retrieval depends on the strength of association between concepts. Frequently co-activated concepts develop stronger links.
**Implication**: Notes that are frequently co-accessed should develop stronger explicit connections. Session logs can reveal which notes are accessed together (implicit link candidates).
**Kernel Primitive**: wiki-link
**Confidence**: Strong

### Network Topology and Knowledge
**Citation**: Steyvers & Tenenbaum (2005) — "The large-scale structure of semantic networks"
**Finding**: Semantic networks exhibit small-world properties — high clustering with short average path lengths. Hub nodes provide efficient navigation.
**Implication**: MOCs serve as hub nodes. A healthy vault should have small-world topology: most notes tightly clustered within topics, with MOC hubs providing short paths between clusters.
**Kernel Primitive**: moc, wiki-link
**Confidence**: Strong

### Semantic Distance
**Citation**: Rips et al. (1973) — "Semantic distance and the verification of semantic relations"
**Finding**: Conceptual similarity is a function of distance in a semantic network. Closer concepts in the network are verified as related faster.
**Implication**: Wiki-links should connect semantically proximate concepts. Long-distance links (connecting dissimilar concepts) are less common but high-value when they exist (bridge concepts).
**Kernel Primitive**: wiki-link
**Confidence**: Strong

## Hierarchical Organization

### Hierarchical Encoding and Retrieval
**Citation**: Bower et al. (1969) — "Hierarchical retrieval schemes"
**Finding**: Hierarchically organized information is recalled significantly better than the same information in random order.
**Implication**: The MOC hierarchy directly implements this. Master MOC → Domain MOC → Topic MOC → Atomic Note provides a hierarchical retrieval path.
**Kernel Primitive**: moc
**Confidence**: Strong

### Subsumption Theory
**Citation**: Ausubel (1963) — "The psychology of meaningful verbal learning"
**Finding**: New information is most effectively learned when it can be subsumed under (connected to) existing, more inclusive concepts. An "advance organizer" provides this inclusive concept.
**Implication**: MOCs serve as advance organizers. Reading a MOC before diving into individual notes provides the inclusive framework that makes the details meaningful.
**Kernel Primitive**: moc
**Confidence**: Strong

### Depth of Processing
**Citation**: Craik & Lockhart (1972) — "Levels of processing: A framework for memory research"
**Finding**: Information processed at deeper levels (semantic meaning) is retained longer than information processed at shallow levels (surface features).
**Implication**: Each step of the 6R pipeline forces deeper processing. Record = surface capture. Reduce = semantic extraction. Reflect = relational processing. Reweave = integrative processing.
**Kernel Primitive**: processing-pipeline
**Confidence**: Strong

## Knowledge Transfer

### Transfer-Appropriate Processing
**Citation**: Morris et al. (1977) — "Levels of processing versus transfer-appropriate processing"
**Finding**: Memory performance depends on the match between encoding operations and retrieval operations, not just depth of encoding.
**Implication**: If you'll retrieve knowledge by browsing MOCs, encode it with MOC context. If you'll search by keyword, include keywords. The schema system supports multiple retrieval routes.
**Kernel Primitive**: yaml-schema, moc
**Confidence**: Strong

### Analogical Transfer
**Citation**: Gentner (1983) — "Structure-mapping: A theoretical framework for analogy"
**Finding**: Analogy works by mapping structural relationships from one domain to another. Surface similarities are less important than structural parallels.
**Implication**: Cross-domain wiki-links should highlight structural parallels, not just surface similarities. Bridge concepts are structural analogies between domains.
**Kernel Primitive**: wiki-link, domain-namespace
**Confidence**: Moderate

### Situated Cognition
**Citation**: Brown et al. (1989) — "Situated cognition and the culture of learning"
**Finding**: Knowledge is fundamentally situated in the context of its use. Abstract, decontextualized knowledge transfers poorly.
**Implication**: Notes should include context of relevance (where this concept matters). Domain-specific personality keeps notes situated in their use context.
**Kernel Primitive**: personality, domain-namespace
**Confidence**: Moderate
