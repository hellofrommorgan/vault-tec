---
name: vault-methodology
description: >
  Research methodology backing every vault-tec architectural decision.
  83 consolidated cognitive science claims across 6 domains. Use when the
  user asks "why is the vault structured this way", "what research backs this",
  "explain the cognitive science", "methodology", "research claims", "evidence
  for", or needs justification for any architectural decision. Also triggers
  on questions about memory, learning theory, cognitive load, or knowledge
  management research.
version: 0.1.0
---

# Vault Methodology

Every architectural decision in vault-tec traces to cognitive science research. This skill contains 83 consolidated research claims organized into 6 domains, distilled from arscontexta's methodology layer.

## Methodology Domains

The 83 claims are organized into 6 research domains. Each domain is a self-contained reference file:

1. **Cognitive Foundations** (`references/cognitive-foundations.md`) — Memory systems, attention, cognitive load, chunking. The bedrock research on how humans process and store information.

2. **Knowledge Architecture** (`references/knowledge-architecture.md`) — Schema theory, categorization, hierarchical organization, semantic networks. How knowledge is structured for retrieval.

3. **Information Processing** (`references/information-processing.md`) — Levels of processing, dual coding, elaborative rehearsal, generation effect. How processing depth affects retention.

4. **Retrieval and Linking** (`references/retrieval-and-linking.md`) — Spreading activation, retrieval practice, transfer-appropriate processing, context-dependent memory. How connections enable finding what you know.

5. **Metacognition** (`references/metacognition.md`) — Self-regulation, reflection, desirable difficulty, calibration. How thinking about thinking improves knowledge quality.

6. **Evolution and Maintenance** (`references/evolution-and-maintenance.md`) — Reflective practice, double-loop learning, error prevention, system drift. How knowledge systems stay healthy over time.

## How to Use This Skill

When answering "why" questions about vault architecture:
1. Identify which domain(s) the question touches
2. Read the relevant reference file(s)
3. Find the specific claims that support the architectural decision
4. Present the answer with: claim, citation, and practical implication

When making architectural decisions:
1. Check whether existing research supports the proposed change
2. If supported, cite the backing claims
3. If no research backing exists, flag it as an empirical gap
4. Log the decision and its backing (or lack thereof) in evolution-log.md

## Claim Format

Each claim follows this structure:
```
### [Claim Title]
**Citation**: [Author (Year)] — [Paper/Book title]
**Finding**: [What the research found]
**Implication**: [What this means for vault architecture]
**Kernel Primitive**: [Which primitive this backs]
**Confidence**: [Strong | Moderate | Emerging]
```

## Cross-Domain Claims

Some claims bridge multiple domains — these are marked with multiple kernel primitive tags. Cross-domain claims are particularly valuable because they provide converging evidence from independent research traditions.
