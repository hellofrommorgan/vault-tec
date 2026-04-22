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

## Context

Season thesis: harness-hardening. Establish verify.sh as the Score verify contract for vault-tec by locking in shellcheck, YAML frontmatter, link-integrity, and hooks.json validity gates.

**Isolation**:
- Worktree: {{ workspace }}
- Branch: auto/season-20260422-144922-vault-harness-v1
- Canonical: /Users/morgan/Projects/vault-tec (DO NOT TOUCH)

## Your Startup Sequence (non-negotiable per CLAUDE.md)

1. `cd {{ workspace }}`
2. Read progress.md, score.json, and knowledge/ entry titles
3. Run `./.score/score status --brief`
4. Read the relevant lane from `/Users/morgan/Projects/stage/season/seasons/vault-harness-v1/THESIS.md` (the target surface, halt conditions, stopping-bar bullet this issue contributes to)
5. Identify highest-priority ready feature matching issue `{{ issue.identifier }}`

## Work Cycle

1. Plan briefly (1–3 sentences)
2. Code/edit (respect out-of-scope: do NOT touch skills/*/references/*.md, .claude-plugin/, LICENSE, README.md)
3. `./.score/score verify <feature-id>` — this is THE gate
4. If pass: commit referencing feature id, update progress.md, append RUN-LEDGER block to `/Users/morgan/Projects/stage/season/seasons/vault-harness-v1/RUN-LEDGER.md`
5. If fail: iterate up to 3 attempts. After 3, STOP and surface as harness gap in progress.md notes; transition issue to `blocked`.

## Rules (hard)

- **NEVER self-grade**: the `passes` field is script-owned.
- **NEVER touch canonical** (`/Users/morgan/Projects/vault-tec`) — only the worktree.
- **NEVER force-push** or `git reset --hard`.
- **Clean git state at session end**: all work committed or reverted.
- **One issue per session**: when this issue terminates, end the session.

## RUN-LEDGER append format

After any outcome (pass/fail), append a block to the season RUN-LEDGER.md:

```
### batch-N/run-M — {{ issue.identifier }}
- lane: L<1|2|3>
- dispatched_at: <ISO UTC>
- subagent: orchestra/copilot
- task: <1-sentence bounded spec>
- halt_condition: <what stopped the run>
- expected_artifact: <path or "verify green">
- actual_artifact: <path or "verify result">
- exit_status: pass | degraded | failed | skipped
- discovery: <1–3 bullets of what was learned>
- flagged_bug: <link to commit or "none">
- commit_range: <sha..sha or "none">
```

Turn {{ turn }} of {{ max_turns }}. Focus. Commit on green. Surface gaps on red.
