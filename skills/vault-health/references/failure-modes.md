# Failure Modes

Catalogue of known vault failure modes — how vaults degrade, early warning signs, and remediation strategies.

## Structural Failures

### F1: Schema Erosion
**Description**: Gradual loss of YAML frontmatter consistency. Starts with "just this once" and normalizes.
**Early Signs**: Health check shows schema compliance dropping below 90%.
**Root Cause**: Templates not used, hooks disabled, or templates themselves have drifted.
**Remediation**: Re-validate all notes. Fix violations. Re-enable write validation hook. Audit templates.
**Research**: Vaughan (1996) — normalization of deviance.

### F2: MOC Stagnation
**Description**: MOCs stop being updated as new notes are added. Navigation structure calcifies.
**Early Signs**: New notes not reachable from any MOC. MOC last-modified dates are old.
**Root Cause**: MOC updates not part of the session integration phase.
**Remediation**: Run full MOC audit. Update all MOCs with recent notes. Add MOC update to session checklist.
**Research**: Lehman (1980) — software entropy; systems decay without active maintenance.

### F3: Space Contamination
**Description**: Knowledge notes appear in ops/, or operational files appear in notes/.
**Early Signs**: Health check flags cross-contamination.
**Root Cause**: Hurried note creation without proper routing.
**Remediation**: Move misplaced files to correct spaces. Check if the three-space model is clear.

## Processing Failures

### F4: Pipeline Bottleneck
**Description**: Notes accumulate at one stage of the 6R pipeline and don't progress.
**Early Signs**: Status distribution heavily skewed (e.g., 80% seed, 15% growing, 5% evergreen).
**Root Cause**: One pipeline stage is too effortful or unclear.
**Remediation**: Identify the bottleneck stage. Simplify it. Consider dropping to a lighter pipeline variant.
**Research**: Bjork (1994) — desirable difficulty must be achievable, not overwhelming.

