# vault-tec

**Your knowledge, preserved for the future. Vault-Tec -- because the best time to build a vault was before the bombs dropped.**

vault-tec is a [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin that creates and manages agent-native [Obsidian](https://obsidian.md) knowledge vaults. Every architectural decision is grounded in cognitive science research -- from memory systems (Tulving 1985) to spreading activation (Collins & Loftus 1975) to cognitive chunking (Miller 1956). You bring the knowledge; vault-tec builds the shelter it deserves.

---

## Features

| | Feature | What You Get |
|---|---|---|
| **15** | Kernel Primitives | Irreducible architectural decisions, each backed by cognitive science |
| **8** | Feature Generators | Modular CLAUDE.md generation from conversation-derived configuration |
| **83** | Research Claims | Consolidated findings across 6 cognitive science domains |
| **7** | Hooks | Real-time quality enforcement on every write, session, and compaction |
| **11** | Commands | From vault creation to friction diagnostics |
| **8** | Skills | Deep reference knowledge loaded on demand |
| **1** | Agent | Proactive architectural advisor with measurable activation triggers |

Plus: **S.P.E.C.I.A.L. health dashboard**, **Bobblehead milestone system**, and a **vault-as-runtime** architecture that treats your vault as a living cognitive substrate -- not a filing cabinet.

---

## Installation

Clone the repo and install as a Claude Code plugin:

```bash
git clone https://github.com/agenticnotetaking/vault-tec.git
claude plugin add /path/to/vault-tec
```

Then run the interactive setup to configure vault-tec for your environment:

```bash
/vault-tec:setup
```

### GitHub Copilot CLI (optional)

vault-tec also runs inside [GitHub Copilot CLI](https://github.com/github/copilot-cli) via a Node adapter that shells out to the same bash hooks. `/vault-tec:setup` detects Copilot CLI and offers to install it; or install manually:

```bash
mkdir -p ~/.copilot/extensions/vault-tec
cp copilot-extension/extension.mjs ~/.copilot/extensions/vault-tec/
ln -sfn "$PWD/hooks/scripts" ~/.copilot/extensions/vault-tec/scripts
```

| Claude Code hook       | Copilot CLI hook         | Status          |
|------------------------|--------------------------|-----------------|
| PreToolUse             | `onPreToolUse`           | ✅ direct       |
| PostToolUse            | `onPostToolUse`          | ✅ direct       |
| PostToolUseFailure     | `onPostToolUse` (guard)  | ✅ routed       |
| SessionStart           | `onSessionStart`         | ✅ direct       |
| SessionEnd             | `onSessionEnd`           | ✅ direct       |
| UserPromptSubmit       | `onUserPromptSubmitted`  | ✅ direct       |
| PreCompact             | *(none in Copilot)*      | 🟡 emulated via `vault_tec_preserve_state` tool |
| *(new)*                | `onErrorOccurred`        | ✅ routed to post-tool-use handler |

See [`copilot-extension/README.md`](./copilot-extension/README.md) for adapter design details.

---

## Quick Start

```bash
# 1. Configure vault-tec (interactive — one-time setup)
/vault-tec:setup

# 2. Create a new vault (interactive — derives architecture from conversation)
/vault-tec:create-vault MyVault ~/

# 3. Seed it with deep research on a topic
/vault-tec:seed "quantum computing" ~/MyVault

# 4. Check its health
/vault-tec:health ~/MyVault

# 5. See what to work on next
/vault-tec:runtime ~/MyVault
```

---

## Commands

| Command | Description |
|---------|-------------|
| `/vault-tec:setup` | Interactive onboarding and configuration |
| `/vault-tec:create-vault` | Create a new vault through conversational derivation |
| `/vault-tec:seed` | Seed a vault with deep, multi-phase research on a topic |
| `/vault-tec:health` | Run S.P.E.C.I.A.L. dashboard + 5-check diagnostic battery |
| `/vault-tec:ask` | Query the 83-claim methodology research graph |
| `/vault-tec:evolve` | Get research-backed architecture evolution advice |
| `/vault-tec:guide` | Interactive tutorial and help for any feature |
| `/vault-tec:reweave` | Surface stale notes for guided backward maintenance |
| `/vault-tec:friction` | Diagnose six architectural friction patterns |
| `/vault-tec:runtime` | Identity dashboard, metabolic rates, gap report |
| `/vault-tec:triggers` | Run test suite (unit / integration / regression) |

## Skills

| Skill | Purpose |
|-------|---------|
| `vault-setup` | Interactive onboarding -- vault location, companion identity, processing preferences, monitoring, hooks |
| `vault-architect` | Core vault architecture -- 15 kernel primitives, three-space model, 8 feature generators, note templates |
| `research-seeder` | 7-phase research pipeline with error handling, quality gates, and parallel merge strategy |
| `vault-methodology` | 83 research claims across 6 cognitive science domains + post-2016 additions |
| `vault-health` | 5-check diagnostic battery with pipeline health formulas and inter-metric validation |
| `vault-evolution` | 12 evolution patterns with decision framework, rollback procedures, and time estimates |
| `vault-runtime` | Runtime health: identity tracking, metabolic rates, reconciliation loops, desired-state gap reports |
| `vault-triggers` | Test-driven knowledge work: unit / integration / regression triggers with effectiveness tracking |

## Hooks

| Hook | Type | Purpose |
|------|------|---------|
| Schema Enforcement | `PreToolUse:Write` | Validates YAML schema, title composability, link minimums on every note write |
| Referential Integrity | `PostToolUse:Write\|Edit` | Checks wiki-link resolution and orphan detection after writes and edits |
| Session Start | `SessionStart` | Pip-Boy status line, identity, health snapshot, working memory, active patterns |
| Session End | `SessionEnd` | Logs session, rotates heartbeat, prepares continuity for next session |
| Pattern Injection | `UserPromptSubmit` | Injects active vault patterns on vault-related prompts |
| Compaction Snapshot | `PreCompact` | Preserves working memory and active patterns across context compaction |
| Failure Logging | `PostToolUseFailure:Write\|Edit` | Surfaces vault write/edit failures with diagnostic context |

---

## Architecture

Vaults follow a **three-space model** separating identity, knowledge, and operations into distinct growth-rate zones:

```
vault/
├── self/        ← Identity (slow growth: who the agent is, goals, methodology)
├── notes/       ← Knowledge (steady growth: atomic notes, MOCs, source notes)
├── ops/         ← Operations (high churn: sessions, inbox, tasks, maintenance)
├── templates/   ← Note type schemas (single source of truth)
└── CLAUDE.md    ← Generated agent prompt (composed from 8 feature blocks)
```

**self/** changes rarely but matters enormously. **notes/** grows steadily through the 6R processing pipeline. **ops/** churns daily and is disposable. Cross-contamination between spaces is a failure mode (F3) that health checks flag automatically.

---

## S.P.E.C.I.A.L. Health Dashboard

Run `/vault-tec:health` and the first thing you see is this:

```
╔══════════════════════════════════════════════════════════════════════╗
║              VAULT-TEC S.P.E.C.I.A.L. DIAGNOSTICS                  ║
║              Vault: MyVault                                         ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  S — Structure      ████████░░   8/10  (82% schema-compliant)       ║
║  P — Propagation    ██████████  10/10  (5.2 links/note avg)         ║
║  E — Evergreen %    ████░░░░░░   4/10  (22% evergreen)              ║
║  C — Coverage       ███████░░░   7/10  (74% map-covered)            ║
║  I — Intake         ██████████  10/10  (0 inbox items)              ║
║  A — Activity       ██████░░░░   6/10  (12 notes / 7 days)          ║
║  L — Longevity      █████░░░░░   5/10  (48% rewoven)                ║
║                                                                      ║
╠══════════════════════════════════════════════════════════════════════╣
║  COMPOSITE: 7.1/10   [ GOOD ]                                       ║
╠══════════════════════════════════════════════════════════════════════╣
║  142  notes | 8   maps | 31   evergreen | 738   total links          ║
╚══════════════════════════════════════════════════════════════════════╝
```

| Stat | Measures | What it tracks |
|------|----------|----------------|
| **S**tructure | Schema compliance | YAML frontmatter validity across all notes |
| **P**ropagation | Connection density | Average wiki-links per note |
| **E**vergreen % | Maturity ratio | Percentage of notes at evergreen status |
| **C**overage | Map coverage | Percentage of notes reachable from a map |
| **I**ntake | Inbox health | Inbox item count (lower is better) |
| **A**ctivity | Metabolic rate | Notes created or modified in the last 7 days |
| **L**ongevity | Reweave freshness | Percentage of old notes recently revisited |

The dashboard runs in under 5 seconds and gives you an instant read on vault health before diving into the full diagnostic battery.

### Pip-Boy Status Line

Every session starts with a one-liner pulse check -- your vault's vital signs at a glance:

```
⚡ MyVault | 1049 notes | GOOD (7.1) | 3 inbox | 2 orphans | 12 mR
```

Runs in ~1 second (computes a fast 5-stat composite, skipping the expensive Coverage and Longevity calculations). Think of it as the Pip-Boy status bar vs. the full medical exam.

---

## Rad Counter

Every vault accumulates contamination over time -- orphaned notes, broken links, schema violations. The Rad Counter measures it in **millirems (mR)** so you always know how clean your vault is:

```
☢ CONTAMINATION REPORT
  RAD LEVEL: MODERATE (27 mR)
  ├─ 5 orphaned notes (10 mR)
  ├─ 2 dangling links (6 mR)
  ├─ 14 inbox items (7 mR)
  ├─ 4 stale notes (4 mR)
  └─ 0 schema violations (0 mR)

  Decontamination: Run /vault-tec:reweave for orphans. Process inbox.
```

| Source | Weight | What It Means |
|--------|--------|---------------|
| Orphaned notes | 2 mR each | Notes with no incoming links -- invisible to the graph |
| Dangling links | 3 mR each | Wiki-links pointing to files that don't exist |
| Inbox backlog | 0.5 mR each | Unprocessed material piling up |
| Stale notes | 1 mR each | Notes untouched 30+ days with sparse connections |
| Schema violations | 2 mR each | Missing required frontmatter fields |

| Level | Range | Assessment |
|-------|-------|------------|
| CLEAN | 0-5 mR | Vault integrity nominal, Overseer |
| LOW | 6-15 mR | Minor maintenance recommended |
| MODERATE | 16-40 mR | Schedule a decontamination sweep |
| ELEVATED | 41-80 mR | Vault health degrading -- act soon |
| CRITICAL | 81+ mR | Immediate maintenance required |

For deeper architectural friction analysis (unused types, placeholder inflation, oversized MOCs), see `/vault-tec:friction`.

---

## Bobbleheads

The Bobblehead Collection tracks 14 vault milestones. Run the tracker during `/vault-tec:health` to see your progress:

| Bobblehead | Milestone | Condition |
|------------|-----------|-----------|
| Perception | First pattern detected | A pattern surfaces in `ops/patterns/` |
| Intelligence | 100 notes | Note count reaches 100 |
| Endurance | 500 notes | Note count reaches 500 |
| Strength | 1000 notes | Note count reaches 1,000 |
| Charisma | Deep map | 30+ notes on a single map |
| Agility | Sprint day | 10+ notes created in one day |
| Luck | Mature vault | 50%+ notes at evergreen status |
| Collector | Clean inbox | Zero inbox items |
| Wasteland Survival | Vault veteran | Vault is 30+ days old |
| Nuka-Cola Quantum | First tested note | A note reaches `confidence: tested` |
| Power Armor | Zero orphans | No orphaned notes in the vault |
| Pip-Boy | Cartographer | 10+ maps created |
| Fat Man | Hub builder | A single note has 10+ incoming links |
| **Vault-Tec CEO** | **Completionist** | **All other bobbleheads collected** |

Bobblehead state persists in `ops/bobbleheads.md` -- new acquisitions are celebrated, and the tracker always tells you which milestone is closest to unlock.

---

## Research Foundation

Every vault-tec decision traces to cognitive science. The methodology backend contains **83 consolidated research claims** across **6 domains**:

| Domain | Claims | Key References |
|--------|--------|----------------|
| Memory Systems | 14 | Tulving 1985, Squire 2004, Eichenbaum 2000 |
| Learning & Encoding | 18 | Craik & Lockhart 1972, Bjork & Bjork 1992, Rohrer & Taylor 2007 |
| Knowledge Organization | 15 | Collins & Loftus 1975, Schank & Abelson 1977, Kintsch 1988 |
| Cognitive Load | 12 | Sweller 1988, Kalyuga 2009, Paas & van Merriënboer 2020 |
| Agent Architecture | 16 | Russell & Norvig 2020, Minsky 1986, Dennett 1978 |
| Post-2016 Additions | 8 | Context engineering, automation complacency, counterevidence |

Use `/vault-tec:ask` to query this research base in natural language.

---

## What Changed in v0.7.0

### Vault-as-Runtime
The vault is no longer treated as infrastructure -- it's the agent's persistent cognitive substrate. New: **identity dashboard**, **metabolic rate monitoring** across three timescales (session/week/month), **desired-state configuration** with gap reports, and **three-timescale reconciliation loops** (fast write-time, medium session-start, slow monthly audit). See `/vault-tec:runtime`.

### Test-Driven Knowledge Work
Programmable **unit triggers** (per-note quality), **integration triggers** (graph-level coherence), and **regression triggers** (preventing known failures) with effectiveness tracking. See `/vault-tec:triggers`.

### Friction Diagnostics
Six diagnostic patterns (F1-F6) that reveal where vault architecture fights the user's workflow. See `/vault-tec:friction`.

### Session Bookends
Mandatory **SessionStart** orientation (identity, health snapshot, reweave candidates) and **SessionEnd** finalization (session log, pattern surfacing, next-session handoff).

### New Failure Modes
- **F9 -- Automation Complacency**: Hooks handle syntax; users stop checking semantics
- **F10 -- Fan Effect Overload**: Too many connections degrade retrieval speed (Anderson 1974)
- **F11 -- Reweave Debt**: Old notes accumulate without backward maintenance
- **F12 -- Identity Ossification**: `self/` freezes while the vault evolves

### New Evolution Patterns
Schema Reconsolidation, Triage Sprint, Hub Distribution, Processing Ratio Enforcement -- plus a priority matrix and decision tree for choosing which pattern to apply.

### Breaking Changes
- `hooks.json` schema uses `hooks` array wrapper (not flat structure)
- Component counts updated: 7 skills, 10 commands, 7 hooks
- `feature-runtime.md` is a new required feature block for CLAUDE.md generation
- Session logs now mandatory at session end (enforced by SessionEnd hook)

---

## License

MIT

---

Powered by cognitive science. Protected by Vault-Tec.
