# Reconciliation Loops

Three-timescale feedback system that keeps the vault aligned with its intended state.

## Fast Loop (Write-Time)

**Trigger**: Every Write to notes/
**Executor**: PreToolUse:Write and PostToolUse:Write hooks
**Checks**:
- Schema validation (frontmatter fields present and valid)
- Title composability (noun phrase, works as sentence fragment)
- Link minimum (≥2 wiki-links for atomic notes)
- Referential integrity (wiki-links resolve to existing files)
- Domain consistency (note's domain matches its directory)
**Response time**: Immediate (within the write operation)
**Action on failure**: Warn with specific fix suggestion. Do not block.

## Medium Loop (Session-Start)

**Trigger**: SessionStart hook
**Executor**: SessionStart hook prompt
**Checks**:
- Health snapshot (note counts, status distribution)
- Inbox pressure (count and age of inbox items)
- Reweave candidates (notes past staleness threshold)
- Deferred items from previous session
- CLAUDE.md staleness
**Response time**: First 30 seconds of session
**Action on failure**: Surface in session orientation message. Prioritize top 2 issues.

## Slow Loop (Monthly Audit)

**Trigger**: Manual via /vault-tec:runtime or when session-start health snapshot shows score <70
**Executor**: vault-runtime skill (full scan)
**Checks**:
- Full identity coherence audit
- Metabolic rate trends (is knowledge work accelerating, decelerating, or stable?)
- Architecture fitness (does the current structure serve current usage patterns?)
- Gap report against desired state
- Evolution recommendations (should patterns from vault-evolution be applied?)
**Response time**: 2-5 minutes (full vault scan)
**Action on failure**: Generate detailed report with prioritized recommendations. Suggest /vault-tec:evolve if architectural changes are indicated.

## Desired State Configuration

Users configure vault targets in `self/desired-state.yaml`:

```yaml
# Vault desired state — used by reconciliation loops
desired_state:
  # Quality targets
  orphan_rate: 0
  min_connections_per_note: 3
  schema_compliance: 100
  
  # Processing targets  
  max_inbox_age_days: 7
  max_inbox_count: 20
  target_status_distribution:
    seed: [20, 30]      # min%, max%
    growing: [45, 55]
    evergreen: [15, 25]
  
  # Maintenance targets
  reweave_staleness_days: 60
  max_moc_links: 50
  health_check_frequency: weekly
  
  # Identity targets
  max_self_changes_per_month: 2
  claude_md_max_staleness_days: 30
```

## Reconciliation Report Format

```
RECONCILIATION REPORT — [Vault Name]
Date: [YYYY-MM-DD]
Loop: [fast|medium|slow]
═══════════════════════════

CHECKS RUN: [N]
PASSED: [N] | WARNED: [N] | FAILED: [N]

FINDINGS:
[P1] [description] — [specific file/metric]
     Current: [value] | Desired: [value] | Trend: [↑↓→]
     Action: [specific recommendation]

[P2] ...

SUMMARY:
Overall alignment: [N]% with desired state
Trend: [improving|stable|degrading] (vs. last [loop type] run)
Next [loop type] check: [date/trigger]
```
