# Feature Block: Processing

**Merges**: processing-pipeline.md + session-rhythm.md
**Kernel Primitives**: processing-pipeline, session-rhythm, status-lifecycle
**Generates**: Processing section of CLAUDE.md

## Purpose

Define the workflow for transforming raw captures into integrated, connected knowledge — the 6R pipeline and the session rhythm that structures work.

## Generated Content Pattern

```
## Processing

### The 6R Pipeline
Every piece of captured knowledge progresses through six processing stages. Each stage is a distinct cognitive operation — run them separately, not all at once.

**1. Record** (Capture)
Quickly capture the raw idea, quote, or observation. Don't edit, don't connect — just get it down.
- Input: Raw thought, reading note, conversation insight
- Output: Note in `ops/inbox/` with `status: seed`
- Time: Seconds to minutes

**2. Reduce** (Extract)
Distill the capture to its essential insight. Remove noise, identify the core idea.
- Command: `/reduce [note]`
- Input: Raw inbox capture
- Output: Cleaned atomic note draft with clear title and core insight
- Move from: `ops/inbox/` → `notes/domains/[domain]/`

**3. Reflect** (Connect)
Find relationships between this idea and existing knowledge. This is where integration happens.
- Command: `/reflect [note]`
- Input: Reduced atomic note
- Output: Note with wiki-links to related concepts, updated connections field
- Key question: "What does this relate to? What does it change about what I already know?"

**4. Reweave** (Contextualize)
Update the note and its neighborhood with new context. Propagate implications.
- Command: `/reweave [note]`
- Input: Connected note
- Output: Updated note with enriched context; neighboring notes may also be updated
- Update status: `seed` → `growing`

**5. Verify** (Validate)
Check the note against its schema and the vault's quality standards.
- Command: `/verify [note]`
- Input: Reweaved note
- Output: Validation report — schema compliance, link integrity, source attribution

**6. Rethink** (Challenge)
Challenge the note's assumptions. Look for counter-evidence, alternative interpretations, edge cases.
- Command: `/rethink [note]`
- Input: Verified note
- Output: Note with considered objections; may spawn new atomic notes for counter-arguments
- Update status: `growing` → `evergreen` (if it survives rethinking)
```

### 6R Phase Input/Output Contracts (v0.7.0)

Each phase has a strict contract. The output of one phase must satisfy the input requirements of the next.

| Phase | Input Requirements | Output Guarantees | Quality Gate |
|-------|-------------------|-------------------|-------------|
| **Record** | Any raw material (text, link, voice note) | File exists in ops/inbox/ with minimum frontmatter (type, created) | File exists and is parseable |
| **Reduce** | File in ops/inbox/ | Atomic note in notes/domains/[domain]/ with: title (composable noun phrase), body (100-300 words), complete YAML frontmatter, status: seed | Schema validation passes, title composability check passes |
| **Reflect** | Atomic note with status: seed or growing | Same note with: ≥2 wiki-links in body, updated connections: frontmatter, context phrases on each link | Link count ≥2, all links resolve to existing files |
| **Reweave** | Reflected note with ≥2 links | Same note with: enriched body incorporating linked context, status: growing, neighboring notes checked and updated if needed | Status advanced, no new orphans created by the update |
| **Verify** | Reweaved note with status: growing | Validation report: schema pass/fail, link integrity pass/fail, source attribution pass/fail, title composability pass/fail | All checks pass — or specific failures documented |
| **Rethink** | Verified note with all checks passing | Same note with: counter-arguments section, confidence reassessed, status: evergreen (if survives) or growing (if weakened) | Confidence field reflects actual evidence strength |

**Contract violation handling**: If a phase's output doesn't meet the next phase's input requirements, the pipeline pauses. Fix the output before proceeding. Never skip a quality gate.

```
### Session Rhythm
Each work session follows a three-phase rhythm:

**Capture Phase** (Session Start)
- Orient: Read `self/identity.md` and recent session logs
- Check: Review `ops/inbox/` for unprocessed items
- Plan: Decide session focus — seeding new content, processing inbox, or evolving architecture

**Process Phase** (Session Body)
- Focus on one primary activity per session
- Run 6R pipeline on inbox items, OR
- Seed new research, OR
- Evolve architecture via `/vault-tec:evolve`
- Create session-log in `ops/sessions/`

**Integrate Phase** (Session End)
- Run `/remember` to capture session insights
- Update `ops/sessions/session-[date].md` with summary
- Update any MOCs affected by new notes
- Note anything to pick up next session

### Status Lifecycle
- **seed**: Raw capture, minimally processed. Needs reduction and connection.
- **growing**: Processed and connected, but not yet verified or challenged. Active development.
- **evergreen**: Verified, challenged, stable. A trusted piece of knowledge. May still evolve, but slowly.

Healthy status distribution: ~30% seed, ~50% growing, ~20% evergreen.
```

## Adaptation Variables

- `{{PIPELINE_DEPTH}}` — How many R's to enforce:
  - **full**: All 6R (for research vaults)
  - **standard**: Record → Reduce → Reflect → Verify (skip Reweave and Rethink for lighter use)
  - **minimal**: Record → Reduce (capture-focused vaults)
- `{{SESSION_FORMALITY}}` — How structured sessions should be:
  - **structured**: Full three-phase rhythm with explicit logs
  - **flexible**: Orient at start, log at end, freeform in between
