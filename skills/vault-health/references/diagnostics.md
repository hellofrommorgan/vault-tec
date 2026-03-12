# Diagnostics Reference

Detailed validation rules and report templates for vault health checks.

## Schema Validation Rules

### Universal Required Fields
Every note in `notes/` must have:
```yaml
type: [string, one of: atomic-note, moc, source-note, reflection, seed-task, session-log, domain-entry]
domain: [string, must match an existing domain directory]
created: [date, YYYY-MM-DD format]
status: [string, one of: seed, growing, evergreen]
connections: [list of wiki-link strings]
```

### Type-Specific Required Fields

**atomic-note**: `confidence` (low|medium|high), `sources` (list)
**moc**: `scope` (master|domain|topic), `parent_moc`
**source-note**: `source_type`, `author`, `year`
**reflection**: `trigger`
**seed-task**: `priority`, `topic`, `estimated_notes`
**session-log**: `session_number`, `focus`
**domain-entry**: `description`, `key_questions`

### Validation Outcomes
- **PASS**: All required fields present with valid values
- **WARN**: Optional fields missing or values outside expected ranges
- **FAIL**: Required field missing or invalid value

## CLAUDE.md Staleness Check

### Config Fingerprint Validation
The generated CLAUDE.md includes a `Config fingerprint` header — a SHA-256 hash of the adaptation variables used during generation.

To check for staleness:
1. Read the current `Config fingerprint` from CLAUDE.md header
2. Read `self/identity.md` and extract current adaptation variable values (vault name, domain, tone, etc.)
3. Read the vault's current state: domain count, note count, pipeline depth
4. Compute SHA-256 of current variable values concatenated
5. Compare: if fingerprints differ, CLAUDE.md is stale and should be regenerated

### Staleness Triggers
Flag CLAUDE.md as potentially stale if ANY of:
- `self/identity.md` was modified after CLAUDE.md's `Last generated` date
- `self/methodology.md` was modified after CLAUDE.md's `Last generated` date
- A new domain was added since generation
- The `Config fingerprint` doesn't match current state
- CLAUDE.md has no `Config fingerprint` header (pre-v0.2.0 generation)

### Report Addition
Add to the health report under THREE-SPACE INTEGRITY:
```
  CLAUDE.md: [present|missing|STALE]
  Config fingerprint: [match|mismatch|missing]
```

If stale, add to RECOMMENDATIONS: "Regenerate CLAUDE.md with `/vault-tec:create-vault` (update mode) or manually update the `Last generated` date and fingerprint."

## Connection Analysis Rules

### Link Extraction
Parse all `[[...]]` patterns from note body text. Also check `connections:` frontmatter.

### Orphan Detection
A note is orphan if:
- It has 0 outgoing wiki-links in body text AND
- It has 0 entries in `connections:` frontmatter AND
- No other note links TO it

### Broken Link Detection
A link `[[Target]]` is broken if no file named `target.md` (case-insensitive) exists anywhere in `notes/`.

### Hub Detection
Notes with >10 incoming links are hubs. Hubs should typically be MOCs. Non-MOC hubs may indicate a concept that should be promoted to MOC status.

## Pipeline Health Formula (v0.7.0)

Pipeline Health is a composite of 4 sub-metrics, each scored 0-100:

```
PIPELINE_HEALTH = (
  inbox_staleness_score × 0.30 +
  status_distribution_score × 0.30 +
  session_recency_score × 0.20 +
  stuck_tasks_score × 0.20
)
```

### Inbox Staleness Score
```
if no inbox items: 100
else:
  stale_ratio = items_older_than_7_days / total_inbox_items
  score = max(0, 100 - (stale_ratio × 100) - (total_inbox_items > 20 ? 20 : 0))
```

### Status Distribution Score
Target: ~30% seed, ~50% growing, ~20% evergreen.
```
seed_dev = abs(seed_pct - 30)
growing_dev = abs(growing_pct - 50)
evergreen_dev = abs(evergreen_pct - 20)
total_dev = seed_dev + growing_dev + evergreen_dev
score = max(0, 100 - total_dev)
```

### Session Recency Score
```
days_since_last = (today - last_session_date).days
if days_since_last <= 1: score = 100
elif days_since_last <= 3: score = 90
elif days_since_last <= 7: score = 70
elif days_since_last <= 14: score = 40
else: score = max(0, 40 - (days_since_last - 14) × 3)
```

### Stuck Tasks Score
```
stuck_count = tasks_in_progress_for_more_than_14_days
score = max(0, 100 - stuck_count × 25)
```

## Inter-Metric Validation (v0.7.0)

These cross-metric rules detect contradictions that individual metrics miss:

| Pattern | Metrics | Diagnosis |
|---------|---------|-----------|
| High schema + low connections | Schema ≥90, Connection <60 | Schema is enforced but not optimized for linking. Notes pass validation but aren't integrated. |
| High connections + low MOC coverage | Connection ≥80, MOC <60 | Notes are linked but not navigable. Links exist but MOC structure hasn't kept up. |
| High pipeline + low session recency | Pipeline ≥80, Session <50 | Status distribution looks healthy but no one's actively working. Vault is coasting. |
| High schema + high pipeline bottleneck | Schema ≥90, many notes stuck at seed | Schema enforcement works but processing pipeline is blocked. Notes enter correctly but never progress. |

When detected, add to report:
```
CROSS-METRIC ALERT: [Pattern name]
  [Metric A]: [score] | [Metric B]: [score]
  Diagnosis: [explanation]
  Action: [specific recommendation]
```

## Health Thresholds Table (v0.7.0)

