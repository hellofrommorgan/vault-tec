---
description: Run diagnostics on a vault's structural health
allowed-tools: Read, Grep, Glob, Bash(ls:*, wc:*, tree:*, find:*, bash:*)
argument-hint: [optional: vault-path]
---

Run a comprehensive diagnostic check on an Obsidian vault's health. Load the vault-health skill from `${CLAUDE_PLUGIN_ROOT}/skills/vault-health/SKILL.md`.

## S.P.E.C.I.A.L. Quick Report

Before running the full diagnostic battery, run the S.P.E.C.I.A.L. dashboard for a fast overview:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/vault-special-health.sh" [vault-path]
```

This produces a Fallout-themed dashboard scoring seven dimensions (Structure, Propagation, Evergreen %, Coverage, Intake, Activity, Longevity) each 0-10, with a composite score and targeted recommendation. Runs in under 5 seconds.

## Locate Vault

If `$1` is provided, use it. Otherwise check current directory for a vault (CLAUDE.md + self/ + notes/). If not found, ask.

## Diagnostic Battery

Run all checks and score each 0-100:

### 1. Schema Compliance (weight: 25%)
- Read all .md files in notes/ and check YAML frontmatter
- Required fields per note type (read from vault's templates/)
- Flag notes missing `type`, `domain`, `status`, or `connections`
- Score: (compliant notes / total notes) * 100

### 2. Connection Health (weight: 25%)
- Count all [[wiki-links]] across all notes
- Identify broken links (pointing to non-existent notes)
- Identify orphan notes (no incoming or outgoing links)
- Calculate connection density: total links / total notes
- Score: 100 - (orphan_rate * 50) - (broken_link_rate * 50)

### 3. MOC Coverage (weight: 20%)
- Check that every domain has a domain MOC
- Check that _MOC-Master.md links to all domain MOCs
- Check that every note is reachable from some MOC within 3 hops
- Score: (reachable notes / total notes) * 100

### 4. Three-Space Integrity (weight: 15%)
- Verify self/ exists with identity.md, methodology.md, goals.md
- Verify notes/ has proper domain subdirectories
- Verify ops/ has sessions/, inbox/, tasks/
- Check that self/ files haven't been modified excessively (slow-growth check)
- Score: (present directories / expected directories) * 100

### 5. Processing Pipeline Health (weight: 15%)
- Check ops/inbox/ for unprocessed notes (stale inbox = unhealthy)
- Check notes for status distribution (healthy vault has mix of seed/growing/evergreen)
- Check ops/sessions/ for recent activity
- Score: based on inbox staleness, status distribution, activity recency

## Composite Score

Calculate weighted composite: sum(check_score * weight).

Present as a health report:

```
VAULT HEALTH REPORT — [vault name]
═══════════════════════════════════
Overall: [SCORE]/100 [HEALTHY|ATTENTION|CRITICAL]

Schema Compliance:    [██████████] 95/100
Connection Health:    [████████░░] 78/100
MOC Coverage:         [███████░░░] 72/100
Three-Space Integrity:[██████████] 100/100
Pipeline Health:      [██████░░░░] 60/100

ISSUES FOUND:
- [list specific issues with file paths]

RECOMMENDATIONS:
- [prioritized action items]
```

Save the report to `ops/maintenance/health-[date].md`.
