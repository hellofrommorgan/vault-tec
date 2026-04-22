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
