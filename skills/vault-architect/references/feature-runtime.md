# Feature Block: Runtime

**New in v0.7.0**
**Kernel Primitives**: (extends maintenance-hooks, evolution-tracking)
**Generates**: Runtime section of CLAUDE.md

## Purpose

Define how the vault monitors itself as a runtime environment — tracking identity stability, metabolic rates, reconciliation status, and desired-state alignment. This is the self-awareness layer that makes the vault a living system rather than a static archive.

## Generated Content Pattern

```markdown
## Runtime

### Vault-as-Runtime
This vault is the persistent substrate of your cognition. Monitor it like a runtime environment:

### Metabolic Tracking
Track change rates per space:
- **self/**: Target <{{MAX_SELF_CHANGES}}/month. Changes here are identity events — log each one.
- **notes/**: Target {{TARGET_NOTES_PER_WEEK}} notes/week. Stagnation = knowledge work stopped.
- **ops/**: No upper bound. High churn is healthy for operations.

Flag: self/ changing >{{MAX_SELF_CHANGES}}/month, notes/ at 0 for >2 weeks, ops/ at 0 for >1 week.

### Reconciliation
Three loops keep the vault aligned:
- **Fast** (every write): Schema + links validated by hooks
- **Medium** (every session start): Health snapshot + inbox triage + reweave candidates
- **Slow** (monthly or when health <70): Full audit via /vault-tec:runtime

### Desired State
Maintain targets in `self/desired-state.yaml`. At session start, report gaps:
- Orphan rate: actual vs. {{TARGET_ORPHAN_RATE}}%
- Reweave debt: notes past {{REWEAVE_STALENESS_DAYS}}-day threshold
- Schema compliance: actual vs. 100%
- Status distribution: actual vs. target ranges

### Attention Budget
Context window is finite. Minimize vault overhead:
- Session orientation should take <30 seconds of context
- Retrieval should reach any note in ≤3 MOC hops
- Spreading activation: decay={{DECAY_RATE}}, threshold={{ACTIVATION_THRESHOLD}}, max_depth={{MAX_TRAVERSAL_DEPTH}}
```

## Adaptation Variables

| Variable | Default | Description |
|----------|---------|-------------|
| MAX_SELF_CHANGES | 2 | Monthly self/ change budget before warning |
| TARGET_NOTES_PER_WEEK | 5-20 | Healthy knowledge creation rate |
| TARGET_ORPHAN_RATE | 0 | Desired orphan percentage |
| REWEAVE_STALENESS_DAYS | 60 | Days before a note is flagged for reweave |
| DECAY_RATE | 0.15 | Spreading activation decay per hop |
| ACTIVATION_THRESHOLD | 0.3 | Minimum activation to include in results |
| MAX_TRAVERSAL_DEPTH | 3 | Maximum hops for concept search |
