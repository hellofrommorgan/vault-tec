# Feature Block: Domains

**Merges**: multi-domain.md (standalone — retained at full resolution)
**Kernel Primitives**: domain-namespace, three-spaces
**Generates**: Domains section of CLAUDE.md

## Purpose

Define how the vault manages multiple knowledge domains — namespacing, cross-domain connections, and domain lifecycle.

## Generated Content Pattern

```markdown
## Domains

### Domain Structure
Each knowledge domain lives in its own subdirectory under `notes/domains/`:

```
notes/domains/
├── {{DOMAIN_1}}/
│   ├── _MOC-{{Domain1}}.md
│   └── [notes...]
├── {{DOMAIN_2}}/
│   ├── _MOC-{{Domain2}}.md
│   └── [notes...]
└── {{DOMAIN_N}}/
    └── ...
```

### Domain Namespacing
Every note's `domain` frontmatter field identifies its primary home:
- `domain: {{DOMAIN_1}}` — belongs to {{DOMAIN_1}}'s directory and MOC
- Notes can only have ONE primary domain
- Cross-domain connections are made via wiki-links, not dual-domain assignment

### Adding a New Domain
To add a domain:
1. Create the directory: `notes/domains/[new-domain]/`
2. Create the domain MOC: `_MOC-[NewDomain].md`
3. Create a domain entry note using the `domain-entry` template
4. Link the new domain MOC from `_MOC-Master.md`
5. Identify initial seed topics
6. Log the addition in `self/evolution-log.md`

Or use `/vault-tec:create-vault` with the `add-domain` flow.

### Cross-Domain Connections
The most valuable notes are often **bridge concepts** — ideas that connect two domains:
- When you notice the same concept appearing in different domains under different names, create explicit cross-links
- Bridge concepts deserve special attention: they're high-value hubs in the knowledge graph
- Cross-domain reflections (`type: reflection`, `domain: cross-domain`) capture patterns that span domains

### Domain Lifecycle
- **Initializing**: Just created, minimal notes, seeding in progress
- **Active**: Regular note creation and processing, healthy growth
- **Dormant**: No recent activity, but notes are still valuable and connected
- **Archival**: No longer actively developed, but preserved for reference

Track domain health in domain MOC metadata. Dormant domains aren't unhealthy — they just indicate where attention has shifted.

### Domain Balance
For multi-domain vaults, monitor the growth distribution:
- Is one domain drowning out others? → Intentional or drift?
- Are cross-domain links forming? → Good sign of integrated thinking
- Are dormant domains fully connected? → OK. Disconnected dormant domains need linking before archival.
```

## Adaptation Variables

- `{{DOMAIN_1}}, {{DOMAIN_2}}, {{DOMAIN_N}}` — User's domain names
- `{{SINGLE_DOMAIN}}` — If true, simplify to single-domain mode (omit namespacing, cross-domain sections)
- `{{DOMAIN_COUNT}}` — Number of initial domains
