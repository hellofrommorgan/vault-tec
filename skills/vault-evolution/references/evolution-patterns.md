# Evolution Patterns

Catalogue of common vault evolution patterns — recognized structural changes that have known outcomes, backed by research.

## Pattern 1: MOC Splitting

**Trigger**: A MOC has grown beyond 50 direct links.
**Diagnosis**: Scaling problem. The topic has grown beyond a single MOC's capacity to organize.
**Change**: Extract coherent subtopic clusters from the oversized MOC into new topic MOCs. The original MOC becomes a higher-level hub linking to the new topic MOCs.
**Research**: Cowan (2001) — working memory handles ~4 chunks; MOCs exceeding this become navigation burdens. Miller (1956) — chunking hierarchy.
**Effort**: Low (2-4 hours)
**Reversibility**: Easy (merge topic MOCs back if the split doesn't work)
**Risk**: Over-splitting creates navigational overhead. Don't split below 5 notes per topic MOC.
**Rollback**: Merge the sub-MOCs back into the parent, remove the sub-MOC files, update all links.

## Pattern 2: Domain Extraction

**Trigger**: A cluster of notes in one domain consistently deals with a distinct subtopic that has its own vocabulary and conventions.
**Diagnosis**: The domain has differentiated. What started as one topic is now two.
**Change**: Create a new domain directory. Move relevant notes. Create a new domain MOC. Update cross-references.
**Research**: Rosch (1975) — categories have internal structure that can differentiate. Basic-level categories maximize information gain.
**Effort**: Medium (4-8 hours)
**Reversibility**: Moderate (notes can be moved back, but links need updating)
**Risk**: Premature extraction creates unnecessary complexity. Wait until the subtopic has >=15 notes with distinct vocabulary.
**Rollback**: Move notes back to original domain directory, delete new domain MOC, update all links and frontmatter domain fields.

## Pattern 3: Pipeline Simplification

**Trigger**: The full 6R pipeline feels burdensome. Processing throughput is low. Inbox grows.
**Diagnosis**: Behavioral or scaling. The pipeline is too heavy for current usage.
**Change**: Drop to a lighter pipeline variant:
- **Standard** (4R): Record -> Reduce -> Reflect -> Verify (drop Reweave, Rethink)
- **Minimal** (2R): Record -> Reduce (capture-focused)
**Research**: Bjork (1994) — desirable difficulty must be calibrated. Difficulty that exceeds capability reduces learning rather than enhancing it.
**Effort**: Low (1-2 hours)
**Reversibility**: Easy (add stages back when capacity increases)
**Risk**: Lighter pipeline produces less deeply processed notes. Acceptable trade-off if the alternative is no processing at all.
**Rollback**: Re-enable dropped pipeline stages in CLAUDE.md and session rhythm.

## Pattern 4: Identity Realignment

**Trigger**: The vault's actual content and usage patterns have diverged from self/identity.md.
**Diagnosis**: Purpose drift. The user's needs evolved but the vault's identity didn't.
**Change**: Rewrite self/identity.md to match actual usage. Update self/goals.md. Regenerate relevant CLAUDE.md sections.
**Research**: Argyris (1977) — mismatch between espoused theory and theory-in-use creates dysfunction. Alignment restores effectiveness.
**Effort**: Low-Medium (2-4 hours)
**Reversibility**: Easy
**Risk**: Minimal. The vault is already operating in the new mode — the identity document is just catching up.
**Rollback**: Restore self/ files from evolution-log.md history.

## Pattern 5: Template Evolution

**Trigger**: Multiple notes consistently diverge from their template's schema. Custom fields keep getting added informally.
**Diagnosis**: Templates have stagnated while usage evolved.
**Change**: Audit existing notes for emergent schema patterns. Update templates to codify the patterns. Re-validate notes against new templates.
**Research**: Piaget (1952) — accommodation: when new information can't be assimilated into existing schemas, the schemas must change.
**Effort**: Medium (4-8 hours)
**Reversibility**: Moderate (old templates can be restored, but notes may have already diverged)
**Risk**: Changing templates affects all future notes. Announce changes clearly. Consider maintaining backward compatibility.
**Rollback**: Restore template files from version history. Existing notes remain valid (new fields are optional at first).

## Pattern 6: Cross-Domain Bridge Creation

**Trigger**: Multiple notes in different domains reference the same underlying concept using different terminology.
**Diagnosis**: Emergent cross-domain pattern that the current structure doesn't capture.
**Change**: Create explicit bridge notes that name the shared concept and link to its manifestation in each domain. Create a cross-domain reflection.
**Research**: Gentner (1983) — structural mapping in analogy. Bridge concepts enable transfer between domains.
**Effort**: Low (1-2 hours)
**Reversibility**: Easy
**Risk**: None. Bridges add value without disrupting existing structure.
**Rollback**: Delete bridge notes and remove their wiki-links from other notes.

## Pattern 7: Archive and Compact

**Trigger**: ops/ has accumulated months of session logs, old health reports, completed tasks.
**Diagnosis**: Normal operations detritus. Not harmful but adds clutter.
**Change**: Move old ops/ files to ops/archive/. Keep recent items (last 30 days) active.
**Research**: Csikszentmihalyi (1990) — clean workspace reduces cognitive friction.
**Effort**: Low (30 minutes)
**Reversibility**: Easy (move files back from archive)
**Risk**: None if recent items are preserved.
**Rollback**: Move files back from ops/archive/.

## Pattern 8: Vault Forking

**Trigger**: A single vault is trying to serve two very different purposes (e.g., research AND personal journaling) and the tension creates friction.
**Diagnosis**: The vault has exceeded its optimal scope.
**Change**: Create a second vault for the secondary purpose. Move relevant notes. Maintain cross-vault references (Obsidian supports multi-vault linking).
**Research**: Tulving (1985) — memory systems are distinct for a reason. Mixing fundamentally different knowledge types creates interference.
**Effort**: High (8+ hours)
**Reversibility**: Difficult (merging vaults is harder than splitting them)
**Risk**: Significant. Only fork when the friction is clearly caused by scope mismatch, not by other issues.
**Rollback**: Merge vaults back together, resolve link conflicts manually.

## Pattern 9: Schema Reconsolidation (v0.7.0)

**Trigger**: Schema compliance is high (>90%) but notes feel formulaic. Placeholder-stuffed fields detected by /vault-tec:friction. Schema serves the system more than the user.
**Diagnosis**: Schema erosion in reverse — the schema was enforced so rigidly that it lost meaning. Fields are filled because they're required, not because they're useful.
**Change**: Audit which fields are actually queried or used in navigation/retrieval. Demote unused required fields to optional. Remove fields nobody queries. Add fields that emerged informally.
**Research**: Sweller et al. (2019) — cognitive load from excessive structure. Schema complexity should serve retrieval, not compliance.
**Effort**: Medium (4-6 hours)
**Reversibility**: Moderate (restored fields need backfilling)
**Risk**: Removing a field that turns out to be useful later requires backfilling. Err on the side of making fields optional before removing.
**Rollback**: Re-add removed fields to templates. Run schema validation to identify notes needing backfill.

## Pattern 10: Triage Sprint (v0.7.0)

**Trigger**: Inbox backlog exceeds 50 items OR inbox age > 30 days. Capture Addiction (F5) detected.
**Diagnosis**: Processing pipeline has stalled. The inbox has become a dumping ground.
**Change**: Dedicated triage session:
1. Sort inbox by age (oldest first)
2. For each item: process (→ atomic note), defer (→ re-date), or discard
3. Target: reduce inbox to <10 items
4. Implement a capture budget: no new captures until inbox < 20
**Research**: Csikszentmihalyi (1990) — flow requires closed loops. GTD (Allen, 2001) — inbox zero as cognitive relief.
**Effort**: Medium-High (depends on backlog size, ~1 hour per 20 items)
**Reversibility**: Easy (items moved to notes/ can be moved back)
**Risk**: Rushed triage produces low-quality notes. Better to discard than to create poor notes.
**Rollback**: Not usually needed — triage is a one-way operation.

## Pattern 11: Hub Distribution (v0.7.0)

**Trigger**: Hub Collapse detected (F8b) or hub vulnerability flagged by integration triggers. A single MOC has >100 incoming links and no redundant navigation paths.
**Diagnosis**: Network topology is fragile. Single point of failure in navigation.
**Change**:
1. Identify the overloaded hub(s)
2. Create parallel navigation paths (topic MOCs that cover the same notes from different angles)
3. Add direct links between related notes that currently only connect through the hub
4. Split the hub into 2-3 sub-hubs with overlapping coverage
**Research**: Albert et al. (2000) — scale-free network vulnerability. Barabasi (2003) — resilience through redundancy.
**Effort**: Medium (4-6 hours)
**Reversibility**: Easy (remove redundant links and merge sub-hubs)
**Risk**: Redundant paths increase maintenance burden. Keep redundancy targeted at critical hubs only.
**Rollback**: Remove parallel MOCs, delete redundant links.

## Pattern 12: Processing Ratio Enforcement (v0.7.0)

**Trigger**: Capture rate exceeds processing rate by >3:1 for two consecutive weeks. Capture Addiction (F5) in its early stages.
**Diagnosis**: The vault is growing in raw material but not in processed knowledge.
**Change**: Enforce a processing ratio: for every N items captured, M must be processed before new captures are allowed.
- **Strict**: 1:1 (capture one, process one)
- **Standard**: 3:1 (capture three, process one)
- **Relaxed**: 5:1 (for burst-capture phases, with scheduled processing)
**Research**: Bjork (1994) — interleaved practice (switching between capture and processing) improves learning. Csikszentmihalyi (1990) — action-feedback loops.
**Effort**: Low (behavioral change, not structural)
**Reversibility**: Easy (relax the ratio)
**Risk**: Too strict a ratio can stifle creative capture bursts. Use "relaxed" during research sprints, "strict" during integration phases.
**Rollback**: Remove ratio enforcement from session rhythm.

## Decision Framework (v0.7.0)

When multiple evolution patterns apply simultaneously, use this priority matrix:

### Priority Order
1. **Structural integrity first**: Fix F1-F3 (schema, MOC, space contamination) before anything else
2. **Processing flow second**: Fix F4-F6 (pipeline, capture addiction, premature evergreen) to restore flow
3. **Connection quality third**: Fix F7-F8 (link decay, echo chambers, hub collapse) to improve retrieval
4. **Identity and automation fourth**: Fix F9-F12 (complacency, fan effect, reweave debt, ossification) for long-term health

### Decision Tree
```
Is the vault structurally broken? (schema <80%, spaces contaminated)
  YES → Pattern 9 (Schema Reconsolidation) or fix templates
  NO ↓
Is processing stalled? (inbox >50, pipeline bottleneck)
  YES → Pattern 10 (Triage Sprint) + Pattern 3 (Pipeline Simplification)
  NO ↓
Are connections degraded? (orphans >8%, broken links >5%)
  YES → Pattern 11 (Hub Distribution) + Pattern 6 (Cross-Domain Bridges)
  NO ↓
Is the vault growing but not deepening?
  YES → Pattern 12 (Processing Ratio) + /vault-tec:reweave
  NO ↓
Is identity stale?
  YES → Pattern 4 (Identity Realignment)
  NO → Vault is healthy. Consider seeding new domains.
```

## Proposal Template

```
PROPOSAL [N]: [Pattern Name]
===================================
Research Basis: [Claim — Author (Year)]
Current State:  [Observation of current friction]
Proposed Change: [Specific modification to make]
Expected Outcome: [What improves and by how much]
Risk: [What could go wrong]
Effort: [Low | Medium | High] — estimated [N] hours
Reversibility: [Easy | Moderate | Difficult]
Rollback: [Specific steps to undo if needed]
Recommendation: [PROCEED | DEFER | INVESTIGATE FURTHER]
```
