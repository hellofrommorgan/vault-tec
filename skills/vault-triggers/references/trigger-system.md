# Trigger System Architecture

Programmable condition→action triggers for vault quality enforcement.

## Trigger Definition Format

```yaml
trigger:
  name: "schema-compliance"
  type: unit          # unit | integration | regression
  description: "Verify all YAML frontmatter fields are present and valid"
  
  condition:
    scope: "notes/**/*.md"
    check: "yaml_frontmatter_valid"
    parameters:
      required_fields: [type, domain, created, status, connections]
      type_specific: true
  
  action:
    on_pass: "silent"
    on_fail: "warn"
    severity: "error"     # error | warning | info
    auto_fix: false
    fix_suggestion: "Add missing fields: {missing_fields}"
  
  metadata:
    execution_point: "on_demand"   # on_write | on_session_start | on_demand
    false_positive_rate: 0.0
    last_run: null
    total_runs: 0
    total_flags: 0
```

## Execution Points

| Point | When | Triggers |
|-------|------|----------|
| on_write | After every Write to notes/ | Unit triggers only (fast) |
| on_session_start | During SessionStart hook | Integration triggers (medium) |
| on_demand | When user runs /vault-tec:triggers | All triggers (comprehensive) |

## Trigger Evaluation Algorithm

1. **Scope resolution**: Glob the scope pattern to get target files
2. **Condition check**: Run the check function against each target
3. **Result collection**: Aggregate pass/fail/skip per trigger
4. **Action execution**: Apply actions based on results
5. **Effectiveness update**: Update false_positive_rate and run counts
6. **Dashboard generation**: Format results into dashboard output

## Built-in Check Functions

### Unit Checks
- `yaml_frontmatter_valid` — All required fields present with valid values
- `title_composable` — H1 title is a noun phrase (no verbs at start, no question marks)
- `link_count_minimum` — Body contains ≥N wiki-links
- `description_quality` — Description field is ≥10 words and ≤50 words
- `source_attribution` — Atomic notes with claims have ≥1 source
- `confidence_calibrated` — Confidence level matches source strength heuristic

### Integration Checks
- `orphan_scan` — Find notes with 0 incoming AND 0 outgoing links
- `dangling_link_scan` — Find wiki-links pointing to non-existent files
- `moc_coverage` — Every note reachable from a MOC within N hops
- `cluster_coherence` — Intra-domain connection density > threshold
- `cross_domain_bridges` — Inter-domain connections exist
- `hub_vulnerability` — No single-point-of-failure MOCs

### Regression Checks
- `previously_flagged` — Notes in regression watchlist still pass their original trigger
- `pattern_recurrence` — Failure patterns that were fixed haven't returned
