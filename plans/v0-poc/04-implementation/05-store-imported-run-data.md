# Store Imported Run Data

[Back to Execution Map](../EXECMAP.md)

## Goal

Persist the imported workout data needed by the app.

## Tasks

- Storage of imported run fields
- Stable identifiers for imported workouts
- Data shape needed for totals, PRs, and history

## Constraints

- Persist only the imported fields needed for display, filtering, and
  calculations.
- Preserve stable identifiers so app-owned metadata can survive re-imports.

## Exit Criteria

- Imported runs are stored locally in a stable form that matches the data
  model.
- Downstream totals, records, and history features can read from the local run
  store instead of raw HealthKit queries.
