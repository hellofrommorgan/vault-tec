# Feature Block: Quality

**Merges**: maintenance.md + ethical-guardrails.md + helper-functions.md
**Kernel Primitives**: maintenance-hooks, ethical-guardrails, evolution-tracking
**Generates**: Quality section of CLAUDE.md

## Purpose

Define automated quality enforcement, safety guardrails, and operational helper commands — the immune system that keeps the vault healthy.

## Generated Content Pattern

The Quality section of CLAUDE.md should contain ONLY enforceable rules — no explanations, no prose, no research citations. Every rule must be specific enough that compliance is binary (pass/fail).

```
## Quality

### Enforcement Rules
- Every claim in an atomic note must reference a source via the `sources:` frontmatter field
- Every note write to notes/ must pass schema validation (hook-enforced)
- Never modify self/ files without appending an entry to self/evolution-log.md
- Never create a note in notes/ without complete YAML frontmatter matching its type template
- Never leave a note with 0 wiki-link connections (incoming or outgoing)
- Never place knowledge notes in ops/ or operational files in notes/
- Never delete notes without explicit user confirmation
- Set the `confidence:` field on every atomic note: low | medium | high
- Do not default confidence to "high" — assess honestly based on source strength
- When uncertain about a claim, use `confidence: low` and note the uncertainty in the body
- Maintain referential integrity: if a note links to [[X]], X must exist as a file
- When updating linked notes, verify the link context still makes sense

### Hook Enforcement Specification (v0.7.0)

Hooks are the immune system. They WARN, not silently pass.

| Hook | Trigger | Checks | On Failure |
|------|---------|--------|-----------|
| PreToolUse:Write | Any Write to notes/*.md | Schema validation, title composability, link minimum | WARN with specific error + auto-fix suggestion |
| PostToolUse:Write | After Write to notes/*.md | Referential integrity, orphan detection, domain consistency | Advisory report (non-blocking) |
| SessionStart | Session begins | Identity anchor, health snapshot, reweave candidates, deferred items | Surface in orientation message |
| SessionEnd | Session ends | Session log generation, findings triage, continuity prep | Mandatory — cannot skip |

**Enforcement philosophy**: Hooks warn loudly but don't block. The user always has final authority. But warnings must be specific enough to act on — "schema violation" is not enough; "missing 'confidence' field on atomic-note, suggest: confidence: medium" is.

### Test-Driven Quality (v0.7.0)

Beyond hooks, the vault supports programmable triggers:
- **Unit triggers**: Per-note checks (schema, title, links, sources, confidence)
- **Integration triggers**: Graph-level checks (orphans, dangling links, MOC coverage, cluster coherence)
- **Regression triggers**: Track previously-broken items to prevent recurrence

Run via `/vault-tec:triggers`. See vault-triggers skill for full specification.

### Maintenance Schedule
- {{HEALTH_FREQUENCY}}: Run `/vault-tec:health` for full diagnostic
- Monthly: Run `/vault-tec:evolve` for architecture review
- Monthly: Run slow reconciliation loop via `/vault-tec:runtime`
- As needed: Process inbox backlog with `/pipeline`
- Session-start: Run `/vault-tec:reweave` for 1-2 stale note suggestions

### Drift Signals
Watch for:
- ops/inbox/ growing faster than processing → increase processing sessions
- Any MOC exceeding 50 direct links → split into sub-MOCs
- Notes clustering in one domain while others stagnate → rebalance seeding
- Schema violations increasing → audit templates for drift
- self/ files changing frequently → identity instability, re-anchor
- Notes passing hooks but lacking substance → automation complacency (F9)
- Notes with >15 links → fan effect risk (F10)

### Commands

**Processing**:
- `/reduce [note]` — Extract core insight, draft atomic structure
- `/reflect [note]` — Find connections, suggest wiki-links, identify cross-domain bridges
- `/reweave [note]` — Update with context from linked notes, propagate implications
- `/verify [note]` — Schema compliance + link integrity + source attribution check
- `/rethink [note]` — Challenge assumptions, find counter-evidence, stress-test claims
- `/pipeline [note]` — Full 6R sequence (each R in fresh context)

**Navigation**:
- `/graph` — Vault topology: nodes, edges, hubs, orphans, clusters
- `/stats` — Note count, connection density, status distribution
- `/next` — Highest-value next action based on current vault state

**Session**:
- `/seed [topic]` — Queue a research seeding task in ops/tasks/
- `/tasks` — List active tasks from ops/tasks/
- `/remember` — Mine current session for insights, create reflection notes
- `/learn [topic]` — Quick research burst on a specific concept

**Maintenance**:
- `/validate` — Schema validation across all notes, report violations

**Maintenance (v0.7.0)**:
- `/vault-tec:reweave` — Surface stale notes, guided backward maintenance
- `/vault-tec:friction` — Diagnose architectural friction patterns
- `/vault-tec:runtime` — Identity dashboard, metabolic rates, gap report
- `/vault-tec:triggers` — Run test suite (unit/integration/regression)
```

## Adaptation Variables

- `{{HEALTH_FREQUENCY}}` — How often to suggest health checks (weekly/biweekly/monthly)
- `{{GUARDRAIL_STRICTNESS}}` — How strict the guardrails are:
  - **strict**: All rules enforced, no exceptions
  - **standard**: Core rules enforced, drift signals monitored
  - **relaxed**: Basic schema enforcement only
- `{{HELPER_SET}}` — Which commands to include (not all vaults need all commands)
