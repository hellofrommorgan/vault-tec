# Post-2016 Research Additions

Research published after 2016 that extends, updates, or challenges the foundational cognitive science claims backing vault-tec's architecture.

## Context Engineering (2020-2025)

### CE-1: Context Window as Working Memory Analog
**Claim**: LLM context windows function as a working memory analog — with similar capacity constraints, recency effects, and chunking benefits.
**Source**: Anthropic internal research; Liu et al. (2023) "Lost in the Middle"
**Relevance**: Validates the atomic note approach — smaller, well-structured units are easier to retrieve and process within context limits.
**Confidence**: Medium (analogy is useful but not exact)
**Vault implication**: Keep notes atomic and well-titled. Context window ≈ working memory, so vault design should minimize retrieval overhead.

### CE-2: Retrieval-Augmented Generation Patterns
**Claim**: RAG systems perform better when retrieved documents are atomic, well-structured, and have clear metadata — mirroring findings from human memory retrieval research.
**Source**: Lewis et al. (2020) "RAG"; Gao et al. (2023) "RAG Survey"
**Relevance**: Agent vaults are effectively RAG systems with the vault as the knowledge base. Atomic note design directly improves retrieval quality.
**Confidence**: Strong (empirical, widely replicated)
**Vault implication**: Atomic notes with good titles and metadata aren't just cognitively sound — they're technically optimal for agent retrieval.

### CE-3: Tool Use and Extended Cognition
**Claim**: LLM agents that use external tools (including structured knowledge stores) outperform those relying solely on parametric knowledge.
**Source**: Schick et al. (2023) "Toolformer"; Qin et al. (2023) "Tool Learning"
**Relevance**: The vault IS the agent's extended cognition. Well-structured external memory augments agent capability beyond what's possible with context alone.
**Confidence**: Strong (empirical, consistent findings)
**Vault implication**: Investing in vault architecture directly improves agent performance. The vault is not optional infrastructure — it's core cognitive capacity.

## Agent Architecture Research (2023-2025)

### AA-1: Reflexion and Self-Improvement
**Claim**: Agents that maintain structured logs of past actions and reflect on them show improved performance over time.
**Source**: Shinn et al. (2023) "Reflexion"
**Relevance**: Validates the ops/sessions/ log structure and the reflection note type. Session logs aren't just records — they're the substrate for agent self-improvement.
**Confidence**: Strong (empirical)
**Vault implication**: Session logging and reflection aren't optional maintenance — they're the mechanism for agent learning.

### AA-2: Memory-Augmented Agents
**Claim**: Agents with structured external memory (hierarchical, typed, with retrieval mechanisms) significantly outperform agents with flat context or no external memory.
**Source**: Park et al. (2023) "Generative Agents"; Zhong et al. (2024) "MemoryBank"
**Relevance**: Directly validates the three-space model and typed note architecture. Structure matters more than volume.
**Confidence**: Strong (empirical, multiple independent confirmations)
**Vault implication**: The three-space model (self/notes/ops) with typed notes and MOC navigation isn't arbitrary — it's empirically validated as superior to unstructured alternatives.

### AA-3: Multi-Agent Coordination
**Claim**: Multi-agent systems that share structured knowledge stores show emergent collaborative capabilities beyond what single agents achieve.
**Source**: Li et al. (2023) "CAMEL"; Hong et al. (2024) "MetaGPT"
**Relevance**: Vaults designed for agent-native access could enable multi-agent collaboration where agents share, build on, and challenge each other's knowledge.
**Confidence**: Medium (early research, not yet mature)
**Vault implication**: Design vaults with agent-native access in mind. The vault schema should be parseable by any agent, not just the one that created it.

## Counterevidence and Limitations

### Counter-1: Anderson's Fan Effect (1974, confirmed in modern studies)
**Claim**: As the number of associations to a concept increases, retrieval time for any single association also increases. More links ≠ always better.
**Source**: Anderson (1974); Radvansky & Zacks (2014) confirmation
**Relevance**: Challenges the "more connections = better" assumption. There's an optimal connection density beyond which retrieval degrades.
**Confidence**: Strong (foundational, well-replicated)
**Vault implication**: Don't maximize links. Optimize for meaningful, high-quality connections. Pruning weak links can improve retrieval.

### Counter-2: Cognitive Load from Excessive Structure
**Claim**: Overly complex organizational structures impose cognitive load that can exceed the benefit of the organization itself.
**Source**: Sweller et al. (2019) "Cognitive Load Theory update"
**Relevance**: Challenges aggressive schema enforcement. If the schema is too complex, the overhead of maintaining it may exceed its organizational benefit.
**Confidence**: Strong (foundational theory, updated)
**Vault implication**: Schema complexity should scale with vault maturity. Start simple, add complexity only when proven necessary. The "relaxed" guardrail setting exists for a reason.

### Counter-3: Automation Complacency
**Claim**: When systems automate quality checks, users tend to reduce their own vigilance, potentially missing issues the automation doesn't catch.
**Source**: Parasuraman & Manzey (2010); extended by Wickens et al. (2015)
**Relevance**: Hook enforcement can create false confidence. Users may assume "if the hook didn't catch it, it's fine."
**Confidence**: Strong (well-documented in human factors research)
**Vault implication**: Hooks should warn, not silently pass. Maintain user engagement with quality — don't fully automate it away.

## Confidence Level Definitions

| Level | Definition | Typical Source |
|-------|-----------|----------------|
| Strong | Multiple independent empirical confirmations. Consistent findings across studies. No major contradictions. | Peer-reviewed papers with replication |
| Medium | Some empirical support. May be based on a single strong study, or multiple weaker ones. Plausible but not fully established. | Single peer-reviewed paper, or preprints with consistent findings |
| Low | Theoretical reasoning or analogy. Limited empirical support. May be contradicted by some evidence. | Expert opinion, theoretical papers, analogies from adjacent fields |
| Speculative | Novel claim based on extrapolation or emerging patterns. No direct empirical support yet. | Conference talks, blog posts, early-stage research |
