---
name: vault-health
description: >
  Vault diagnostics and quality enforcement. Use when the user asks to
  "check vault health", "run diagnostics", "validate my vault", "find
  broken links", "check for orphan notes", "audit my vault", or needs
  to assess structural integrity, schema compliance, or connection density.
  Also triggers on "health check", "vault quality", and "diagnostic".
version: 0.1.0
---

# Vault Health

Diagnostic engine for assessing and maintaining Obsidian vault structural integrity. Runs a battery of 5 weighted checks that produce a composite health score.

## Diagnostic Battery

### 1. Schema Compliance (25% weight)
Scan all `.md` files in `notes/` for YAML frontmatter validation:
- Required fields present: `type`, `domain`, `created`, `status`, `connections`
- Field values are valid (status is one of seed|growing|evergreen, type matches known types)
- Type-specific fields present per template definitions
- Score: (compliant / total) * 100

Read `references/diagnostics.md` for detailed validation rules.

### 2. Connection Health (25% weight)
Analyze the wiki-link network:
- Count all `[[wiki-links]]` across all notes
- Identify broken links (target doesn't exist)
- Identify orphan notes (0 incoming AND 0 outgoing links)
- Calculate connection density (total links / total notes)
- Healthy target: density ≥ 3.0, orphan rate < 5%, broken link rate < 2%
- Score: 100 - (orphan_rate * 50) - (broken_link_rate * 50)

### 3. MOC Coverage (20% weight)
Assess navigation structure:
- Every domain has a `_MOC-*.md` file
- `_MOC-Master.md` links to all domain MOCs
- Every note reachable from some MOC within 3 hops
- No MOC exceeds 50 direct links (split threshold)
- Score: (reachable / total) * 100

### 4. Three-Space Integrity (15% weight)
Verify architectural boundaries:
- `self/` exists with all 4 required files
- `notes/` has proper domain subdirectory structure
- `ops/` has sessions/, inbox/, tasks/, maintenance/
- No cross-contamination (knowledge notes in ops/, ops files in notes/)
- CLAUDE.md exists and is non-empty at vault root
- Score: (present / expected) * 100

### 5. Pipeline Health (15% weight)
Assess processing flow:
- Inbox staleness: items in `ops/inbox/` older than 7 days
- Status distribution: healthy ≈ 30% seed, 50% growing, 20% evergreen
- Session recency: most recent session log < 7 days old
- Task queue: no tasks stuck in "in-progress" for > 14 days
- Score: composite of sub-metrics

## Severity Thresholds

- **HEALTHY** (80-100): Normal operation. Minor maintenance may help.
- **ATTENTION** (60-79): Noticeable issues. Schedule maintenance session.
- **CRITICAL** (0-59): Significant problems. Immediate attention needed.

## Report Format

Read `references/diagnostics.md` for the full report template.

## Remediation

For each issue found, provide:
1. What's wrong (specific file paths and issue descriptions)
2. Why it matters (link to relevant methodology claim)
3. How to fix it (specific action, often a vault-tec command)
4. Priority (based on issue severity and compound risk)
