# vault-tec

vault-tec is the small deterministic mechanics layer around `~/Mind`.

It is not the mind. It is not the agent. It is not a second doctrine system.

Canonical truth lives in the vault:

- `~/Mind/AGENTS.md` — operating doctrine for agents.
- `~/Mind/notes/` — canonical knowledge.
- `~/Mind/ops/` — staging, reports, inboxes, archives, and other high-churn operations.

vault-tec only owns byte-level mechanics that should not depend on model taste:

- content-addressed refile into `ops/raw/`;
- provenance and SHA idempotency;
- refusing self-fueling paths such as `ops/out/` back into raw;
- deterministic Hermes session shape conversion;
- deterministic inbox drain;
- PDF-to-markdown ingress via MarkItDown;
- deterministic compile replay as a scratch/test witness;
- search/render witnesses over compiled notes.

Agents own semantic judgment: Reduce, Reflect, Reweave, Verify, and Rethink.
Those instructions belong in `~/Mind/AGENTS.md`, not in a pile of duplicate code.

## Core commands

```bash
# Run the whole mechanics gate
./verify.sh

# Refile one markdown source into a vault's ops/raw/ with provenance
bin/vault-refile-append /path/to/source.md /Users/morgan/Mind

# Drain ops/inbox/ into ops/raw/
bin/vault-inbox-drain /Users/morgan/Mind

# Convert a Hermes session transcript into ops/inbox/
bin/vault-ingest-hermes-session --mode=both /Users/morgan/.hermes/sessions/session_x.json /Users/morgan/Mind

# Deterministic replay witness: raw -> notes + compile report in scratch/test vaults
# Refuses live ~/Mind unless VAULT_TEC_ALLOW_LIVE_COMPILE=1 is set for reviewed recovery work
bin/vault-compile-replay /tmp/scratch-mind-vault

# Search compiled notes only
bin/vault-search /Users/morgan/Mind "query"

# Render one compiled note into ops/out/ as derivative markdown
bin/vault-render /Users/morgan/Mind note-slug
```

## Pipeline boundary

```text
external material
  -> ops/inbox/        # loose captures
  -> ops/raw/          # provenance-bearing raw material
  -> agent judgment    # Reduce / Reflect / Reweave / Verify / Rethink from AGENTS.md
  -> notes/            # canonical knowledge
  -> ops/out/          # derivative render/export surface
```

`ops/out/` never feeds `ops/raw/`. Rendered/exported artifacts are derivative.

## Deterministic replay is not semantic compile

`bin/vault-compile-replay` exists so the repo has a fresh-clone-safe runtime witness. It proves shape and contracts without calling an LLM.

It refuses live `~/Mind` by default because replay writes to `notes/`. Use it on scratch/test vaults. Only set `VAULT_TEC_ALLOW_LIVE_COMPILE=1` for explicit reviewed recovery work.

It is deliberately weaker than an agent compile:

- it splits headings;
- it preserves provenance;
- it honors raw frontmatter `compile: whole|sections|skip`;
- it emits a compile report.

It does not decide what is interesting, what connects, or what should be promoted. The frontier model does that with the vault's `AGENTS.md` loaded.

## Verification

`./verify.sh` checks only load-bearing mechanics:

- shell/python entrypoint syntax;
- compile/search/render/refile/provenance witnesses;
- PDF ingest;
- inbox drain;
- Hermes session raw/digest ingest;
- raw frontmatter compile contract.

No hook dashboards, Bobbleheads, Rad counters, synthetic health scores, or duplicate plugin commands remain in the active surface.

## Cron shape

The only cron-safe shape is:

1. prepare bounded deterministic input;
2. preserve provenance/idempotency;
3. ask the agent to perform semantic work using `~/Mind/AGENTS.md`;
4. keep irreversible writes reviewable unless explicitly authorized.

Paused legacy crons that ran compile/curate/promote/tick/synthesis/reflect code should not be resumed without being replaced by this shape.
