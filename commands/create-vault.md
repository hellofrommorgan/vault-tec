---
description: Create a new Obsidian vault with agent-native architecture
allowed-tools: Read, Write, Edit, Bash(mkdir:*, ls:*, cp:*, touch:*, tree:*)
argument-hint: [vault-name] [optional: path]
---

Create a new Obsidian vault using the arscontexta-derived architecture. This is a multi-phase conversational derivation — not a template dump.

## Phase 1: Discovery

If the user provided only a vault name, ask about:
- **Domain focus**: What knowledge domain(s) will this vault serve? (e.g., "AI research", "philosophy", "startup notes", "personal growth")
- **Working style**: Do they prefer structured capture (templates, schemas) or freeform emergence?
- **Scale expectation**: Dozens of notes? Hundreds? Thousands over time?
- **Existing knowledge**: Are they migrating from another system, or starting fresh?

If the user provided `$ARGUMENTS`, parse vault name from `$1` and optional path from `$2`. Default path is `~/` (home directory).

## Phase 2: Vault Scaffold

Create the vault directory at `$2/$1` (or `~/$1` if no path given):

```
$1/
├── .obsidian/                    # Obsidian config (create minimal)
│   └── app.json
├── self/                         # Identity space (slow-growth, ~10-30 files)
│   ├── identity.md               # Who the agent is in this vault
│   ├── methodology.md            # How knowledge is processed here
│   ├── goals.md                  # Current objectives and north stars
│   └── evolution-log.md          # Track architectural changes
├── notes/                        # Knowledge space (steady-growth, unlimited)
│   ├── _MOC-Master.md            # Top-level Map of Content
│   └── domains/                  # One subdirectory per knowledge domain
├── ops/                          # Operations space (high-churn, disposable)
│   ├── sessions/                 # Session capture logs
│   ├── inbox/                    # Unprocessed captures
│   ├── tasks/                    # Active task queue
│   └── maintenance/              # Health reports, audit logs
├── templates/                    # Note type templates
│   ├── atomic-note.md
│   ├── moc.md
│   ├── source-note.md
│   ├── reflection.md
│   ├── seed-task.md
│   ├── session-log.md
│   └── domain-entry.md
└── CLAUDE.md                     # Agent system prompt (generated)
```

## Phase 3: Generate CLAUDE.md

Load the vault-architect skill. Read `${CLAUDE_PLUGIN_ROOT}/skills/vault-architect/references/generator-claude-md.md` for the master template.

Compose the CLAUDE.md by reading and assembling all 8 feature blocks from `${CLAUDE_PLUGIN_ROOT}/skills/vault-architect/references/feature-*.md`:
1. **structure** — schema, atomic notes, templates
2. **navigation** — MOCs, wiki-links, graph analysis
3. **processing** — 6R pipeline, session rhythm
4. **intelligence** — methodology knowledge, concept matching
5. **personality** — domain-native voice, self-space
6. **quality** — maintenance, guardrails, helper functions
7. **domains** — multi-domain management
8. **runtime** — identity tracking, metabolic rates, reconciliation loops, gap reports

Adapt each feature block to the user's domain and working style discovered in Phase 1. Do NOT just copy templates verbatim — derive the configuration from the conversation.

## Phase 4: Populate Templates

Create all template files in `/templates/` with proper YAML frontmatter schemas. Each template must include:
- `type:` field matching the template name
- `domain:` field (default to primary domain)
- `created:` date placeholder
- `status:` field (seed | growing | evergreen)
- `connections:` empty list for wiki-links

## Phase 5: Initialize Identity

Create the `self/` space files:
- `identity.md` — derived from conversation (vault purpose, personality, tone)
- `methodology.md` — link to the 6R processing pipeline
- `goals.md` — initial objectives from user's stated intent
- `evolution-log.md` — first entry: "Vault created via vault-tec derivation"

## Phase 6: Validate

Run a quick health check:
- Verify all directories exist
- Verify CLAUDE.md was generated and is non-empty
- Verify at least the master MOC exists
- Verify all templates have valid YAML frontmatter
- Report the vault structure using `tree`

Present the user with a summary: vault location, domain configuration, total files created, and suggested next steps (typically: `/vault-tec:seed` to populate with research).
