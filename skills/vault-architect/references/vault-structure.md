# Complete Vault Directory Structure

Reference specification for the full vault scaffold created by `/vault-tec:create-vault`.

## Directory Tree

```
vault-name/
├── .obsidian/                          # Obsidian application config
│   ├── app.json                        # Core settings
│   └── appearance.json                 # Theme settings (optional)
│
├── self/                               # IDENTITY SPACE (slow growth)
│   ├── identity.md                     # Agent persona, voice, expertise
│   ├── methodology.md                  # Processing rules, quality standards
│   ├── goals.md                        # North stars, active goals, focus
│   └── evolution-log.md               # Architectural change history
│
├── notes/                              # KNOWLEDGE SPACE (steady growth)
│   ├── _MOC-Master.md                  # Root navigation hub
│   └── domains/                        # Domain-organized knowledge
│       └── [domain-name]/
│           ├── _MOC-[Domain].md        # Domain navigation hub
│           ├── topic-mocs/             # Topic-level MOCs (optional)
│           │   └── _MOC-[Topic].md
│           └── [atomic-notes].md       # Knowledge notes
│
├── ops/                                # OPERATIONS SPACE (high churn)
│   ├── sessions/                       # Session logs
│   │   └── session-YYYY-MM-DD.md
│   ├── inbox/                          # Unprocessed captures
│   ├── tasks/                          # Active task queue
│   │   └── seed-[topic].md            # Research seed tasks
│   └── maintenance/                    # Health & audit reports
│       └── health-YYYY-MM-DD.md
│
├── templates/                          # NOTE TYPE TEMPLATES
│   ├── atomic-note.md                  # Single-concept knowledge note
│   ├── moc.md                          # Map of Content hub
│   ├── source-note.md                  # Source/reference documentation
│   ├── reflection.md                   # Metacognitive reflection
│   ├── seed-task.md                    # Research seeding task
│   ├── session-log.md                  # Session capture template
│   └── domain-entry.md                # New domain initialization
│
└── CLAUDE.md                           # AGENT SYSTEM PROMPT (generated)
```

## File Naming Conventions

- **Directories**: kebab-case (`my-domain/`, `topic-mocs/`)
- **Notes**: kebab-case descriptive names (`quantum-entanglement.md`, `attention-mechanism.md`)
- **MOCs**: Prefixed with `_MOC-` and PascalCase topic (`_MOC-MachineLearning.md`)
- **Templates**: kebab-case type name (`atomic-note.md`, `source-note.md`)
- **Session logs**: `session-YYYY-MM-DD.md` (with optional `-N` suffix for multiple sessions)
- **Health reports**: `health-YYYY-MM-DD.md`

## .obsidian/app.json Minimal Config

```json
{
  "strictLineBreaks": false,
  "showFrontmatter": true,
  "defaultViewMode": "source",
  "livePreview": true,
  "readableLineLength": true,
  "showLineNumber": false
}
```

## Initialization Checklist

After scaffolding, verify:
- [ ] All 3 space directories exist (self/, notes/, ops/)
- [ ] All ops/ subdirectories exist (sessions/, inbox/, tasks/, maintenance/)
- [ ] At least one domain directory in notes/domains/
- [ ] All 7 templates present in templates/
- [ ] All 4 self/ files present and populated
- [ ] _MOC-Master.md exists and links to domain MOC(s)
- [ ] CLAUDE.md exists and is non-empty
- [ ] .obsidian/app.json exists with basic config
