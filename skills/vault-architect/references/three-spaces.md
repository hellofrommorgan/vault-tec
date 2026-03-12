# Three-Space Architecture

The three-space model separates vault content by cognitive function and growth rate, derived from Tulving's (1985) memory systems theory and Conway's (2005) self-memory system.

## The Spaces

### self/ — Identity Space
**Growth rate**: Slow (tens of files over months)
**Cognitive analog**: Autobiographical memory, self-schema
**Purpose**: Persistent agent identity that survives session boundaries

**Contents**:
- `identity.md` — Who the agent is in this vault. Personality, voice, domain expertise, communication style. Derived during vault creation from conversation.
- `methodology.md` — How knowledge is processed. Links to the 6R pipeline, domain-specific processing rules, quality thresholds.
- `goals.md` — Current objectives. North stars (long-term), active goals (medium-term), current focus (short-term). Updated periodically.
- `evolution-log.md` — Architectural change history. Every structural modification with date, rationale, and research backing.

**Rules**:
- Files here change slowly and intentionally
- Every change should be logged in evolution-log.md
- If self/ files are changing rapidly, the vault's identity is unstable
- Agent should read self/ at session start to orient

### notes/ — Knowledge Space
**Growth rate**: Steady (hundreds to thousands over the vault's lifetime)
**Cognitive analog**: Semantic memory, conceptual knowledge
**Purpose**: The vault's actual knowledge — atomic notes, connected via links, navigated via MOCs

**Structure**:
```
notes/
├── _MOC-Master.md              # Top-level navigation hub
└── domains/
    ├── domain-a/
    │   ├── _MOC-DomainA.md     # Domain navigation hub
    │   ├── topic-mocs/         # Topic-level MOCs
    │   └── [atomic-notes].md   # Individual knowledge notes
    └── domain-b/
        └── ...
```

**Rules**:
- Every note follows an atomic-note template with YAML frontmatter
- Every note belongs to exactly one domain
- Notes connect via [[wiki-links]] — minimum 2 per note
- MOCs organize notes conceptually, not alphabetically
- Status lifecycle: seed → growing → evergreen

### ops/ — Operations Space
**Growth rate**: High churn (daily creation and archival)
**Cognitive analog**: Working memory, procedural memory
**Purpose**: The vault's scratch space — captures, queues, logs, reports

**Structure**:
```
ops/
├── sessions/                   # Session capture logs
│   └── session-YYYY-MM-DD.md
├── inbox/                      # Raw captures awaiting processing
├── tasks/                      # Active task queue (seed jobs, reviews)
└── maintenance/                # Health reports, audit logs
    └── health-YYYY-MM-DD.md
```

**Rules**:
- Files here are disposable — archival, not permanent
- Inbox should be regularly emptied via the processing pipeline
- Session logs capture what happened; they don't need to be polished
- Maintenance reports are generated, not manually written

## Why Three Spaces?

**Cognitive Load Theory** (Sweller 1988): Mixing operational noise with knowledge content increases extraneous cognitive load. Separation reduces it.

**Memory Systems** (Tulving 1985): Human memory has distinct systems (episodic, semantic, procedural) with different storage and retrieval characteristics. The three spaces mirror this.

**Conway's Self-Memory System** (2005): Autobiographical memory (self/) provides the organizational framework for specific knowledge (notes/) and moment-to-moment processing (ops/).

**Practical benefit**: When an agent starts a session, it reads self/ for identity and ops/ for current state — it doesn't need to scan all of notes/. When searching for knowledge, it searches notes/ — it doesn't get noise from ops/. When doing maintenance, it works in ops/ — it doesn't risk corrupting notes/.
