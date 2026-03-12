---
description: Get architecture evolution advice for a vault
allowed-tools: Read, Grep, Glob, Bash(ls:*, tree:*, find:*)
argument-hint: [optional: vault-path]
---

Analyze a vault's current state and provide research-backed evolution guidance. This merges the functions of arscontexta's architect and recommend skills into a single evolution advisor.

Load the vault-evolution skill from `${CLAUDE_PLUGIN_ROOT}/skills/vault-evolution/SKILL.md`.

## Phase 1: Situational Analysis

1. Locate the vault (from `$1` or current directory)
2. Read `self/evolution-log.md` to understand the vault's history
3. Read `self/goals.md` to understand current objectives
4. Run a lightweight health check (schema compliance + connection density)
5. Read recent session logs from `ops/sessions/`
6. Identify friction patterns:
   - Are notes piling up in inbox without processing?
   - Are MOCs getting too large (>50 links)?
   - Are certain domains growing while others stagnate?
   - Has the vault's identity drifted from its original purpose?

## Phase 2: Research-Grounded Diagnosis

Map observed friction to research claims:
- Read `${CLAUDE_PLUGIN_ROOT}/skills/vault-methodology/references/evolution-and-maintenance.md`
- Read `${CLAUDE_PLUGIN_ROOT}/skills/vault-evolution/references/evolution-patterns.md`
- For each friction pattern, find the relevant cognitive science backing
- Identify whether friction is structural (architecture problem) or behavioral (usage problem)

## Phase 3: Evolution Proposals

Generate 2-3 ranked proposals, each with:

```
PROPOSAL [N]: [Name]
Research Basis: [Claim + citation]
Current State: [What's happening now]
Proposed Change: [Specific architectural modification]
Expected Outcome: [What improves]
Risk: [What could go wrong]
Effort: [Low/Medium/High]
Reversibility: [Easy/Moderate/Difficult]
```

Prioritize proposals by impact-to-effort ratio. Always prefer reversible changes.

## Phase 4: Implementation (if approved)

If the user approves a proposal:
1. Create a backup note in `ops/maintenance/pre-evolution-[date].md`
2. Execute the architectural changes
3. Update `self/evolution-log.md` with what changed and why
4. Update `self/methodology.md` if the change affects processing
5. Update CLAUDE.md if system behavior needs to change
6. Run a post-evolution health check