| Metric | Healthy (80-100) | Attention (60-79) | Critical (<60) |
|--------|------------------|-------------------|-----------------|
| Schema compliance | ≥95% compliant | 80-94% | <80% |
| Connection density | ≥3.0 links/note | 2.0-2.9 | <2.0 |
| Orphan rate | <2% | 2-8% | >8% |
| Broken link rate | <1% | 1-5% | >5% |
| MOC coverage | ≥95% reachable | 80-94% | <80% |
| Inbox staleness | 0 items >7 days | 1-5 stale | >5 stale |
| Session recency | <3 days | 3-14 days | >14 days |
| Status balance | Within ±10% of targets | ±10-20% | >±20% |

## Bonus Checks (v0.7.0)

### Reweave Staleness
Check for notes not modified in >60 days (configurable via REWEAVE_STALENESS_DAYS):
```
stale_notes = notes where (today - last_modified) > REWEAVE_STALENESS_DAYS
reweave_debt = len(stale_notes)
```
Report as info if <10, warning if 10-30, critical if >30.

### Title Composability
Check that atomic note titles work as noun phrases (sentence fragments):
```
composable = title does not start with a verb
composable = title does not end with "?"
composable = title is 3-10 words
```
Report non-composable titles as info-level findings.

### Link Quality Analysis
Categorize wiki-links by type:
- **Reasoning links**: Inline links woven into explanatory prose ("because [[X]], we see...")
- **Citation links**: Links in sources: frontmatter or "(see [[X]])" patterns
- **List links**: Links in bullet lists or connections: frontmatter

Healthy ratio: ≥40% reasoning links. Below 40% suggests links are administrative rather than cognitive.

## Report Template

```
╔══════════════════════════════════════════════╗
║  VAULT HEALTH REPORT                         ║
║  Vault: [name]                               ║
║  Date:  [YYYY-MM-DD]                         ║
║  Score: [N]/100 — [HEALTHY|ATTENTION|CRITICAL]║
║  vault-tec v0.7.0                            ║
╚══════════════════════════════════════════════╝

SCHEMA COMPLIANCE                    [██████████] NN/100
  Total notes scanned: N
  Compliant: N (N%)
  Warnings: N
  Failures: N
  Top issues: [list]

CONNECTION HEALTH                    [████████░░] NN/100
  Total wiki-links: N
  Connection density: N.N links/note
  Orphan notes: N (N%)
  Broken links: N (N%)
  Hub notes: N
  Link quality: N% reasoning, N% citation, N% list

MOC COVERAGE                         [███████░░░] NN/100
  Domain MOCs: N/N present
  Master MOC links: N/N domains
  Reachable notes: N/N (N%)
  Oversized MOCs: N (>50 links)

THREE-SPACE INTEGRITY                [██████████] NN/100
  self/ files: N/4 present
  notes/ domains: N configured
  ops/ directories: N/4 present
  Cross-contamination: [none|list]
  CLAUDE.md: [present|missing|STALE]
  Config fingerprint: [match|mismatch|missing]

PIPELINE HEALTH                      [██████░░░░] NN/100
  Inbox items: N (N stale)
  Status distribution:
    seed:      N (N%) [target: ~30%]
    growing:   N (N%) [target: ~50%]
    evergreen: N (N%) [target: ~20%]
  Last session: [date] ([N days ago])
  Stuck tasks: N
  Reweave debt: N notes past threshold

CROSS-METRIC ALERTS                  [if any]
  [Alert details]

════════════════════════════════════════════════
ISSUES (sorted by priority)

[P1] [CRITICAL] [description] — [file path]
     Fix: [action]

[P2] [WARNING] [description] — [file path]
     Fix: [action]

[P3] [INFO] [description]
     Suggestion: [action]

════════════════════════════════════════════════
RECOMMENDATIONS

1. [Highest-priority action with expected impact]
2. [Second priority]
3. [Third priority]
```

## Common Issue Patterns

### "Growing Inbox" Pattern
- Symptom: ops/inbox/ has >20 items, many older than 7 days
- Cause: Capture outpacing processing
- Fix: Dedicated processing session. Run `/pipeline` on oldest items first.

### "Orphan Island" Pattern
- Symptom: Cluster of notes with no connections to the rest of the vault
- Cause: Notes created without the Reflect stage of 6R
- Fix: Run `/reflect` on each orphan note. Check if they belong to an existing domain or need a new one.

### "MOC Bloat" Pattern
- Symptom: One or more MOCs with >50 links
- Cause: Topic grew without spawning sub-MOCs
- Fix: Identify clusters within the bloated MOC and extract into topic MOCs.

### "Identity Drift" Pattern
- Symptom: self/ files have been modified frequently or are inconsistent with current vault usage
- Cause: Vault purpose is evolving without deliberate reflection
- Fix: Run `/vault-tec:evolve` for a structured architecture review.

### "Stale CLAUDE.md" Pattern
- Symptom: Config fingerprint mismatch or missing fingerprint
- Cause: Vault evolved (new domains, identity changes) but CLAUDE.md wasn't regenerated
- Fix: Regenerate CLAUDE.md using the create-vault command in update mode, or run `/vault-tec:evolve`.

### "Reweave Debt" Pattern (v0.7.0)
- Symptom: Many notes not modified in >60 days with sparse connections
- Cause: Knowledge captured but never revisited with fresh context
- Fix: Run `/vault-tec:reweave` for guided backward maintenance. Small batches: 1-2 notes per session.

### "Composability Gap" Pattern (v0.7.0)
- Symptom: Note titles that don't work as sentence fragments
- Cause: Titles written as labels ("Memory systems") rather than composable noun phrases ("Working Memory Capacity Limits")
- Fix: Rename notes to composable noun-phrase form. Update all wiki-links referencing the old title.
