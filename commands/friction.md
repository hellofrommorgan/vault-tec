---
name: friction
description: "Diagnose architectural friction patterns. Six diagnostic patterns that reveal structural problems."
allowed-tools: ["Read", "Glob", "Grep", "Task"]
---

# /vault-tec:friction

Friction diagnostics command. Identifies patterns in the vault that indicate architectural problems — places where the system's design is fighting the user's workflow.

## The Six Friction Patterns

### F1: Unused Note Types
**Signal**: Note types defined in templates/ but never instantiated in notes/
**Diagnosis**: Template overhead. Types that exist but aren't used add complexity without value.
**Architecture problem**: Over-engineered schema. Types were anticipated but not needed.
**Recommendation**: Remove unused templates, or investigate why they're not being used (maybe the workflow doesn't naturally produce them).

### F2: Placeholder-Stuffed Fields
**Signal**: Required fields filled with generic/empty values ("TBD", "...", empty strings, "TODO")
**Diagnosis**: Schema friction. Fields are required but not useful for the user's workflow.
**Architecture problem**: Schema doesn't match cognitive needs. Required fields should capture information the user naturally produces.
**Recommendation**: Make placeholder-heavy fields optional, or redesign them to capture what the user actually knows at write time.

### F3: Manually-Added Metadata
**Signal**: Metadata that should be automated but is being added by hand (timestamps, link counts, status calculations)
**Diagnosis**: Automation gap. The user is doing work that hooks or tools should handle.
**Architecture problem**: Insufficient automation in the processing pipeline.
**Recommendation**: Add hooks or modify existing ones to auto-populate these fields.

### F4: Navigation Failures
**Signal**: Notes that take >3 MOC hops to reach, or notes the user searches for by filename instead of navigating via MOCs
**Diagnosis**: Navigation structure doesn't match retrieval patterns.
**Architecture problem**: MOC hierarchy doesn't reflect how the user thinks about their knowledge.
**Recommendation**: Reorganize MOCs around actual access patterns, not logical taxonomy. Add shortcut links for frequently-accessed notes.

### F5: Orphaned Pipeline Output
**Signal**: Notes stuck at one pipeline stage (e.g., many "seed" notes that never become "growing")
**Diagnosis**: Pipeline bottleneck. One stage is too effortful or unclear.
**Architecture problem**: Processing pipeline doesn't match available time/energy.
**Recommendation**: Identify the bottleneck stage. Simplify it, or drop to a lighter pipeline variant.

### F6: Oversized MOCs
**Signal**: Any MOC with >50 direct links
**Diagnosis**: MOC is trying to do too much. Navigation burden exceeds cognitive capacity.
**Architecture problem**: Topic grew without spawning sub-MOCs. Missing intermediate organizational layer.
**Recommendation**: Extract coherent subtopic clusters into new topic MOCs. The original MOC becomes a hub-of-hubs.

## Pattern-to-Architecture Mapping

| Pattern | Root Cause | Fix Category |
|---------|-----------|-------------|
| F1 Unused types | Over-engineering | Simplify schema |
| F2 Placeholders | Schema-workflow mismatch | Redesign templates |
| F3 Manual metadata | Automation gap | Enhance hooks |
| F4 Navigation failures | MOC-cognition mismatch | Restructure navigation |
| F5 Pipeline orphans | Processing bottleneck | Simplify pipeline |
| F6 Oversized MOCs | Missing hierarchy | Split MOCs |

## Friction Score

```
FRICTION REPORT — [Vault Name] — [Date]
════════════════════════════════════════

F1 Unused Types:       [N] unused / [M] defined    [░░░░░░░░░░] LOW
F2 Placeholders:       [N] notes with placeholders  [████░░░░░░] MEDIUM
F3 Manual Metadata:    [N] instances detected       [░░░░░░░░░░] LOW
F4 Navigation Fails:   [N] notes >3 hops            [██████░░░░] MEDIUM
F5 Pipeline Orphans:   [N] stuck notes              [████████░░] HIGH
F6 Oversized MOCs:     [N] MOCs >50 links           [░░░░░░░░░░] LOW

COMPOSITE FRICTION: [N]/100 (lower is better)
Trend: [improving|stable|worsening] vs. last run

TOP RECOMMENDATION:
[Most impactful single change based on highest-friction pattern]
```

## Tracking Over Time

Store friction reports in ops/maintenance/friction-[DATE].md. Compare across runs to show improvement or degradation. A friction score that improves over time indicates healthy architectural evolution.
