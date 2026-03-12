# Cognitive Foundations

Research on memory systems, attention, cognitive load, and chunking. These claims form the bedrock justification for vault-tec's structural decisions.

## Memory Systems

### Tulving's Memory Systems Theory
**Citation**: Tulving (1985) — "How many memory systems are there?"
**Finding**: Human memory comprises distinct systems — episodic (events), semantic (facts), and procedural (skills) — with different encoding, storage, and retrieval characteristics.
**Implication**: The three-space architecture mirrors this: self/ ≈ episodic/autobiographical, notes/ ≈ semantic, ops/ ≈ procedural/working memory.
**Kernel Primitive**: three-spaces
**Confidence**: Strong

### Conway's Self-Memory System
**Citation**: Conway (2005) — "Memory and the self"
**Finding**: Autobiographical memory provides an organizational framework for all other memories. The self-concept structures how we encode and retrieve everything else.
**Implication**: The self/ space isn't optional — it's the organizational backbone. Without identity context, knowledge retrieval degrades.
**Kernel Primitive**: self-space
**Confidence**: Strong

### Working Memory Capacity
**Citation**: Cowan (2001) — "The magical number 4 in short-term memory"
**Finding**: Working memory is limited to approximately 4 chunks of information, not Miller's original 7±2.
**Implication**: MOCs should present ~4-7 major categories. Deeper hierarchy compensates for shallow capacity.
**Kernel Primitive**: moc
**Confidence**: Strong

### Episodic-Semantic Interaction
**Citation**: Tulving (2002) — "Episodic memory: From mind to brain"
**Finding**: Episodic and semantic memory interact — episodic experiences feed semantic knowledge, semantic knowledge shapes episodic encoding.
**Implication**: Session logs (episodic, ops/) naturally feed into atomic notes (semantic, notes/). The processing pipeline formalizes this transfer.
**Kernel Primitive**: processing-pipeline, three-spaces
**Confidence**: Strong

## Attention and Cognitive Load

### Cognitive Load Theory
**Citation**: Sweller (1988) — "Cognitive load during problem solving"
**Finding**: Learning is impaired when extraneous cognitive load is high. Reducing irrelevant processing demands frees capacity for learning.
**Implication**: YAML schema reduces cognitive load by making note structure predictable. Three-space separation reduces noise by keeping operations out of knowledge space.
**Kernel Primitive**: yaml-schema, three-spaces
**Confidence**: Strong

### Split Attention Effect
**Citation**: Chandler & Sweller (1992) — "The split-attention effect as a factor in the design of instruction"
**Finding**: When learners must mentally integrate information from multiple disparate sources, learning suffers.
**Implication**: Atomic notes should be self-contained. Wiki-links allow voluntary exploration without forcing integration. MOCs provide integrated views when needed.
**Kernel Primitive**: atomic-note, wiki-link
**Confidence**: Strong

### Attention Residue
**Citation**: Leroy (2009) — "Why is it so hard to do my work?"
**Finding**: When switching tasks, attention residue from the previous task impairs performance on the new one. Even brief interruptions create residue.
**Implication**: MOC hierarchy reduces context-switching by grouping related content. The session rhythm (capture→process→integrate) minimizes within-session switching.
**Kernel Primitive**: moc, session-rhythm
**Confidence**: Strong

### Selective Attention and Filtering
**Citation**: Broadbent (1958) — "Perception and Communication"
**Finding**: Humans filter information based on physical characteristics before semantic processing. Attention is a bottleneck.
**Implication**: Consistent schema and visual structure (YAML, MOC formatting) leverages pre-attentive filtering. Notes that look structurally familiar are processed faster.
**Kernel Primitive**: yaml-schema, template-system
**Confidence**: Strong

## Chunking and Organization

### Chunking
**Citation**: Miller (1956) — "The magical number seven, plus or minus two"
**Finding**: Working memory capacity is limited, but chunking (grouping items into meaningful units) increases effective capacity.
**Implication**: Atomic notes are chunks. MOCs are chunks-of-chunks. The hierarchy of atomics → topic MOCs → domain MOCs → master MOC is a chunking hierarchy.
**Kernel Primitive**: atomic-note, moc
**Confidence**: Strong

