---
name: vault-triggers
description: >
  Test-driven knowledge work for Obsidian vaults. Use when the user asks to
  "test my vault", "run triggers", "validate notes", "run quality checks",
  "unit test my knowledge", "integration test", "regression test", or needs
  programmable condition-action triggers for vault quality enforcement.
  Also triggers on "test suite", "trigger system", "quality gates".
version: 0.7.0
---

# Vault Triggers

Programmable test-driven quality enforcement for Obsidian vaults. Applies the principle that knowledge systems should be tested like software: unit tests per note, integration tests across the graph, regression tests for previously-broken items.

## Philosophy

If a vault constraint matters, it should be testable. If it's testable, it should be tested automatically. Triggers are the mechanism: declarative condition→action rules that run at defined execution points.

## Trigger Types

### Unit Triggers (Per-Note)
Test individual notes in isolation:
- Schema compliance (frontmatter fields present and valid)
- Title composability (works as a noun-phrase sentence fragment)
- Link count (meets minimum threshold)
- Description quality (specific enough to distinguish from similar notes)
- Source attribution (claims have sources)
- Confidence calibration (confidence level matches source strength)

### Integration Triggers (Graph-Level)
Test relationships across notes:
- Orphan detection (notes with no incoming or outgoing links)
- Dangling link detection (wiki-links pointing to non-existent notes)
- MOC coverage (every note reachable from a MOC within 3 hops)
- Cluster coherence (domains are internally well-connected)
- Cross-domain bridging (domains have inter-domain connections)
- Hub vulnerability (critical MOCs with no redundant paths)

### Regression Triggers
Track previously-broken items:
- Notes that were flagged and fixed — verify they stay fixed
- Patterns that were remediated — verify they don't recur
- Schema fields that were added — verify they're maintained
- Links that were repaired — verify they don't break again

## Execution

Read `references/trigger-system.md` for the trigger architecture.
Read `references/trigger-templates.md` for pre-built trigger suites.

## Dashboard Output

```
TRIGGER DASHBOARD — [Vault Name] — [Date]
═══════════════════════════════════════════

UNIT TESTS          [████████░░] 47/52 passed (90.4%)
  Schema:           [██████████] 52/52 ✓
  Title:            [███████░░░] 42/52 (10 non-composable)
  Links:            [████████░░] 47/52 (5 under minimum)
  Sources:          [████████░░] 48/52 (4 uncited claims)

INTEGRATION TESTS   [██████████] 6/6 passed (100%)
  Orphans:          0 found ✓
  Dangling links:   0 found ✓
  MOC coverage:     100% ✓
  Cluster coherence: 4/4 domains ✓
  Cross-domain:     12 bridges ✓
  Hub vulnerability: 0 single-points ✓

REGRESSION TESTS    [██████████] 8/8 passed (100%)
  Previously broken: 0 regressions ✓

SUMMARY: 61/66 triggers passed (92.4%)
Trend: ↑ from 87.1% last run
```

## Trigger Effectiveness

Track false positive rate per trigger:
- If a trigger flags >30% of notes and the user consistently overrides → trigger is too sensitive
- If a trigger never flags anything → trigger may be redundant or threshold too loose
- Adjust thresholds based on vault maturity (stricter as vault grows)
