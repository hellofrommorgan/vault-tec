---
description: Interactive vault-tec onboarding and configuration
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: "[optional: vault-path]"
---

Interactive setup and configuration for vault-tec. This command walks the user through a conversational onboarding flow that configures all vault-tec settings — vault location, companion identity, processing preferences, monitoring, and hooks.

## Behavior

Load the `vault-setup` skill. It contains the full interactive setup flow.

If `$ARGUMENTS` contains a path, use it as the default vault path suggestion in Phase 1 (the user can still change it).

If `~/.vault-tec/config.sh` already exists, enter **reconfigure mode**: show the current settings and ask what the user wants to change, rather than running the full flow from scratch.

If this is a fresh setup with no existing config, run the full 5-phase interactive flow defined in the skill.

After configuration is complete, if the vault path doesn't contain an existing vault (no CLAUDE.md + self/ + notes/), offer to run `/vault-tec:create-vault` to build the vault structure.
