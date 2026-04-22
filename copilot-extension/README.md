# copilot-extension

GitHub Copilot CLI adapter for vault-tec.

Bridges vault-tec's 7 Claude Code hooks (bash scripts in `hooks/scripts/`) into
Copilot CLI's Node.js extension API. Zero logic duplication — the bash scripts
stay canonical, this layer is a thin adapter.

## Install

```bash
mkdir -p ~/.copilot/extensions/vault-tec
cp copilot-extension/extension.mjs ~/.copilot/extensions/vault-tec/
ln -sfn "$PWD/hooks/scripts" ~/.copilot/extensions/vault-tec/scripts
```

Run `/vault-tec:setup` to have the install done for you.

## How it works

```
┌─────────────────────┐   ┌──────────────────────┐   ┌──────────────────┐
│   Copilot CLI       │──►│   extension.mjs      │──►│  hooks/scripts/  │
│  (parent process)   │   │   (JS adapter)       │   │   *.sh (bash)    │
└─────────────────────┘   └──────────────────────┘   └──────────────────┘
                             ▲                          ▲
                             │                          │
                   pre-filter │                          │ JSON on stdin
                   (skip non- │                          │ JSON on stdout
                   vault tool │                          │ {additionalContext:...}
                   calls)     │                          │
```

### Hook mapping

| Copilot CLI hook         | vault-tec bash script          |
|--------------------------|--------------------------------|
| `onSessionStart`         | `vault-session-start.sh`       |
| `onSessionEnd`           | `vault-session-end.sh`         |
| `onUserPromptSubmitted`  | `vault-userpromptsubmit.sh`    |
| `onPreToolUse`           | `vault-pretooluse.sh`          |
| `onPostToolUse`          | `vault-posttooluse.sh`         |
| `onErrorOccurred`        | *(system/model errors only)*   |
| **(no `onPreCompact`)**  | → emulated via `vault_tec_preserve_state` tool |

### Tool

`vault_tec_preserve_state` — callable by the agent to snapshot working-memory
before compaction (Copilot CLI has no pre-compact hook; this is the only
preservation path). The extension also injects a standing instruction telling
the agent to call this tool at natural checkpoints.

### Council-reviewed design decisions

- **JS-side pre-filter** kills ~90% of bash subprocess spawns. Only writer
  tools (`edit`/`create`/`write`) with `.md` paths inside the vault's `notes/`
  tree trigger hooks.
- **`edit` tool content synthesis** — Copilot's `edit` passes `old_str`/`new_str`
  (no full content), which would break `vault-pretooluse.sh`'s schema check.
  The adapter reads the file from disk and simulates the patch in-memory
  before feeding to bash.
- **`import.meta.url` paths** — no hardcoded dev paths; works from any install
  location.
- **Subprocess timeouts** — hung bash scripts can't stall the CLI (2–15s per hook).
- **Resume skip** — `onSessionStart` skips heavy scan on `input.source === "resume"`.
- **Config cache** — `~/.vault-tec/config.sh` parsed once at startup, env
  pre-loaded to child procs.
- **JSON stdout parsing** — bash scripts emit `{"additionalContext": "..."}`,
  adapter parses and forwards the inner field (not the raw JSON blob).
- **SIGTERM cascade** — child processes get terminated on extension shutdown.

### Known gaps

- **No `onPreCompact` parity** — emulated via the preserve-state tool + standing
  agent instruction. Relies on agent cooperation (imperfect but unavoidable).
- **Windows** — bash shell-out won't work. Future work: port hot-path checks
  (`vault-posttooluse.sh`, `vault-pipboy-status.sh`, `vault-rad-counter.sh`)
  to pure JS.
- **`PostToolUseFailure` semantics** — routed through `onPostToolUse` with a
  `toolResult.resultType === "failure"` guard; not a separate hook.

## Dev / smoke test

With the extension symlinked into `~/.copilot/extensions/vault-tec/`, reload
via `extensions_reload` tool inside a Copilot CLI session and verify:

```
extensions_manage({operation: "inspect", name: "vault-tec"})
# Should report: Status: running
```
