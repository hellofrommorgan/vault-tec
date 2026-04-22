#!/usr/bin/env bash
# score init — scaffold Score convention files into a target repo
set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo "Usage: score init [target-directory]"
  echo "Install Score OS into a directory. Creates convention files,"
  echo "system calls (.score/), and knowledge base. Default: current dir."
  exit 0
fi

TARGET="${1:-.}"

if [[ ! -d "$TARGET" ]]; then
  echo "ERROR: Target directory '$TARGET' does not exist" >&2
  exit 1
fi

echo "=== Score Init ==="
echo "Scaffolding into: $TARGET"
echo ""

# Create VISION.md if it doesn't exist
if [[ ! -f "$TARGET/VISION.md" ]]; then
  cat > "$TARGET/VISION.md" << 'VISIONMD'
# Vision

> What are you building and why does it matter? This is the north star the agent reads to understand your intent.

## What It Is
TODO: Describe what you are creating — not features, but the thing you want to exist in the world.

## Why It Matters
TODO: What problem does this solve? Why now? Why you?

## What It Is Not
TODO: Draw boundaries. What are you deliberately not building?
VISIONMD
  echo "  Created: VISION.md"
else
  echo "  Skipped: VISION.md (already exists)"
fi

# Create CLAUDE.md with full Score SOP if it doesn't exist
if [[ ! -f "$TARGET/CLAUDE.md" ]]; then
  cat > "$TARGET/CLAUDE.md" << 'CLAUDEMD'
# Score — Standard Operating Procedure

> This file is the control plane. The agentic CLI reads it at session start and becomes the operating system.
> Every rule here exists because a known failure mode demands it.

## Startup Sequence (Every Session, Non-Negotiable)

Before doing ANY work, complete these steps in order:

1. Read `progress.md` — understand what happened last session and what's next
2. Read `score.json` — know the full feature list and current pass/fail state
3. Scan `knowledge/` — read entry titles, dive into any relevant to your current target
4. Run `./.score/score status --brief` — get the bounded orientation summary
5. Identify the highest-priority ready feature from that summary — that's your target

Do NOT begin coding until the brief orientation is complete. Use `./.score/score status --full` only when you need more context than the brief summary provides.

If all features are passing or the feature list is empty, run `./.score/score plan` to decompose intent into new work. The plan output will guide you to propose features — **surface these as a steering moment** for human approval before adding them to score.json.

## Work Cycle (Per Feature)

1. **Plan briefly** — state the approach in 1-3 sentences, no more
2. **Code/edit** — implement the feature
3. **Verify** — run `./.score/score verify <feature-id>` to gate completion
4. **If pass** — commit with a descriptive message referencing the feature ID, then update progress.md
5. **If fail** — read the test output, iterate on the code, re-verify. Do NOT move on until the gate passes.
6. **Update progress.md** — record what was done and what's next
7. **Extract learnings** — if anything surprised you, write a structured entry in `knowledge/` using the format in `knowledge/README.md`. This is how the OS compounds intelligence across sessions.

## Verification Protocol

**NEVER self-grade.** You are systematically overconfident about your own output quality.

- The `passes` field in score.json is **script-owned**. Do NOT edit it directly. Only `.score/verify.sh` writes that field.
- Always use `./.score/score verify <feature-id>` to check completion
- If tests fail, the feature is not done — regardless of how correct the code looks to you
- Binary only: a feature passes or it doesn't. No "mostly works."

## Clean-State Rule

Every session MUST end with clean git state:

- If work is complete: commit all changes with a descriptive message
- If work is incomplete: revert uncommitted changes, update progress.md with context for next session, commit progress.md
- No half-finished code is ever left uncommitted

Check with `git status` before ending any session.

## Failure Escalation

After 3 failed attempts on the same feature:

1. STOP trying to force it
2. Surface as a **harness gap**: what tool, test, or constraint is missing?
3. Update progress.md with the diagnosis
4. Move on to the next feature or end the session cleanly

The human's job is to improve the harness. Your job is to surface what's missing, not to guess your way through it.

## Steering Moments

Pause and surface to the human when:
- **Architecture forks** — multiple structurally different paths, choice shapes everything downstream
- **Scope questions** — unclear whether something is in or out of current intent
- **Convention changes** — any modification to CLAUDE.md, golden-principles.md, or VISION.md
- **Taste calls** — naming, API shape, user-facing language
- **Repeated failure** — after 3 failed attempts, surface as a harness gap

Stay autonomous when the path is unambiguous, the work is mechanical, verification will catch mistakes, or the decision is easily reversible.

## Convention Evolution

The OS is a living document. It improves through the same cycle it uses to build anything else.

**Trigger:** At session end when 3+ features were completed, or when `knowledge/` has 5+ unreviewed entries.

**Process:**
1. Scan `knowledge/` for recurring patterns
2. Draft proposed convention changes
3. **Surface as a steering moment** — convention changes always require human approval
4. If approved: make the change, archive promoted entries to `knowledge/archived/`

