# ops/raw/

`ops/raw/` holds provenance-bearing raw material waiting for agent judgment.

Raw files are not canonical thoughts. They are evidence.

Expected path:

```text
ops/inbox/  -> loose capture
ops/raw/    -> content-addressed raw with provenance
notes/      -> canonical knowledge after agent Reduce/Reflect/Reweave/Verify/Rethink
ops/out/    -> derivative exports/renders
```

`bin/vault-compile-replay <vault>` may replay raw files into `notes/` for deterministic tests and fallback recovery. That replay proves shape only. It is not a substitute for semantic compile by a frontier agent reading the vault's `AGENTS.md`.
