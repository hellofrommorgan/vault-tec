# vault-tec radical simplification campaign

Date: 2026-04-30
Branch: auto/vault-tec-radical-simplify-20260430

## Objective

Simplify vault-tec for Morgan's actual operating model: frontier agents with effectively unlimited tokens tend `~/Mind` using the vault's own `AGENTS.md` doctrine. Code should own only mechanics that must be deterministic, idempotent, or safety-critical. Agent judgment should live as instructions.

## Canonical source surfaces

- `~/Mind/AGENTS.md` is the canonical operating doctrine for Morgan's vault.
- `notes/` is canonical knowledge.
- `ops/` is high-churn operational state and reversible staging.
- `vault-tec` repo is the tool/mechanics layer, not a second brain.

## Simplification thesis

Replace rule piles, faux cognitive dashboards, and deterministic imitation of judgment with:

1. tiny deterministic mechanics for safe file movement and replayable witnesses;
2. a small set of markdown agent instructions for Reduce/Reflect/Reweave/Verify/Rethink;
3. one obvious cron bridge that prepares work and asks the agent to do semantic judgment;
4. tests that preserve only load-bearing contracts.

## Code should stay when it protects reality

Keep code for:

- SHA/idempotency/dedupe/provenance;
- atomic writes and no self-fueling loops from `ops/out/`;
- transcript/session ingestion shape conversion;
- PDF-to-markdown ingress;
- raw frontmatter `compile:` dispatch: `whole|sections|skip`;
- compile replay as a deterministic witness/fallback only;
- search/render/refile small CLIs where they provide runtime witness value;
- validation that prevents writes to the wrong vault or wrong surface.

## Code should be deleted or demoted to markdown when it imitates judgment

Delete, shrink, or convert to instructions:

- S.P.E.C.I.A.L., Bobbleheads, Rad Counter, synthetic health scoring;
- giant cognitive-science methodology payloads as active runtime product surface;
- generated vault architecture feature blocks that duplicate `~/Mind/AGENTS.md`;
- commands that are mostly prompts and can be direct markdown SOPs;
- extra hook ceremony that produces theater rather than protecting writes;
- stale Claude-plugin product packaging if it conflicts with Hermes/Copilot actual usage;
- tests that pin deleted scaffolds rather than load-bearing behavior.

## Stopping rubric

A slice is useful only if it materially improves at least one gate:

- [ ] active public docs no longer advertise deleted/scaffolded surfaces;
- [ ] root doctrine says code owns mechanics, agents own judgment;
- [ ] tracked file count materially reduced, with no archive maze under active tree;
- [ ] command/hook/skill surface is minimal and current;
- [ ] deterministic contract suite remains green;
- [ ] at least one runtime witness proves the simplified path still works;
- [ ] crons can be safely re-enabled against `~/Mind` without reviving the shitty vault-tec code path.

## Non-goals

- Do not write directly to `~/Mind/notes/` from this campaign.
- Do not resume or remove Hermes crons as part of repo simplification unless explicitly asked later.
- Do not push.
- Do not preserve historical scaffolds under active docs/tests. Git is the archive.

## Verification baseline

Initial branch baseline:

```text
./verify.sh -> PASS, gating checks 17/17
tracked files -> 113
branch -> auto/vault-tec-radical-simplify-20260430
pushurl -> no_push_allowed_autonomous_loop
```
