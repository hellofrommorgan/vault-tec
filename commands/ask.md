---
description: Query the methodology research graph
allowed-tools: Read, Grep, Glob
argument-hint: [question]
---

Answer a question about knowledge management methodology by searching the consolidated research claims. Load the vault-methodology skill from `${CLAUDE_PLUGIN_ROOT}/skills/vault-methodology/SKILL.md`.

## Process

1. Parse the user's question from `$ARGUMENTS`
2. Determine which methodology domain(s) are relevant:
   - **Cognitive foundations** — memory, attention, learning theory
   - **Knowledge architecture** — structure, schema, atomic design
   - **Information processing** — pipelines, capture, refinement
   - **Retrieval and linking** — search, connections, spreading activation
   - **Metacognition** — reflection, self-awareness, evolution
   - **Evolution and maintenance** — drift, recovery, lifecycle

3. Read the relevant reference files from `${CLAUDE_PLUGIN_ROOT}/skills/vault-methodology/references/`
4. Search for claims that address the question
5. Present the answer with:
   - Direct response to the question
   - Supporting research claims with citations (author, year)
   - Practical implications for vault architecture
   - Related claims the user might want to explore

## Answer Format

```
Q: [user's question]

A: [clear, grounded answer]

SUPPORTING RESEARCH:
- [Claim]: [Citation] — [relevance to question]
- [Claim]: [Citation] — [relevance to question]

PRACTICAL IMPLICATIONS:
- [What this means for your vault]

SEE ALSO:
- [Related questions or claims]
```

If the question doesn't map to any known research claims, say so honestly and suggest where the user might look, or flag it as an open question worth investigating.
