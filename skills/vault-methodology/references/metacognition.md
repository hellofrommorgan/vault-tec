# Metacognition

Research on self-regulation, reflection, calibration, and how thinking about thinking improves knowledge quality and learning outcomes.

## Self-Regulation

### Metacognitive Monitoring
**Citation**: Nelson & Narens (1990) — "Metamemory: A theoretical framework and new findings"
**Finding**: Effective learners monitor their own understanding — they know what they know and what they don't. This monitoring regulates learning strategies.
**Implication**: The status lifecycle (seed/growing/evergreen) is an explicit metacognitive monitoring tool. Labeling a note "seed" says "I know this is incomplete." The /health command provides vault-level metacognitive assessment.
**Kernel Primitive**: status-lifecycle
**Confidence**: Strong

### Self-Regulated Learning
**Citation**: Zimmerman (2002) — "Becoming a self-regulated learner"
**Finding**: Expert learners follow a cycle: forethought (planning) → performance (executing) → self-reflection (evaluating). Each phase informs the next.
**Implication**: The session rhythm mirrors this: Capture phase (forethought/planning) → Process phase (performance) → Integrate phase (self-reflection). Evolution via /evolve is macro-level self-reflection.
**Kernel Primitive**: session-rhythm
**Confidence**: Strong

### Calibration
**Citation**: Lichtenstein et al. (1982) — "Calibration of probabilities"
**Finding**: People are generally overconfident in their knowledge — their subjective confidence exceeds their actual accuracy. Calibration (aligning confidence with accuracy) is a learnable skill.
**Implication**: The `confidence:` field in atomic notes forces explicit calibration. Am I certain about this claim? The /rethink command challenges overconfidence by forcing counter-argument consideration.
**Kernel Primitive**: processing-pipeline, yaml-schema
**Confidence**: Strong

### Illusion of Knowing
**Citation**: Glenberg et al. (1982) — "Calibration of comprehension"
**Finding**: Readers often believe they understand text when they actually don't. This illusion of knowing persists until tested.
**Implication**: The /verify command tests comprehension by checking whether a note's claims are internally consistent and properly supported. Without verification, the vault accumulates notes that feel understood but aren't.
**Kernel Primitive**: processing-pipeline
**Confidence**: Strong

## Reflection

### Reflective Practice
**Citation**: Schön (1983) — "The Reflective Practitioner"
**Finding**: Expert practitioners engage in reflection-in-action (during practice) and reflection-on-action (after practice). This reflection is what distinguishes mere experience from genuine expertise.
**Implication**: Reflection notes (type: reflection) are explicit reflective practice. The /remember command captures reflection-in-action. Session logs enable reflection-on-action.
**Kernel Primitive**: evolution-tracking, processing-pipeline
**Confidence**: Strong

### Double-Loop Learning
**Citation**: Argyris (1977) — "Double-loop learning in organizations"
**Finding**: Single-loop learning corrects errors within existing frameworks. Double-loop learning questions the frameworks themselves. Organizations that only do single-loop learning stagnate.
**Implication**: The /rethink command is double-loop learning — it challenges the frameworks, not just the details. The /evolve command is double-loop at the architectural level — questioning whether the vault structure itself is still appropriate.
**Kernel Primitive**: processing-pipeline, evolution-tracking
**Confidence**: Strong

### Productive Failure
**Citation**: Kapur (2008) — "Productive failure"
**Finding**: Students who struggle with problems before receiving instruction perform better on transfer tasks than students who receive instruction first.
**Implication**: The vault should tolerate (even encourage) imperfect seed notes. The 6R pipeline assumes notes START imperfect and improve through processing. Premature perfectionism kills knowledge development.
**Kernel Primitive**: status-lifecycle, processing-pipeline
**Confidence**: Moderate

## Desirable Difficulty

### Desirable Difficulties Framework
**Citation**: Bjork (1994) — "Memory and metamemory considerations"
**Finding**: Conditions that make learning harder in the short term often produce better long-term retention. These include: spacing, interleaving, testing, generation, and reduced feedback.
**Implication**: The full 6R pipeline is harder than just copying information. Processing notes through multiple stages is effortful. But this effort is the mechanism that produces deep understanding. Don't optimize for ease — optimize for learning.
**Kernel Primitive**: processing-pipeline
**Confidence**: Strong

### Interleaving
**Citation**: Rohrer & Taylor (2007) — "The shuffling of mathematics problems improves learning"
**Finding**: Interleaving practice across different problem types improves discriminative ability and transfer, even though blocked practice feels easier.
**Implication**: Processing notes from different domains in the same session (interleaving) may be harder but produces better cross-domain connections. The /next command can deliberately suggest interleaved processing.
**Kernel Primitive**: session-rhythm
**Confidence**: Moderate

### Effort and Encoding
**Citation**: Tyler et al. (1979) — "The effect of effort on learning"
**Finding**: Greater cognitive effort during encoding leads to better retention, provided the effort is productive (relevant to the material, not extraneous).
**Implication**: The distinction between productive effort (deep processing via 6R) and unproductive effort (fighting bad schema, navigating disorganized vaults) is crucial. The vault structure minimizes unproductive effort while maximizing productive effort.
**Kernel Primitive**: processing-pipeline, yaml-schema
**Confidence**: Strong

## Knowledge Monitoring

### Judgment of Learning
**Citation**: Dunlosky & Nelson (1992) — "Importance of the kind of cue for judgments of learning"
**Finding**: People's predictions about what they'll remember are more accurate when based on retrieval cues (trying to recall) rather than study cues (looking at the material).
**Implication**: When assigning status to a note (seed/growing/evergreen), test by trying to recall its content without looking. If you can recall the key insight, it's at least "growing." If you can also recall its connections and counter-arguments, it's "evergreen."
**Kernel Primitive**: status-lifecycle
**Confidence**: Moderate

### Dunning-Kruger Effect
**Citation**: Kruger & Dunning (1999) — "Unskilled and unaware of it"
**Finding**: People with low ability in a domain tend to overestimate their competence, while experts tend to underestimate theirs.
**Implication**: New vaults with few notes may feel more "complete" than they are. The /health diagnostic provides objective measurement against this bias. Connection density and coverage metrics don't lie.
**Kernel Primitive**: (vault health)
**Confidence**: Strong

### Metacognitive Strategies
**Citation**: Flavell (1979) — "Metacognition and cognitive monitoring"
**Finding**: Metacognitive strategies (planning, monitoring, evaluating) can be explicitly taught and improve learning outcomes.
**Implication**: vault-tec teaches metacognitive strategies implicitly through its structure: the session rhythm teaches planning, the 6R pipeline teaches monitoring, and /health teaches evaluation. The vault is a metacognition training system.
**Kernel Primitive**: session-rhythm, processing-pipeline
**Confidence**: Moderate