## Architecture Reference

Read `VISION.md` to understand what this project is and why. Read `golden-principles.md` before making architecture decisions. If a decision conflicts with the vision or a golden principle, flag it — don't silently override.

## Project Structure

```
├── CLAUDE.md              ← You are here (the SOP / kernel)
├── VISION.md              ← What this project is and why it exists
├── score.json         ← Feature tracking (process table, script-owned)
├── progress.md            ← Session state (you read and write this)
├── golden-principles.md   ← Architecture invariants (kernel invariants)
├── knowledge/             ← Compound intelligence (persistent memory)
├── .score/            ← System calls (namespaced to avoid collisions)
│   ├── score          ← Dispatch: score {status|verify|audit|run|plan|add|init}
│   ├── verify.sh          ← THE gate: runs tests, writes passes field
│   ├── status.sh          ← Orientation: vision, progress, knowledge, next target
│   ├── audit.sh           ← Trust check: re-verify all passed features
│   ├── run.sh             ← Autonomous iteration loop
│   ├── plan.sh            ← Intent-to-features decomposition
│   ├── add.sh             ← Add features from CLI without editing JSON
│   └── init.sh            ← Install Score OS into a new repo
└── (project's own files, tests, scripts — untouched)
```
CLAUDEMD
  echo "  Created: CLAUDE.md"
else
  echo "  Skipped: CLAUDE.md (already exists)"
fi

# Create progress.md if it doesn't exist
if [[ ! -f "$TARGET/progress.md" ]]; then
  cat > "$TARGET/progress.md" << 'PROGRESS'
# Progress

## Last Updated
(not yet started)

## Current State
initializing

## Last Completed Feature
None

## Next Feature
(run `./.score/score status` to identify)

## Notes
Fresh Score scaffold. Define features in score.json, then start working.

## Learnings

> Pit/solution/prevention format. Each entry compounds the harness's intelligence for future sessions.
> Add entries here when something surprises you — a pit you fell into, a technique that worked, a harness gap you discovered.
PROGRESS
  echo "  Created: progress.md"
else
  echo "  Skipped: progress.md (already exists)"
fi

# Create score.json if it doesn't exist
if [[ ! -f "$TARGET/score.json" ]]; then
  cat > "$TARGET/score.json" << 'SCORE'
{
  "project": "my-project",
  "intent": "TODO: one-line description of what you are building",
  "vision": "TODO: what do you want to exist in the world and why? Not features — purpose. This is the north star the agent reads to understand your intent.",
  "test_command": "echo 'TODO: set your test command'",
  "features": []
}
SCORE
  echo "  Created: score.json"
else
  echo "  Skipped: score.json (already exists)"
fi

# Create golden-principles.md if it doesn't exist
if [[ ! -f "$TARGET/golden-principles.md" ]]; then
  cat > "$TARGET/golden-principles.md" << 'GOLDEN'
# Golden Principles

> Architecture invariants for this project. The agent reads these before making decisions.

## 1. (Define your first principle)
TODO
GOLDEN
  echo "  Created: golden-principles.md"
else
  echo "  Skipped: golden-principles.md (already exists)"
fi

# Create knowledge/ directory if it doesn't exist
if [[ ! -d "$TARGET/knowledge" ]]; then
  mkdir -p "$TARGET/knowledge"
  cat > "$TARGET/knowledge/README.md" << 'KBREADME'
# Knowledge Base

> Compound intelligence. Every entry makes the next session start from a higher floor.

## Entry Format

Each file is a markdown document named `YYYY-MM-DD-short-slug.md`:

```markdown
# Title (short, scannable)

**Category:** harness | testing | verification | workflow | architecture
**Date:** YYYY-MM-DD
**Session:** (which feature or work prompted this)

## Pit
What went wrong or what was surprising.

## Solution
What fixed it or what the insight was.

## Prevention
How to avoid this in the future — a rule, a convention, or a check.
```

Recurring patterns get promoted to conventions in CLAUDE.md or golden-principles.md.
KBREADME
  echo "  Created: knowledge/ with README.md"
else
  echo "  Skipped: knowledge/ (already exists)"
fi

# Install .score/ system calls into target repo
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ ! -d "$TARGET/.score" ]]; then
  mkdir -p "$TARGET/.score"
  for script in score verify.sh status.sh audit.sh run.sh plan.sh init.sh add.sh; do
    if [[ -f "$SCRIPT_DIR/$script" ]]; then
      cp "$SCRIPT_DIR/$script" "$TARGET/.score/$script"
      chmod +x "$TARGET/.score/$script"
    fi
  done
  echo "  Created: .score/ (all system calls installed)"
else
  echo "  Skipped: .score/ (already exists)"
fi

echo ""
echo "Done. Score OS installed. Next steps:"
echo "  1. Edit VISION.md — define what you are building and why"
echo "  2. Edit score.json — set project name, intent, vision, and test_command"
echo "  3. Edit golden-principles.md — define your architecture invariants"
echo "  4. Run: ./.score/score status --brief"
