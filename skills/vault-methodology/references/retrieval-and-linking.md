# Retrieval and Linking

Research on spreading activation, network effects, transfer-appropriate processing, and how connections enable knowledge retrieval.

## Spreading Activation Networks

### Spreading Activation Theory
**Citation**: Collins & Loftus (1975) — "A spreading activation theory of semantic processing"
**Finding**: Concepts in memory are organized as a network. Activating one concept spreads activation to connected concepts along the links, with strength decreasing with distance.
**Implication**: Wiki-links ARE the activation network. Following a link activates the target concept. Well-linked vaults have efficient activation spreading — you can reach relevant ideas quickly.
**Kernel Primitive**: wiki-link
**Confidence**: Strong

### Priming Effects
**Citation**: Meyer & Schvaneveldt (1971) — "Facilitation in recognizing pairs of words"
**Finding**: Recognition of a word is faster when preceded by a semantically related word. This priming effect reflects spreading activation in the mental lexicon.
**Implication**: When browsing connected notes, each note "primes" the concepts in its linked neighbors. This makes it easier to understand and process the next note you visit.
**Kernel Primitive**: wiki-link
**Confidence**: Strong

### Strength of Association
**Citation**: Anderson (1983) — "The architecture of cognition" (ACT* theory)
**Finding**: Memory retrieval depends on the strength of association between the retrieval cue and the target memory. Stronger associations produce faster, more reliable retrieval.
**Implication**: Frequently co-accessed notes should be linked (if they aren't already). Connection strength in the vault mirrors association strength in memory. MOC links to frequently-accessed notes should be prominent.
**Kernel Primitive**: wiki-link, moc
**Confidence**: Strong

### Fan Effect
**Citation**: Anderson (1974) — "Retrieval of propositional information from long-term memory"
**Finding**: When a concept is connected to many facts/associations, retrieval of any one becomes slower (the "fan effect"). More connections = more competition at retrieval.
**Implication**: Very highly-connected hub notes may become retrieval bottlenecks. If a note has >10 connections, it may benefit from being split or from having its MOC restructured to reduce fan.
**Kernel Primitive**: wiki-link, moc
**Confidence**: Strong

## Network Topology

### Small-World Networks
**Citation**: Steyvers & Tenenbaum (2005) — "The large-scale structure of semantic networks"
**Finding**: Semantic networks in the mind exhibit small-world properties: high clustering (related concepts group together) with short path lengths (any concept is a few hops from any other).
**Implication**: Healthy vaults should exhibit small-world topology. MOCs provide the "long-range" connections that shorten path lengths. Domain clustering provides the high-clustering component.
**Kernel Primitive**: moc, wiki-link, domain-namespace
**Confidence**: Strong

### Hub-and-Spoke Organization
**Citation**: Patterson et al. (2007) — "Where do you know what you know?"
**Finding**: The brain uses a hub-and-spoke architecture for semantic memory — domain-specific "spokes" connected through amodal "hubs" that enable cross-domain integration.
**Implication**: MOCs are the hubs. Domain-specific notes are the spokes. Cross-domain bridge concepts are the amodal integrators. This architecture is neurally plausible.
**Kernel Primitive**: moc, domain-namespace
**Confidence**: Moderate

### Network Resilience
**Citation**: Albert et al. (2000) — "Error and attack tolerance of complex networks"
**Finding**: Scale-free networks (with hub nodes) are robust to random failures but vulnerable to targeted hub removal.
**Implication**: MOCs are hub nodes — they're critical infrastructure. Corrupted or missing MOCs are more damaging than corrupted individual notes. Health checks should prioritize MOC integrity.
**Kernel Primitive**: moc
**Confidence**: Moderate

## Retrieval Strategies

### Retrieval Practice Effect
**Citation**: Karpicke & Roediger (2008) — "The critical importance of retrieval for learning"
**Finding**: Practicing retrieval is more effective for long-term learning than additional study, even when study provides additional exposure.
**Implication**: Using /ask to query the vault, browsing MOCs, and running /verify all force retrieval practice. The vault should encourage retrieval, not just storage.
**Kernel Primitive**: processing-pipeline
**Confidence**: Strong

### Transfer-Appropriate Processing
**Citation**: Morris et al. (1977) — "Levels of processing versus transfer-appropriate processing"
**Finding**: Memory performance is best when the cognitive processes used at retrieval match those used at encoding.
**Implication**: If you encode notes by connecting them to concepts (elaborative encoding), you should retrieve them by conceptual association (MOC browsing, wiki-link traversal), not just keyword search.
**Kernel Primitive**: wiki-link, moc
**Confidence**: Strong

### Cue-Dependent Forgetting
**Citation**: Tulving (1974) — "Cue-dependent forgetting"
**Finding**: Forgetting is often a retrieval failure, not a storage failure. The information exists but the right cue isn't available to access it.
**Implication**: Multiple retrieval paths reduce cue-dependent forgetting. A note accessible via MOC browsing, wiki-link traversal, AND keyword search has three independent retrieval paths. Redundancy is a feature.
**Kernel Primitive**: moc, wiki-link, yaml-schema
**Confidence**: Strong

### Encoding Variability
**Citation**: Martin (1968) — "Encoding specificity revisited"
**Finding**: Encoding the same information in multiple contexts (with different cues) improves later retrieval because any of those contexts can serve as a retrieval cue.
**Implication**: Cross-domain links encode a concept in multiple contexts. A note about "attention" linked from both a "neuroscience" MOC and a "UX design" MOC is encoded in two contexts, doubling retrieval paths.
**Kernel Primitive**: wiki-link, domain-namespace
**Confidence**: Moderate

## Connection Quality

### Meaningful vs. Arbitrary Links
**Citation**: Craik & Tulving (1975) — "Depth of processing"
**Finding**: Meaningful (semantic) elaboration produces better memory than surface-level (structural) elaboration.
**Implication**: Wiki-links should represent meaningful conceptual relationships, not arbitrary associations. "builds on," "contrasts with," and "applies to" are meaningful. "mentioned in the same session" is arbitrary.
**Kernel Primitive**: wiki-link
**Confidence**: Strong

### Relational Processing
**Citation**: Hunt & Einstein (1981) — "Relational and item-specific information in memory"
**Finding**: Optimal memory requires both item-specific processing (understanding each item on its own) and relational processing (understanding how items relate to each other).
**Implication**: Atomic notes handle item-specific processing (deep understanding of one concept). Wiki-links and MOCs handle relational processing (how concepts connect). Both are needed.
**Kernel Primitive**: atomic-note, wiki-link, moc
**Confidence**: Strong

### Interference and Distinctiveness
**Citation**: Anderson & Neely (1996) — "Interference and inhibition in memory retrieval"
**Finding**: Similar memories compete at retrieval. Distinctive features help resolve this competition.
**Implication**: Notes on similar topics need distinctive features to avoid interference. The YAML schema (unique title, domain, specific connections) provides distinctiveness. Status and confidence fields add additional discriminability.
**Kernel Primitive**: yaml-schema, atomic-note
**Confidence**: Moderate
