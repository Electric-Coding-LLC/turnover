# Define Data Model

[Back to Execution Map](../EXECMAP.md)

## Goal

Define the data model that supports imported runs, app-owned metadata, and
derived calculations.

## Tasks

### Model Principles

- Keep imported Apple Health data separate from app-owned metadata.
- Use a stable workout identifier so app metadata survives re-imports.
- Store only the data needed for display, filtering, and calculations.
- Treat totals and PRs as derived data, not primary stored records.

### Core Entities

### Imported Run

Represents a normalized local snapshot of an eligible outdoor run imported from
Apple Health.

Suggested fields:

- `id`
  Local app identifier if needed by the storage layer
- `healthKitWorkoutId`
  Stable external identifier used to map back to the Apple Health workout
- `source`
  Fixed value for v0, since Apple Health is the only source of truth
- `startDate`
- `endDate`
- `durationSeconds`
- `distanceMeters`
- `isOutdoor`
  Stored as a normalized eligibility flag for the imported run
- `importedAt`
- `updatedAt`

Optional fields if available and useful for v0:

- `sourceAppName`
  Only if needed to help exclude unwanted data during import logic
- `notesForImportState`
  Only if import diagnostics become necessary

### Run Metadata

Represents app-owned data attached to an imported run.

Suggested fields:

- `id`
- `healthKitWorkoutId`
  Foreign key or unique relationship back to the imported run
- `customName`
- `createdAt`
- `updatedAt`

### Tag

Represents a reusable app-owned tag.

Suggested fields:

- `id`
- `name`
- `createdAt`
- `updatedAt`

### RunTag

Represents the relationship between a run and a tag.

Suggested fields:

- `id`
- `healthKitWorkoutId`
- `tagId`
- `createdAt`

## Relationships

- One imported run can have zero or one metadata record.
- One imported run can have zero or many tags through `RunTag`.
- One tag can belong to zero or many runs.
- App-owned metadata should always attach to the imported run through
  `healthKitWorkoutId`.

## Derived Data

The following values should be calculated from stored run data rather than
stored as standalone records for v0:

- current week distance total
- current month distance total
- year-to-date distance total
- average pace values
- PR results for each target distance
- filtered run-history views

This keeps v0 simpler and reduces sync/recalculation complexity.

## Data Needed by Feature

### Summary

Needs:

- `startDate`
- `distanceMeters`
- unit conversion logic
- calendar grouping rules

### Personal Records

Needs:

- `healthKitWorkoutId`
- `startDate`
- `durationSeconds`
- `distanceMeters`
- any additional workout detail required to extract best efforts from longer
  runs

### Run History

Needs:

- `healthKitWorkoutId`
- `startDate`
- `distanceMeters`
- `durationSeconds`
- derived average pace
- `customName`
- associated tags

### Naming and Tagging

Needs:

- stable workout identifier
- metadata record for custom name
- tag records and run-tag mapping

## Constraints

### Storage Rules

- Do not store workouts that fail the v0 eligibility rules.
- Do not store manually entered runs.
- Do not store indoor runs.
- Do not store third-party synced runs included outside the v0 import rules.
- Do not store more HealthKit data than the app actually needs for v0.

## Exit Criteria

- Imported runs, app-owned metadata, and derived values have a clear data model
  with stable relationships.
- Storage rules are explicit enough to support implementation without
  broadening the imported data set.
