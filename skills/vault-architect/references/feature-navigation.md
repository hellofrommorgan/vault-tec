# Feature Block: Navigation

**Merges**: mocs.md + wiki-links.md + graph-analysis.md
**Kernel Primitives**: moc, wiki-link, domain-namespace
**Generates**: Navigation section of CLAUDE.md

## Purpose

Define how knowledge is discovered, traversed, and analyzed within the vault — the linking topology, MOC hierarchy, and graph-level operations.

## Generated Content Pattern

```markdown
## Navigation

### Maps of Content (MOCs)
MOCs are navigation hubs, not folders. They organize notes by conceptual relationship — grouping ideas that illuminate each other.

**Hierarchy**:
- `_MOC-Master.md` — The vault's root hub. Links to all domain MOCs.
- `_MOC-[Domain].md` — One per domain. Links to topic MOCs and key atomic notes.
- `_MOC-[Topic].md` — Optional. For subtopics that accumulate enough notes (>10).

**MOC Creation Rules**:
- Create a topic MOC when a cluster of >10 related notes forms
- MOCs should have 1-2 sentence descriptions for each linked note
- Organize by conceptual relationship (not alphabetically)
- Include an "Open Questions" section for unresolved ideas
- Link back to parent MOC

### Wiki-Links
Connect notes using [[double bracket]] links. Links represent semantic relationships — conceptual proximity, dependency, contrast, or evolution.

**Linking Conventions**:
- Every note: minimum 2 outgoing wiki-links
- Place links in body text where they're contextually relevant (not just in frontmatter)
- Link types (implicit by context):
  - "builds on [[X]]" — dependency
  - "contrasts with [[X]]" — opposition
  - "example of [[X]]" — instantiation
  - "evolved from [[X]]" — temporal development

**Spreading Activation**: When you visit a note, its linked notes become "activated" — more likely to be relevant. This is why link quality matters: good links create useful activation patterns.

### Graph Analysis
Commands for understanding the vault's topology:

- `/graph` — Report on the vault's connection structure:
  - Total nodes (notes) and edges (links)
  - Average connections per note
  - Most-connected notes (hubs)
  - Orphan notes (0 connections)
  - Cluster detection (groups of tightly-linked notes)

- `/stats` — Quick metrics:
  - Note count by type and domain
  - Status distribution (seed/growing/evergreen)
  - Connection density
  - MOC coverage (% of notes reachable from a MOC)
```

## Adaptation Variables

- `{{MOC_THRESHOLD}}` — Note count that triggers topic MOC creation (default: 10)
- `{{MIN_LINKS}}` — Minimum outgoing links per note (default: 2)
- `{{GRAPH_COMMANDS}}` — Whether to include graph analysis commands (omit for small vaults)