### Expert Chunking Patterns
**Citation**: Chase & Simon (1973) — "Perception in chess"
**Finding**: Experts perceive meaningful patterns (chunks) that novices see as individual pieces. Expert chunks are larger and more meaningful.
**Implication**: As a vault matures, notes cluster into recognizable patterns. MOCs codify these expert-level chunks. The vault literally develops expertise structure.
**Kernel Primitive**: moc, domain-namespace
**Confidence**: Strong

### Hierarchical Organization
**Citation**: Bower et al. (1969) — "Hierarchical retrieval schemes in recall of categorized word lists"
**Finding**: Hierarchically organized material is recalled 2-3x better than randomly organized material.
**Implication**: The MOC hierarchy (Master → Domain → Topic → Atomic) directly leverages hierarchical organization for retrieval.
**Kernel Primitive**: moc
**Confidence**: Strong

### Schema Theory
**Citation**: Bartlett (1932) — "Remembering: A study in experimental and social psychology"
**Finding**: Memory is reconstructive, guided by schemas (organized knowledge structures). New information is assimilated into existing schemas.
**Implication**: Templates provide schemas for note creation. Consistent structure aids both encoding (creating notes) and retrieval (finding them later).
**Kernel Primitive**: template-system
**Confidence**: Strong

## Encoding and Storage

### Generation Effect
**Citation**: Slamecka & Graf (1978) — "The generation effect"
**Finding**: Self-generated information is remembered better than passively received information.
**Implication**: The derivation approach (generating vault architecture from conversation rather than applying templates) leverages the generation effect. Users remember architecture they helped derive.
**Kernel Primitive**: (vault-creation philosophy)
**Confidence**: Strong

### Testing Effect
**Citation**: Roediger & Karpicke (2006) — "Test-enhanced learning"
**Finding**: The act of retrieving information strengthens memory more than re-studying. Testing is a powerful learning tool.
**Implication**: The /verify and /rethink commands force retrieval practice on notes. Questioning your own notes strengthens understanding.
**Kernel Primitive**: processing-pipeline
**Confidence**: Strong

### Encoding Specificity
**Citation**: Tulving & Thomson (1973) — "Encoding specificity and retrieval processes"
**Finding**: Memory retrieval is best when the retrieval context matches the encoding context.
**Implication**: Domain-native personality (voice, terminology) creates consistent encoding context. Notes written in a consistent voice are easier to retrieve when searching in that voice.
**Kernel Primitive**: personality
**Confidence**: Strong

### Elaborative Encoding
**Citation**: Craik & Tulving (1975) — "Depth of processing and the retention of words"
**Finding**: Deeper, more elaborative processing at encoding leads to better retention.
**Implication**: The 6R pipeline forces progressively deeper processing — each R adds another layer of elaboration.
**Kernel Primitive**: processing-pipeline
**Confidence**: Strong

## Forgetting and Persistence

### Ebbinghaus Forgetting Curve
**Citation**: Ebbinghaus (1885) — "Über das Gedächtnis"
**Finding**: Forgetting follows a predictable curve — rapid initially, then slowing. Spaced repetition combats this.
**Implication**: The session rhythm with regular processing sessions provides natural spaced exposure. Notes that return to attention through MOC browsing get informal spaced retrieval.
**Kernel Primitive**: session-rhythm
**Confidence**: Strong

### Spacing Effect
**Citation**: Cepeda et al. (2006) — "Distributed practice in verbal recall tasks"
**Finding**: Distributing learning over time produces better retention than massing it. Optimal spacing depends on retention interval.
**Implication**: The session rhythm (not processing everything in one sitting) leverages spacing. Status lifecycle (seed → growing → evergreen) implies revisitation over time.
**Kernel Primitive**: session-rhythm, status-lifecycle
**Confidence**: Strong

### Interference Theory
**Citation**: Anderson & Neely (1996) — "Interference and inhibition in memory retrieval"
**Finding**: Similar memories interfere with each other at retrieval. Proactive interference (old blocking new) and retroactive interference (new blocking old) are both real.
**Implication**: Domain namespacing reduces interference between similar concepts in different domains. The wiki-link context helps disambiguate similar notes.
**Kernel Primitive**: domain-namespace, wiki-link
**Confidence**: Moderate
