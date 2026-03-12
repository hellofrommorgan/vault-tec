# Information Processing

Research on processing depth, dual coding, elaborative rehearsal, and the generation effect. How the way information is processed determines retention and understanding.

## Processing Depth

### Levels of Processing Framework
**Citation**: Craik & Lockhart (1972) — "Levels of processing"
**Finding**: Memory traces are byproducts of processing operations. Deeper (semantic) processing creates more durable traces than shallow (structural) processing.
**Implication**: The 6R pipeline creates progressively deeper processing — from raw capture (Record) through semantic extraction (Reduce) to integrative synthesis (Reweave).
**Kernel Primitive**: processing-pipeline
**Confidence**: Strong

### Elaborative Interrogation
**Citation**: Pressley et al. (1987) — "Elaborative interrogation facilitates acquisition of confusing facts"
**Finding**: Asking "why" questions during learning significantly improves retention, especially for factual knowledge.
**Implication**: The /reflect command prompts "why" questions: "Why does this connect to that? Why does this matter?" The /rethink command pushes further: "Why might this be wrong?"
**Kernel Primitive**: processing-pipeline
**Confidence**: Strong

### Dual Coding Theory
**Citation**: Paivio (1986) — "Mental representations: A dual coding approach"
**Finding**: Information encoded in both verbal and visual forms is remembered better than information encoded in only one form.
**Implication**: While vault-tec is primarily text-based, wiki-link networks create a spatial/structural encoding alongside verbal content. MOC maps provide a quasi-visual representation of knowledge topology.
**Kernel Primitive**: wiki-link, moc
**Confidence**: Moderate

### Generation Effect
**Citation**: Slamecka & Graf (1978) — "The generation effect"
**Finding**: Information you generate yourself is better remembered than information you passively receive.
**Implication**: Vault creation through conversational derivation (not template copying) leverages the generation effect. Users who help derive their vault's architecture understand it better.
**Kernel Primitive**: (vault creation philosophy)
**Confidence**: Strong

## Encoding Strategies

### Elaborative Rehearsal
**Citation**: Craik & Tulving (1975) — "Depth of processing and the retention of words"
**Finding**: Elaboration at encoding (connecting new information to existing knowledge) improves retention more than simple repetition.
**Implication**: The Reflect and Reweave stages force elaborative encoding — connecting new notes to existing ones, embedding new knowledge in the existing network.
**Kernel Primitive**: processing-pipeline
**Confidence**: Strong

### Self-Reference Effect
**Citation**: Rogers et al. (1977) — "Self-reference and the encoding of personal information"
**Finding**: Information related to the self is remembered better than information processed for other semantic properties.
**Implication**: The self/ space personalizes the knowledge system. Notes written in the vault's personality (which reflects the user's domain identity) benefit from self-referential encoding.
**Kernel Primitive**: self-space, personality
**Confidence**: Strong

### Organization and Encoding
**Citation**: Mandler (1967) — "Organization and memory"
**Finding**: Organizational processes during encoding directly improve later retrieval. Even arbitrary organization helps.
**Implication**: The act of filing a note into a domain, connecting it via wiki-links, and placing it in a MOC IS the encoding. The organizational work is the learning.
**Kernel Primitive**: domain-namespace, wiki-link, moc
**Confidence**: Strong

### Distinctiveness
**Citation**: Hunt & Worthen (2006) — "Distinctiveness and memory"
**Finding**: Distinctive items (those that differ from their context) are better remembered. Both individual distinctiveness and relational distinctiveness matter.
**Implication**: Atomic notes that capture unique insights stand out against the background of related notes. The contrast itself aids retrieval. Status markers (seed/growing/evergreen) add additional distinctiveness cues.
**Kernel Primitive**: atomic-note, status-lifecycle
**Confidence**: Moderate

## Retrieval Practice

### Testing Effect
**Citation**: Roediger & Karpicke (2006) — "Test-enhanced learning"
**Finding**: Retrieving information from memory strengthens the memory trace more than additional study. This is one of the most robust findings in memory research.
**Implication**: Commands like /verify and /rethink are retrieval practice exercises. Browsing MOCs provides informal retrieval practice.
**Kernel Primitive**: processing-pipeline
**Confidence**: Strong

### Retrieval-Induced Forgetting
**Citation**: Anderson et al. (1994) — "Retrieval-induced forgetting"
**Finding**: Practicing retrieval of some items from a category can impair retrieval of related but unpracticed items.
**Implication**: Don't only revisit the same favorite notes — the /next command should surface neglected notes to prevent retrieval-induced forgetting of less-visited content.
**Kernel Primitive**: (vault maintenance)
**Confidence**: Moderate

### Desirable Difficulty
**Citation**: Bjork (1994) — "Memory and metamemory considerations in the training of human beings"
**Finding**: Conditions that slow learning (spacing, interleaving, testing) often produce better long-term retention than conditions that feel easy.
**Implication**: The 6R pipeline is intentionally effortful. Processing a note through all six stages is harder than just filing it away, but produces better knowledge. The status lifecycle rewards this effort.
**Kernel Primitive**: processing-pipeline, status-lifecycle
**Confidence**: Strong

### Context-Dependent Memory
**Citation**: Godden & Baddeley (1975) — "Context-dependent memory in two natural environments"
**Finding**: Memory retrieval is better when the retrieval context matches the encoding context.
**Implication**: Domain-native personality creates consistent context. When you search for knowledge using the vault's domain terminology, you're more likely to find it because it was encoded in that same vocabulary.
**Kernel Primitive**: personality, domain-namespace
**Confidence**: Strong

## Consolidation

### Memory Consolidation
**Citation**: McGaugh (2000) — "Memory — a century of consolidation"
**Finding**: Memories undergo a consolidation process over time, transitioning from labile to stable states. This process takes time and can be influenced by subsequent experiences.
**Implication**: The status lifecycle (seed → growing → evergreen) mirrors consolidation. Seeds are labile — they can change dramatically. Evergreen notes are consolidated — stable and reliable.
**Kernel Primitive**: status-lifecycle
**Confidence**: Strong

### Reconsolidation
**Citation**: Nader et al. (2000) — "Fear memories require protein synthesis in the amygdala for reconsolidation"
**Finding**: When a memory is retrieved, it becomes labile again and must be reconsolidated. This creates a window for updating.
**Implication**: The /reweave command leverages reconsolidation — retrieving a note and updating it with new context. The note must be "re-stabilized" through verification.
**Kernel Primitive**: processing-pipeline
**Confidence**: Moderate
