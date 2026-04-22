---
tracker:
  kind: local-json
  path: ./orchestra.json
  active_states: [todo, in_progress]
  terminal_states: [done, blocked]

polling:
  interval_ms: 15000

workspace:
  # CRITICAL: vault-tec is markdown+bash. Per season dogma all runs share ONE
  # worktree. We set source_repo to the worktree itself and base_branch to the
  # season branch. Orchestra's default would create per-issue worktrees under
  # workspace.root — but those will still share commits via git since all point
  # at the same source_repo.
  root: .orchestra/workspaces
  source_repo: .
  base_branch: auto/season-20260422-144922-vault-harness-v1
  reset_on_retry: false
  delete_branch_on_cleanup: false

agent:
  # Pin concurrency to 1 for first drain (avoid same-tree race).
  # Bump after dogfood validates shared-worktree safety.
  max_concurrent_agents: 1
  max_turns: 8
  turn_timeout_ms: 1800000
  stall_timeout_ms: 300000
  max_retry_backoff_ms: 300000

copilot:
  allow_tools: []
  deny_tools:
    - "shell(rm -rf)"
    - "shell(git push)"
    - "shell(git reset --hard)"
  disallow_temp_dir: false  # we ARE in /tmp, so allow
  add_dirs:
    - /tmp/season-vault-harness-v1-20260422-144922/vault-tec

allowed_agent_transitions:
  - { from: todo, to: in_progress }
  - { from: in_progress, to: done }
  - { from: in_progress, to: blocked }

hooks:
  before_run:
    - run: "echo '--- orchestra: starting issue (cwd is worktree) ---'"
      timeout_ms: 5000
    - run: "./.score/score status --brief"
      timeout_ms: 15000
  after_run:
    - run: "git status --short"
      timeout_ms: 5000

dashboard:
  enabled: true
  port: 7777
  bind: localhost
  allow_control: true

logs:
  root: ./.orchestra/logs
  level: info
---

You are a Score session inside season **vault-harness-v1** working on issue **{{ issue.identifier }}**: {{ issue.title }}.

{% if attempt %}This is attempt {{ attempt }}.{% endif %}

## State Transition Protocol (REQUIRED — orchestra reads these)

Emit on a line by itself in your final assistant message:

- **First act:** claim the issue
  `ORCHESTRA_TRANSITION issue={{ issue.identifier }} to=in_progress reason="starting work"`
- **On success (verify green):**
  `ORCHESTRA_TRANSITION issue={{ issue.identifier }} to=done reason="verify green, committed <sha>"`
- **On 3-strike failure:**
  `ORCHESTRA_TRANSITION issue={{ issue.identifier }} to=blocked reason="3-strike: <symptom>"`

Format is strict: `ORCHESTRA_TRANSITION issue=<id> to=<state> reason="<quoted>"`. Whitespace-sensitive. No transition line = orchestra retries the session.

## Context

Season thesis: harness-hardening. Establish verify.sh as the Score verify contract for vault-tec by locking in shellcheck, YAML frontmatter, link-integrity, and hooks.json validity gates.

**Isolation (cwd is already set to the worktree):**
- Worktree: /tmp/season-vault-harness-v1-20260422-144922/vault-tec
- Branch: auto/season-20260422-144922-vault-harness-v1
- Canonical: /Users/morgan/Projects/vault-tec (DO NOT TOUCH)

## Your Startup Sequence (non-negotiable per CLAUDE.md)

Emit the `to=in_progress` transition FIRST, then:

1. Read `progress.md`, `score.json`, and `knowledge/` entry titles
2. Read lane details from `/Users/morgan/Projects/stage/season/seasons/vault-harness-v1/THESIS.md`
3. Run `./.score/score status --brief`
4. Identify the feature matching issue `{{ issue.identifier }}`

## Work Cycle

1. Plan briefly (1–3 sentences)
2. Code/edit (respect out-of-scope: do NOT touch `skills/*/references/*.md`, `.claude-plugin/`, `LICENSE`, `README.md`)
3. `./.score/score verify <feature-id>` — this is THE gate
4. If pass: commit referencing feature id, update `progress.md`, append to `/Users/morgan/Projects/stage/season/seasons/vault-harness-v1/RUN-LEDGER.md`, emit `to=done` transition
5. If fail: iterate up to 3 attempts. After 3: emit `to=blocked` transition, surface as harness gap in progress.md

## Rules (hard)

- **NEVER self-grade:** the `passes` field is script-owned (only `.score/verify.sh` writes it).
- **NEVER touch canonical** (`/Users/morgan/Projects/vault-tec`) — only the worktree.
- **NEVER force-push** or `git reset --hard`.
- **Clean git state at session end:** all work committed or reverted.
- **One issue per session:** emit the terminal transition, then stop.
- **Always end with a transition line** — no transition = retry loop.

## RUN-LEDGER append format

Append to `/Users/morgan/Projects/stage/season/seasons/vault-harness-v1/RUN-LEDGER.md`:

```
### {{ issue.identifier }} — attempt <N>
- dispatched_at: <ISO UTC>
- subagent: orchestra/copilot
- task: <1-sentence spec>
- exit_status: pass | degraded | failed | blocked
- discovery: <1–3 bullets>
- commit_range: <sha..sha or "none">
```

Focus. Commit on green. Emit transition. End session.

## RUN-LEDGER append format

After any outcome (pass/fail), append a block to the season RUN-LEDGER.md:

```
Turn {{ turn }} of {{ max_turns }}. Focus. Commit on green. Surface gaps on red.
