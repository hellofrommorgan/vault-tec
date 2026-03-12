# Evolution and Maintenance

Research on reflective practice, system drift, error prevention, and how knowledge systems stay healthy and adaptive over time.

## System Evolution

### Reflective Practice
**Citation**: Schön (1983) — "The Reflective Practitioner"
**Finding**: Professionals develop expertise through cycles of action and reflection. Without deliberate reflection on practice, experience alone doesn't produce improvement.
**Implication**: The evolution-log tracks deliberate reflection on vault architecture. The /evolve command triggers this reflection. Without it, vaults accumulate accidental complexity.
**Kernel Primitive**: evolution-tracking
**Confidence**: Strong

### Double-Loop Learning
**Citation**: Argyris (1977) — "Double-loop learning in organizations"
**Finding**: Single-loop learning adjusts actions within existing mental models. Double-loop learning examines and changes the mental models themselves. Both are necessary; only the second produces genuine adaptation.
**Implication**: Note-level editing is single-loop (fixing content within existing structure). /evolve is double-loop (questioning whether the structure itself needs to change). Both are needed — but most people only do single-loop.
**Kernel Primitive**: evolution-tracking
**Confidence**: Strong

### Punctuated Equilibrium
**Citation**: Gersick (1991) — "Revolutionary change theories: A multilevel exploration"
**Finding**: Groups don't evolve gradually — they alternate between long periods of stability and brief periods of revolutionary change, often triggered by temporal milestones.
**Implication**: Vaults evolve the same way. Long periods of stable note-taking punctuated by architectural changes when friction accumulates. /evolve should be used at natural milestones (project completion, domain saturation, seasonal reviews).
**Kernel Primitive**: evolution-tracking
**Confidence**: Moderate

### Conway's Law for Knowledge
**Citation**: Conway (1968) — "How do committees invent?"
**Finding**: Systems mirror the communication structure of the organization that built them.
**Implication**: A vault's structure will mirror its user's thinking patterns. If the user thinks in hierarchies, the vault will become hierarchical. If they think in networks, it will become networked. /evolve should check whether the vault structure still matches the user's actual thinking style.
**Kernel Primitive**: evolution-tracking
**Confidence**: Moderate

## Drift and Decay

### Normalization of Deviance
**Citation**: Vaughan (1996) — "The Challenger Launch Decision"
**Finding**: Small deviations from established procedures, when accepted repeatedly, become the new norm. Each deviation makes the next slightly larger deviation acceptable.
**Implication**: Skipping YAML frontmatter "just this once" normalizes schema violations. Drift is cumulative and insidious. Automated enforcement (hooks) prevent normalization of deviance.
**Kernel Primitive**: maintenance-hooks
**Confidence**: Strong

### Technical Debt Metaphor
**Citation**: Cunningham (1992) — "The WyCash portfolio management system" (experience report)
**Finding**: Taking shortcuts in code creates "technical debt" that accrues interest — future development becomes slower and more error-prone.
**Implication**: Unprocessed inbox items, orphan notes, stale MOCs, and schema violations are knowledge debt. Like technical debt, they compound. Regular /health checks identify and quantify this debt.
**Kernel Primitive**: maintenance-hooks
**Confidence**: Strong (by analogy)

### Entropy and Maintenance
**Citation**: Lehman (1980) — "Programs, life cycles, and laws of software evolution"
**Finding**: Systems that aren't actively maintained degrade over time. Functionality erodes, complexity increases, quality decreases.
**Implication**: Vaults require active maintenance. Without periodic /health checks and /evolve reviews, they degrade. The session rhythm's integration phase is the minimum maintenance unit.
**Kernel Primitive**: maintenance-hooks, session-rhythm
**Confidence**: Strong (by analogy)

## Error Prevention

### Swiss Cheese Model
**Citation**: Reason (1990) — "Human Error"
**Finding**: Accidents occur when holes in multiple defensive layers align. Each layer is imperfect (has "holes"), but multiple layers make catastrophic failure unlikely.
**Implication**: Vault quality relies on multiple defensive layers: schema templates (layer 1), write-time hook validation (layer 2), periodic health checks (layer 3), evolution reviews (layer 4). No single layer is perfect; together they catch most problems.
**Kernel Primitive**: maintenance-hooks, ethical-guardrails
**Confidence**: Strong

### Error Prevention vs. Error Detection
**Citation**: Norman (1988) — "The Design of Everyday Things"
**Finding**: Preventing errors through design is more effective than detecting and correcting them after the fact. Constraints, affordances, and forcing functions prevent errors.
**Implication**: Templates are forcing functions — they constrain note creation to valid schemas. Hook validation is a constraint — it prevents invalid writes. These are preferable to after-the-fact health checks (though both are needed).
**Kernel Primitive**: template-system, maintenance-hooks
**Confidence**: Strong

### Human Error Taxonomy
**Citation**: Reason (1990) — "Human Error"
**Finding**: Errors fall into three categories: slips (execution failures), lapses (memory failures), and mistakes (planning failures). Each requires different countermeasures.
**Implication**: Slips (typos in schema) → caught by validation hooks. Lapses (forgetting to process inbox) → caught by health checks. Mistakes (wrong architectural decisions) → caught by /evolve. Different error types need different defensive layers.
**Kernel Primitive**: maintenance-hooks, evolution-tracking
**Confidence**: Strong

## Sustainability

### Flow State and Tool Friction
**Citation**: Csikszentmihalyi (1990) — "Flow: The psychology of optimal experience"
**Finding**: Flow states require clear goals, immediate feedback, and a balance between challenge and skill. Tool friction disrupts flow by introducing extraneous challenge.
**Implication**: Vault structure should minimize friction. Consistent schemas reduce decision fatigue. MOCs provide clear navigation. Templates provide instant starting points. The goal: the vault should feel like an extension of thought, not an obstacle to it.
**Kernel Primitive**: template-system, yaml-schema
**Confidence**: Moderate

### Habit Formation
**Citation**: Lally et al. (2010) — "How are habits formed"
**Finding**: Habit formation takes an average of 66 days of consistent repetition. Simple behaviors become habitual faster than complex ones.
**Implication**: The session rhythm should be simple enough to habituate. Start with the minimal rhythm (orient, work, log) and add complexity only after the basic habit is established. /guide tutorial supports gradual skill building.
**Kernel Primitive**: session-rhythm
**Confidence**: Moderate

### Intrinsic Motivation
**Citation**: Deci & Ryan (1985) — "Intrinsic motivation and self-determination in human behavior"
**Finding**: Intrinsic motivation requires autonomy (choice), competence (mastery), and relatedness (connection to something meaningful).
**Implication**: The vault should feel autonomous (user-derived, not imposed), competence-building (visible growth via /stats, status lifecycle), and meaningful (connected to user's goals). Vaults that feel like chores die.
**Kernel Primitive**: (vault design philosophy)
**Confidence**: Moderate

### Cognitive Offloading
**Citation**: Risko & Gilbert (2016) — "Cognitive offloading"
**Finding**: Humans strategically offload cognitive tasks to external tools (notes, calendars, etc.). Effective offloading depends on tool reliability and accessibility.
**Implication**: The vault IS a cognitive offloading system. Its reliability (consistent schema, validated structure) and accessibility (MOC navigation, wiki-link traversal) determine whether users actually trust it enough to offload.
**Kernel Primitive**: yaml-schema, moc, wiki-link
**Confidence**: Strong
