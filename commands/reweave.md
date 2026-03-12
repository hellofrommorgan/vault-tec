---
name: reweave
description: "Surface stale notes and guide a reweave workflow. Small-batch maintenance: 1-2 notes per session."
allowed-tools: ["Read", "Glob", "Grep", "Write", "Edit", "Task"]
---

# /vault-tec:reweave

Backward maintenance command. Surfaces notes that haven't been touched in a while and guides the user through updating them with new context.

## Staleness Detection

A note is stale if ANY of:
- Last modified >{{REWEAVE_STALENESS_DAYS}} days ago (default: 60)
- Has <3 incoming links (underconnected)
- Has 0 modifications since creation (never reweaved)
- A newer note contradicts or supersedes it (detected via keyword overlap + different conclusions)

## Selection Algorithm

From all stale notes, select 1-2 per session using:
1. **Priority score** = staleness_days × (1 / connection_count) × domain_importance
2. **Diversity**: Don't select two notes from the same domain
3. **Small-batch psychology**: Never suggest more than 2. Maintenance should feel manageable, not overwhelming.

## Reweave Workflow

For each selected note:

1. **Context Refresh**: "This note was last modified [N] days ago. Since then, [M] new notes have been created."

2. **Fresh Eyes Test**: "If you wrote this today, knowing what you know now, what would be different?"

3. **New Connection Scan**: Search notes created AFTER the stale note for:
   - Same domain, related concepts → potential new wiki-links
   - Different domain, shared terminology → potential cross-domain bridge
   - Contradictory claims → tension to resolve or note

4. **Integration**: Apply changes:
   - Add new wiki-links discovered
   - Update claims if newer evidence exists
   - Adjust confidence level if warranted
   - Update status if appropriate
   - Log reweave in the note's body: `> Reweaved [DATE]: [brief description of changes]`

5. **Evolution Tracking**: Append to note body:
   ```
   ## Reweave History
   - [DATE]: [what changed and why]
   ```

## Output Format

```
REWEAVE CANDIDATES — [Date]
═══════════════════════════

1. [[Note Title]] (domain: X)
   Last modified: [N] days ago
   Connections: [N] (below average of [M])
   New related notes since: [list of 2-3]
   Reason: [staleness | underconnected | superseded]

2. [[Note Title]] (domain: Y)
   ...

Pick one to reweave, or type 'both' for a mini-session.
```
