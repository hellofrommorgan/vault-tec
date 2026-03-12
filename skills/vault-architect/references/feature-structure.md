# Feature Block: Structure

**Merges**: schema.md + atomic-notes.md + templates.md
**Kernel Primitives**: atomic-note, yaml-schema, template-system
**Generates**: Architecture section of CLAUDE.md

## Purpose

Define the structural foundation of the vault — how notes are shaped, what metadata they carry, and what templates enforce consistency.

## Generated Content Pattern

```markdown
## Architecture

### Three Spaces
This vault uses a three-space architecture:
- **self/** — Your identity. Slow-changing. Read at session start.
- **notes/** — Your knowledge. Steady growth. Organized by domain.
- **ops/** — Your workspace. High churn. Sessions, inbox, tasks.

### Note Schema
Every note MUST have YAML frontmatter with these required fields:
- `type`: Note type (atomic-note, moc, source-note, reflection, seed-task, session-log, domain-entry)
- `domain`: Primary knowledge domain (e.g., {{DOMAIN}})
- `created`: Creation date (YYYY-MM-DD)
- `status`: Maturity level (seed | growing | evergreen)
- `connections`: List of wiki-links to related notes

### Atomic Note Principle
Each note contains exactly ONE idea. Signs a note isn't atomic:
- You need more than one sentence to state its core idea
- It covers multiple concepts that could exist independently
- You find yourself wanting to link to "part of" the note
When in doubt, split.

### Template System
Note templates live in `templates/`. They define the canonical YAML schema for each note type. When creating a new note:
1. Identify the note type
2. Copy the template's frontmatter
3. Fill in all required fields
4. Never omit required fields — the schema is enforced
```

## Adaptation Variables

- `{{DOMAIN}}` — User's primary domain name
- `{{NOTE_TYPES}}` — Which note types this vault uses (not all vaults need all 7)
- `{{SCHEMA_STRICTNESS}}` — How strict schema enforcement should be:
  - **strict**: All fields required, hook-enforced
  - **moderate**: Required fields enforced, optional fields encouraged
  - **relaxed**: Only type and domain required, rest is flexible
