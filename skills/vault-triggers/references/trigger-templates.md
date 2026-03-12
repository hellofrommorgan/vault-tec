# Trigger Templates

Pre-built trigger suites for common quality enforcement needs.

## Standard Unit Suite (6 triggers)

Apply to every note in notes/:

| # | Trigger | Check | Severity | Auto-fix |
|---|---------|-------|----------|----------|
| U1 | Schema compliance | yaml_frontmatter_valid | error | No |
| U2 | Title composability | title_composable | warning | Suggest |
| U3 | Link minimum | link_count_minimum (≥2) | warning | Suggest connections |
| U4 | Description quality | description_quality (10-50 words) | info | No |
| U5 | Source attribution | source_attribution | warning | No |
| U6 | Confidence calibration | confidence_calibrated | info | No |

## Standard Integration Suite (6 triggers)

Apply to the vault graph as a whole:

| # | Trigger | Check | Severity | Threshold |
|---|---------|-------|----------|-----------|
| I1 | Orphan detection | orphan_scan | error | 0 orphans |
| I2 | Dangling links | dangling_link_scan | error | 0 dangling |
| I3 | MOC coverage | moc_coverage (3 hops) | warning | 100% coverage |
| I4 | Cluster coherence | cluster_coherence | info | density > 2.0 |
| I5 | Cross-domain bridges | cross_domain_bridges | warning | ≥1 per domain pair |
| I6 | Hub vulnerability | hub_vulnerability | warning | 0 single-points |

## Standard Regression Suite (4 triggers)

Track previously-broken items:

| # | Trigger | Check | Source |
|---|---------|-------|--------|
| R1 | Schema regressions | previously_flagged (schema) | Last health check |
| R2 | Link regressions | previously_flagged (links) | Last health check |
| R3 | Orphan regressions | pattern_recurrence (orphans) | Last remediation |
| R4 | MOC regressions | pattern_recurrence (unreachable) | Last remediation |

## Domain-Specific Templates

### Research Vault
Add to standard suites:
- U7: Citation density (every 3rd paragraph should reference a source)
- I7: Methodology coverage (every claim domain has ≥3 supporting sources)

### Creative Vault
Relax from standard suites:
- U5: Source attribution → severity: info (creative notes may not cite)
- U6: Confidence → disabled (not applicable to creative work)

### Engineering Vault
Add to standard suites:
- U7: Code reference (technical notes should link to implementations)
- I7: Decision trail (architecture decisions have ADR-style reasoning)

## Custom Trigger Template

```yaml
trigger:
  name: "[descriptive-name]"
  type: [unit|integration|regression]
  description: "[what this trigger checks]"
  condition:
    scope: "[glob pattern]"
    check: "[check function]"
    parameters: {}
  action:
    on_pass: "silent"
    on_fail: "[warn|error|info]"
    severity: "[error|warning|info]"
    auto_fix: [true|false]
    fix_suggestion: "[template with {variables}]"
  metadata:
    execution_point: "[on_write|on_session_start|on_demand]"
```
