# Runtime Metrics

Definitions for all metrics tracked by the vault-runtime skill.

## Identity Metrics

| Metric | Definition | Healthy | Warning | Critical |
|--------|-----------|---------|---------|----------|
| Self-change frequency | Number of self/ file modifications per month | <2/month | 3-5/month | >5/month |
| Identity coherence | Do self/identity.md, self/goals.md, and actual vault usage align? | All aligned | Minor drift | Major contradiction |
| CLAUDE.md staleness | Days since CLAUDE.md was regenerated vs. last self/ change | <30 days | 30-90 days | >90 days |
| Evolution log gaps | Modifications to self/ without evolution-log entries | 0 gaps | 1-2 gaps | >2 gaps |

## Metabolic Metrics

| Space | Metric | Healthy Rate | Warning | Critical |
|-------|--------|-------------|---------|----------|
| self/ | Changes per month | 0-2 | 3-5 (unstable) | >5 (identity crisis) |
| notes/ | New notes per week | 5-20 | 1-4 (stagnant) | 0 (dormant) |
| notes/ | Notes modified per week | 3-15 | 0-2 (static) | 0 (fossilized) |
| ops/ | Sessions per week | 2-7 | 1 (sporadic) | 0 (abandoned) |
| ops/ | Inbox processing rate | >80% weekly | 50-79% | <50% (backlog) |

## Attention Budget Metrics

The vault competes with the agent's context window. These metrics help manage that budget.

| Metric | Definition | Calculation |
|--------|-----------|-------------|
| Context load estimate | How much context vault orientation consumes | Count of self/ files × avg size + inbox count × 50 tokens |
| Retrieval depth cost | Average hops needed to find relevant notes | Mean shortest path from MOC to leaf notes |
| Navigation overhead | Percentage of vault unreachable in 3 MOC hops | (Unreachable notes / Total notes) × 100 |
| Spreading activation cost | Estimated tokens for a concept search | Avg notes visited per query × avg note size in tokens |

## Composite Runtime Score

```
RUNTIME_SCORE = (
  identity_stability × 0.25 +
  metabolic_health × 0.25 +
  reconciliation_currency × 0.25 +
  desired_state_alignment × 0.25
)
```

Each sub-score is 0-100. Thresholds: Healthy ≥80, Attention 60-79, Critical <60.
