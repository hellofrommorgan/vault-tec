---
name: triggers
description: "Run the vault trigger suite: unit tests, integration tests, regression tests. Test-driven knowledge work."
allowed-tools: ["Read", "Glob", "Grep", "Task"]
---

# /vault-tec:triggers

Execute the vault's trigger suite and display a test dashboard.

## Usage

- `/vault-tec:triggers` — Run all trigger suites (unit + integration + regression)
- `/vault-tec:triggers unit` — Run unit triggers only
- `/vault-tec:triggers integration` — Run integration triggers only
- `/vault-tec:triggers regression` — Run regression triggers only

## Execution Flow

1. **Load triggers**: Read trigger definitions from the vault's trigger configuration (or use standard templates from vault-triggers skill)
2. **Scope resolution**: For each trigger, glob the scope pattern to identify target files
3. **Execute checks**: Run each trigger's check function against its targets
4. **Collect results**: Aggregate pass/fail/skip per trigger and per suite
5. **Generate dashboard**: Format results into the dashboard template
6. **Track effectiveness**: Update trigger run counts and false positive rates
7. **Save report**: Write to ops/maintenance/triggers-[DATE].md

## Implementation Notes

- Unit triggers can run in parallel (each note is independent)
- Integration triggers must run sequentially (they depend on graph state)
- Regression triggers reference previous run results
- Use the Task tool for parallel unit trigger execution on large vaults
