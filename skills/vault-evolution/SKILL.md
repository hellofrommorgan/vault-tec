---
name: vault-evolution
description: >
  Architecture evolution guidance for Obsidian vaults. Use when the user
  asks to "evolve my vault", "improve vault architecture", "my vault feels
  wrong", "restructure my notes", "vault is getting messy", "refactor my
  knowledge system", or needs guidance on when and how to change vault
  structure. Also triggers on "drift", "friction", "architectural review",
  and "vault refactoring". Merges arscontexta's architect and recommend skills.
version: 0.1.0
---

# Vault Evolution

Guidance engine for evolving vault architecture over time. Combines the diagnostic eye of an architect with research-backed recommendations for structural change. Derived from arscontexta's architect + recommend skills (merged for 50% component reduction, 100% functional coverage).

## When to Evolve

Evolution is appropriate when:
- Health scores drop below 80 consistently
- The user reports friction ("this doesn't feel right", "I can't find things")
- The vault's actual usage has diverged from its stated identity
- A domain has grown large enough to need sub-structuring
- Cross-domain patterns are emerging that the current structure doesn't capture
- A significant life/work change has shifted the vault's purpose

Evolution is NOT appropriate when:
- The vault is new (< 50 notes) — too early to judge
- Minor issues that health checks can fix — use /vault-tec:health instead
- The user is in a productive flow — don't interrupt with structural changes

## Evolution Process

Read `references/evolution-patterns.md` for the full pattern catalogue.

### Phase 1: Situational Analysis
1. Read `self/evolution-log.md` — understand the vault's architectural history
2. Read `self/goals.md` — understand what the vault is trying to accomplish
3. Run a lightweight health diagnostic (5 checks)
4. Read recent session logs — understand current usage patterns
5. Map friction to specific architectural elements

### Phase 2: Research-Grounded Diagnosis
1. For each friction point, find the relevant methodology claim
2. Determine if the friction is:
   - **Structural** (the architecture doesn't fit the use case) → needs evolution
   - **Behavioral** (the user isn't following the existing architecture) → needs coaching
   - **Scaling** (the architecture was fine but outgrew itself) → needs expansion
3. Differentiate: don't restructure when coaching would fix the problem

### Phase 3: Proposal Generation
Generate 2-3 proposals ranked by impact-to-effort ratio. Read `references/evolution-patterns.md` for the proposal template.

Every proposal must include:
- Research basis (specific cognitive science claim)
- Current state (what's happening now)
- Proposed change (specific modification)
- Expected outcome (what improves)
- Risk assessment (what could go wrong)
- Effort estimate (Low/Medium/High)
- Reversibility (Easy/Moderate/Difficult)

Always prefer reversible changes.

### Phase 4: Implementation (if approved)
1. Backup: Create pre-evolution snapshot in ops/maintenance/
2. Execute: Make the structural changes
3. Update: Modify self/ files to reflect the new architecture
4. Regenerate: Update CLAUDE.md if system behavior needs to change
5. Validate: Run post-evolution health check
6. Log: Record everything in self/evolution-log.md

## Conversation Patterns

Read `references/conversation-patterns.md` for effective interaction templates for evolution discussions.
