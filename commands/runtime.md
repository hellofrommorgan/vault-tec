---
name: runtime
description: "Vault runtime dashboard: identity stability, metabolic rates, reconciliation status, gap report."
allowed-tools: ["Read", "Glob", "Grep", "Task"]
---

# /vault-tec:runtime

Runtime dashboard command. Provides a comprehensive view of the vault as a runtime environment.

## Dashboard Sections

### 1. Identity Status
```
IDENTITY — [Vault Name]
  self/identity.md: [last modified] ([N] days ago)
  self/goals.md:    [last modified] ([N] days ago)
  self/ changes this month: [N] (threshold: {{MAX_SELF_CHANGES}})
  CLAUDE.md staleness: [N] days (threshold: 30)
  Evolution log entries: [N] total, [N] this month
  Status: [STABLE | EVOLVING | UNSTABLE]
```

### 2. Vault Shape
```
SHAPE — [Date]
  Total notes: [N]
  Domains: [N] ([list])
  Notes per domain: [distribution]
  Connection density: [N] links/note
  Status distribution: seed [N]% | growing [N]% | evergreen [N]%
  Hub notes: [N] (>10 incoming links)
  Orphan notes: [N]
```

### 3. Metabolic Rates
```
METABOLISM — [Period]
  self/:  [N] changes ([HEALTHY|WARNING|CRITICAL])
  notes/: [N] created, [N] modified ([HEALTHY|WARNING|CRITICAL])
  ops/:   [N] sessions, [N] tasks processed ([HEALTHY|WARNING|CRITICAL])
  Trend: [accelerating|steady|decelerating]
```

### 4. Reconciliation Status
```
RECONCILIATION
  Fast loop (write-time):    [ACTIVE|DISABLED] — last: [date]
  Medium loop (session-start): [ACTIVE|DISABLED] — last: [date]
  Slow loop (monthly):       [DUE|CURRENT] — last: [date], next: [date]
```

### 5. Gap Report
```
GAP REPORT vs. Desired State
  Orphan rate:      [actual]% vs [target]% — [OK|GAP +N%]
  Connections/note: [actual] vs [target]   — [OK|GAP]
  Reweave debt:     [N] notes past threshold — [OK|ATTENTION|CRITICAL]
  Schema compliance: [actual]% vs 100%     — [OK|GAP]
  Status balance:   [actual distribution] vs [target] — [OK|SKEWED]
```

### 6. Attention Budget
```
ATTENTION BUDGET
  Session orientation cost: ~[N] tokens
  Avg retrieval depth: [N] hops
  Navigation overhead: [N]% unreachable in 3 hops
  Estimated concept search cost: ~[N] tokens/query
```

## Full Dashboard Format
Combine all sections into a single output. Save to ops/maintenance/runtime-[DATE].md.
