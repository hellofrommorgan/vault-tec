---
name: vault-runtime
description: >
  Runtime health and identity tracking for Obsidian vaults. Use when the user asks
  about "vault identity", "metabolic rate", "vault shape", "runtime status",
  "reconciliation", "desired state", "gap report", "attention budget", or needs
  to monitor how the vault is changing over time. Also triggers on "runtime",
  "identity dashboard", and "vault-as-runtime".
version: 0.7.0
---

# Vault Runtime

The vault is not a filing system — it is the persistent substrate of agent cognition. This skill treats the vault as a runtime environment: monitoring its health, tracking identity stability, measuring metabolic rates, and running reconciliation loops at three timescales.

## Core Concept

What an agent can think is determined by what its vault contains and how it's structured. Change the vault, you change the agent. This skill makes that relationship visible and manageable.

## Capabilities

### 1. Identity Dashboard
Read `references/runtime-metrics.md` for metric definitions.
- Vault shape: note count, domain distribution, connection topology
- Identity stability: self/ file change frequency and magnitude
- Behavior-impact predictions: "Adding this domain will increase retrieval time by ~15%"
- Growth trajectory: vault size over time with metabolic rates per space

### 2. Metabolic Rate Tracking
Each vault space has a characteristic change rate:
- **self/**: Slow metabolism. Changes here are significant identity events. Healthy: <2 changes/month.
- **notes/**: Steady metabolism. Consistent growth indicates active knowledge work. Healthy: 5-20 notes/week.
- **ops/**: High metabolism. Frequent changes are normal (sessions, tasks, inbox). No upper bound.

Flag anomalies: self/ changing too fast (identity instability), notes/ stagnant (knowledge work stopped), ops/ empty (no operational rhythm).

### 3. Reconciliation Loops
Read `references/reconciliation-loops.md` for the three-timescale spec.
- **Fast** (write-time): Schema validation, link checking — handled by hooks
- **Medium** (session-start): Health snapshot, inbox triage, reweave candidates — handled by SessionStart hook
- **Slow** (monthly): Full audit, identity review, architecture evolution check — manual trigger via /vault-tec:runtime

### 4. Desired-State Configuration
Users define vault targets:
```yaml
desired_state:
  orphan_rate: 0%
  min_connections_per_note: 3
  reweave_staleness_days: 60
  schema_compliance: 100%
  status_distribution:
    seed: 20-30%
    growing: 45-55%
    evergreen: 15-25%
```

### 5. Gap Reports
Compare actual vs desired state. Output:
```
GAP REPORT — [Vault Name] — [Date]
Orphan rate:     actual 3.2% | desired 0% | gap: 3.2% ↑ (was 2.1% last month)
Connections/note: actual 4.1 | desired 3+  | OK ✓
Reweave debt:    12 notes past 60-day threshold | trending: +3/month
Schema:          actual 97%  | desired 100% | 5 violations (list below)
```

## Parallel Research

For the slow reconciliation loop (monthly audit), use the Task tool to launch a subagent that performs a full vault scan without blocking the user's current work.
