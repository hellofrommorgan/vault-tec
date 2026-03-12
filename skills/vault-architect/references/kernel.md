# Kernel Primitives

The 15 kernel primitives define the irreducible architectural decisions of every vault-tec vault. Each primitive maps to cognitive science research — no primitive exists without empirical backing.

## Primitive Definitions

### 1. atomic-note
- **Rule**: One idea per note. If a note contains two ideas, split it.
- **Grounding**: Miller (1956) — chunking capacity limits; Kintsch (1988) — proposition-level comprehension
- **Implementation**: Title = concept name. Body = explanation. Max ~300 words for core content.
- **Validation**: If you can't state the note's single idea in one sentence, it's not atomic.

### 2. yaml-schema
- **Rule**: Every note has YAML frontmatter with typed fields. Schema is enforced, not optional.
- **Grounding**: Sweller (1988) — extraneous cognitive load reduction; Chi (2000) — self-explanation improves encoding
- **Implementation**: Required fields: `type`, `domain`, `created`, `status`, `connections`. Type-specific fields per template.
- **Validation**: Missing required fields = schema violation. Hook enforcement recommended.

### 3. wiki-link
- **Rule**: Connect notes using [[double bracket]] syntax. Links are semantic — they represent conceptual relationships.
- **Grounding**: Collins & Loftus (1975) — spreading activation; Anderson (1983) — ACT* memory retrieval
- **Implementation**: Every note should have 2-5 outgoing links. Links in body text, not just frontmatter.
- **Validation**: Orphan notes (0 links) are unhealthy. Broken links point to non-existent notes.

### 4. moc (Map of Content)
- **Rule**: MOCs are navigation hubs, not folders. They organize notes by conceptual relationship.
- **Grounding**: Kintsch (1988) — situation models; Bransford (1979) — organized knowledge retrieval
- **Implementation**: Three levels: Master MOC → Domain MOC → Topic MOC. Every note reachable within 3 hops from a MOC.
- **Validation**: Unreachable notes indicate MOC gaps.

### 5. domain-namespace
- **Rule**: Notes are namespaced by domain using DOMAIN:type convention in frontmatter.
- **Grounding**: Rosch (1975) — prototype theory; Barsalou (1983) — context-dependent categories
- **Implementation**: `domain: AI` or `domain: philosophy`. Domains map to subdirectories in notes/.
- **Validation**: Every note has exactly one primary domain.

### 6. three-spaces
- **Rule**: Vault is divided into self/ (identity), notes/ (knowledge), ops/ (operations).
- **Grounding**: Tulving (1985) — episodic/semantic/procedural memory systems; Conway (2005) — self-memory system
- **Implementation**: Each space has different growth rates and churn expectations.
- **Validation**: Cross-contamination (ops files in notes/) indicates architectural drift.

### 7. processing-pipeline
- **Rule**: Notes progress through the 6R pipeline: Record → Reduce → Reflect → Reweave → Verify → Rethink
- **Grounding**: Paivio (1986) — dual coding; Craik & Lockhart (1972) — levels of processing
- **Implementation**: Each R is a distinct cognitive operation. Fresh LLM context per phase prevents contamination.
- **Validation**: Notes stuck at "Record" indicate pipeline blockage.

### 8. session-rhythm
- **Rule**: Each work session follows Capture → Process → Integrate phases.
- **Grounding**: Ebbinghaus (1885) — spacing effect; Bjork (1994) — spacing and interleaving
- **Implementation**: Session start loads context. Session end captures state. Between: focused work.
- **Validation**: Sessions without integration phase lose knowledge.

### 9. status-lifecycle
- **Rule**: Notes progress: seed → growing → evergreen. Status tracks maturity.
- **Grounding**: Bjork (1994) — desirable difficulty; Karpicke & Roediger (2008) — retrieval practice
- **Implementation**: `status: seed` (raw capture), `status: growing` (processed, connected), `status: evergreen` (verified, stable).
- **Validation**: Healthy vault has distribution across all three statuses.

### 10. self-space
- **Rule**: The self/ directory persists agent identity across sessions.
- **Grounding**: Newell (1990) — unified theories of cognition; Tulving (2002) — autonoetic consciousness
- **Implementation**: identity.md (who), methodology.md (how), goals.md (why), evolution-log.md (history).
- **Validation**: self/ files should change slowly. Rapid changes indicate instability.

### 11. personality
- **Rule**: Documentation uses domain-native voice and terminology.
- **Grounding**: Clark (1996) — common ground theory; Pickering & Garrod (2004) — alignment in dialogue
- **Implementation**: Derived from conversation during vault creation. Stored in self/identity.md.
- **Validation**: If notes feel "off-voice," personality needs recalibration.

### 12. maintenance-hooks
- **Rule**: Quality is enforced automatically, not manually.
- **Grounding**: Norman (1988) — error prevention design; Reason (1990) — active failure prevention
- **Implementation**: Hooks validate schema on write, orient on session start.
- **Validation**: Disabled hooks correlate with vault quality degradation.

### 13. template-system
- **Rule**: Note templates define the canonical schema for each note type. Templates are the single source of truth.
- **Grounding**: Chi (2000) — self-explanation effect; Bransford (1979) — schema theory
- **Implementation**: Templates stored in vault's templates/ directory. Each has complete YAML frontmatter.
- **Validation**: Notes diverging from their template indicate template drift.

### 14. ethical-guardrails
- **Rule**: AI interactions respect boundaries — no fabrication, no overconfidence, no harmful outputs.
- **Grounding**: Reason (1990) — Swiss cheese model of failure; Kahneman (2011) — cognitive biases
- **Implementation**: CLAUDE.md includes explicit guardrail section. Agent admits uncertainty, cites sources.
- **Validation**: Periodic review of agent outputs for accuracy.

### 15. evolution-tracking
- **Rule**: Every architectural change is logged with rationale and research basis.
- **Grounding**: Schön (1983) — reflective practice; Argyris (1977) — double-loop learning
- **Implementation**: self/evolution-log.md records all changes. Include: what changed, why, what research supports it.
- **Validation**: Unlogged changes are architectural debt.