### F5: Capture Addiction
**Description**: User captures compulsively but never processes. Inbox grows indefinitely.
**Early Signs**: ops/inbox/ has >50 items. Growing by >10/week with <5 processed/week.
**Root Cause**: Capture feels productive; processing feels like work.
**Remediation**: Implement a capture budget (don't add new items until inbox < 20). Schedule processing sessions.
**Research**: Csikszentmihalyi (1990) — flow requires action-feedback loops; capture without processing breaks the loop.

### F6: Premature Evergreen
**Description**: Notes are marked "evergreen" without passing through full processing.
**Early Signs**: Evergreen notes with minimal connections or unverified claims.
**Root Cause**: Status used as aspiration rather than assessment.
**Remediation**: Run /verify on all evergreen notes. Demote those that don't pass.
**Research**: Lichtenstein et al. (1982) — overconfidence in knowledge calibration.

## Connection Failures

### F7: Link Decay
**Description**: Wiki-links break as notes are renamed, moved, or deleted without updating references.
**Early Signs**: Health check reports broken links > 5%.
**Root Cause**: No referential integrity enforcement.
**Remediation**: Fix all broken links. When renaming/moving, search for references and update them. Consider Obsidian aliases.

### F8: Echo Chamber
**Description**: Dense linking within a subtopic but zero links to other areas. Knowledge silos form.
**Early Signs**: Graph analysis shows isolated clusters with no cross-cluster connections.
**Root Cause**: Only connecting within the current train of thought. No deliberate cross-domain linking.
**Remediation**: Run /reflect specifically looking for cross-domain connections. Create bridge concepts.
**Research**: Gentner (1983) — analogical transfer requires structural mapping across domains.

### F8b: Hub Collapse
**Description**: A critical MOC is deleted, corrupted, or becomes so large it's unusable.
**Early Signs**: Notes becoming unreachable. MOC with >100 links.
**Root Cause**: MOC maintenance neglected. Single point of failure.
**Remediation**: Split oversized MOCs. Ensure multiple paths to every note. Add redundant links.
**Research**: Albert et al. (2000) — scale-free networks are vulnerable to hub removal.

## Identity Failures

### F8c: Purpose Drift
**Description**: The vault's actual content diverges from its stated identity in self/.
**Early Signs**: self/identity.md describes a research vault, but most content is task management.
**Root Cause**: User's needs changed but identity wasn't updated.
**Remediation**: Run /vault-tec:evolve. Update self/ to match actual usage or deliberately refocus.
**Research**: Argyris (1977) — mismatch between espoused theory and theory-in-use.

### F8d: Personality Inconsistency
**Description**: Notes vary wildly in voice, terminology, and style.
**Early Signs**: Reading consecutive notes feels like reading different authors.
**Root Cause**: Self/identity.md is vague, or not read at session start.
**Remediation**: Sharpen identity.md. Add specific terminology and style examples. Enforce session-start orientation.
**Research**: Clark (1996) — common ground requires consistent communication context.

## Automation & Cognitive Failures (v0.7.0)

### F9: Automation Complacency
**Description**: Over-reliance on hooks and automated checks leads to reduced user vigilance. Users assume "if the hook didn't catch it, it's fine" — but hooks can't catch everything (semantic quality, argument coherence, insight depth).
**Early Signs**: Notes pass all schema checks but lack substantive content. Descriptions are formulaic. Connections are technically present but semantically weak.
**Root Cause**: Hooks handle syntax; users abdicate responsibility for semantics.
**Remediation**: Periodically run manual quality audits on hook-passing notes. Add "depth check" to session integration phase — read 2-3 recent notes for substance, not just schema. Consider `/vault-tec:friction` F2 (placeholder-stuffed fields) as an early indicator.
**Research**: Parasuraman & Manzey (2010) — automation complacency; Wickens et al. (2015) — extended findings on trust calibration.
**Detection**: Friction pattern F2 (placeholder-stuffed fields) correlating with high schema compliance scores.

### F10: Fan Effect Overload
**Description**: A note accumulates so many connections that retrieving any single association becomes slow and unreliable — for both human readers and LLM agents scanning the vault.
**Early Signs**: Notes with >15 outgoing wiki-links. Retrieval queries consistently returning too many results. Users or agents struggling to find specific notes in dense clusters.
**Root Cause**: Indiscriminate linking without pruning. "More links = better" assumption.
**Remediation**: Prune weak links (keep reasoning links, remove administrative ones). Split over-connected notes into more specific atomic notes. Use link quality analysis from diagnostics to identify low-value links.
**Research**: Anderson (1974) — fan effect: retrieval time increases with the number of associations. Radvansky & Zacks (2014) — modern confirmation.
**Detection**: Notes where outgoing_links > 15 AND link_quality_reasoning_ratio < 40%.

### F11: Reweave Debt
**Description**: Notes accumulate without backward maintenance. Old notes don't benefit from new knowledge. The vault grows forward but never deepens.
**Early Signs**: Average note age increasing while connection count per old note stays flat. Reweave staleness metric rising. New notes don't link to notes older than 30 days.
**Root Cause**: Forward creation feels productive; backward maintenance feels tedious. No systematic reweave triggers.
**Remediation**: Enable `/vault-tec:reweave` as a session-start suggestion. Start with 1-2 notes per session. Focus on notes with lowest connection density first.
**Research**: Ebbinghaus (1885) — spaced revisiting strengthens retention. Bjork (1994) — retrieval practice benefits from distributed intervals.
**Detection**: reweave_debt metric > 30 notes OR notes_unreweaved_pct > 50%.

### F12: Identity Ossification
**Description**: The opposite of Purpose Drift — self/ files haven't changed in months even as vault content evolves significantly. Identity is frozen while knowledge grows.
**Early Signs**: self/ last-modified dates >90 days old. Vault has grown >50% since last self/ update. Goals in self/goals.md completed but not replaced.
**Root Cause**: Identity updates feel like a separate task rather than natural evolution. SessionEnd hook not prompting self/ review.
**Remediation**: Add self/ review to monthly slow reconciliation loop. Check if self/goals.md still reflects active priorities. Update self/identity.md if vault usage patterns have shifted.
**Research**: Markus & Wurf (1987) — dynamic self-concept; identity should update with experience.
**Detection**: self_change_frequency = 0 for >60 days AND notes_growth_rate > 10%/month.

## Recovery Protocol

For any failure mode:
1. **Diagnose**: Run /vault-tec:health for objective assessment
2. **Prioritize**: Fix structural issues before content issues
3. **Isolate**: Work on one failure at a time to avoid cascading changes
4. **Fix**: Apply remediation with minimal blast radius
5. **Verify**: Re-run health check after fixes
6. **Log**: Record what happened and what fixed it in self/evolution-log.md
7. **Prevent**: Enable or adjust hooks to prevent recurrence
8. **Regress** (v0.7.0): Add fixed items to regression trigger watchlist to prevent recurrence
