# Golden Principles
> Architecture invariants. Changes that break these require a steering moment.

## P1: Atomicity
One idea per note. If a note carries two or more distinct claims, split it — schema and knowledge-guide enforce this. Violations collapse retrieval precision and make wiki-links ambiguous (Miller 1956).

## P2: Composable titles
Every note title is a noun phrase, 3–10 words, that reads naturally mid-sentence as `[[wiki-link]]`. No verb-initial commands, no questions, no dates. Failure mode: titles that don't compose force paraphrasing at every link site, eroding the graph.

## P3: Every write passes the gate
The `PreToolUse` hook validates YAML frontmatter, description, topics, body wiki-links, and title shape on every note write. There is no bypass path and no silent approval. If the gate is disabled, the vault's integrity guarantees evaporate.

## P4: No dangling references
`${CLAUDE_PLUGIN_ROOT}/PATH` must resolve on disk, and every `[[wiki-link]]` must point at an existing note or a stub the vault knows how to create. Dangling refs are contamination (counted in mR) and must fail loudly.

## P5: MOC reachability ≤ 3 hops
Every atomic note is reachable from `_MOC-Master.md` in three hops or fewer. Deeper burial means the note is effectively orphaned regardless of inbound links. Coverage checks enforce this bound.

## P6: Three-space separation
`self/` (identity, slow), `notes/` (knowledge, steady), `ops/` (workspace, high churn) grow at different rates and serve different cognitive functions (Tulving 1985; Conway 2005). Cross-space writes — e.g., session logs landing in `notes/` — are flagged as F3 contamination.

## P7: Cognitive-science grounding
Architectural additions cite at least one claim from `skills/vault-methodology/references/`. "It feels right" is not a rationale. Ungrounded features accrete into folklore and can't be evaluated or evolved.

## P8: Convention over runtime
Markdown, bash, and Obsidian only. No daemons, databases, or frameworks added to the plugin itself. Every capability must survive a fresh clone with nothing installed. Runtime dependencies turn a vault into infrastructure we have to babysit.

## P9: Personality is local
Vault voice lives exclusively in `self/identity.md`. Commands, skills, hooks, and generators are voice-neutral and reusable across vaults. Leaking Vault-Tec flavor into shared machinery makes the plugin unshippable for non-Fallout vaults.

## P10: Fail loud, not silent
Hooks, `verify.sh`, and health checks surface issues inline with actionable context. Silent skips — swallowed errors, empty exits, untouched counters — are worse than loud failures because they destroy the feedback loop the vault depends on.
