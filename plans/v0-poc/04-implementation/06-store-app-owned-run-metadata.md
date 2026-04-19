# Store App-Owned Run Metadata

[Back to Execution Map](../EXECMAP.md)

## Goal

Store the data that belongs to the app rather than Apple Health.

## Tasks

- Custom run names
- Run tags
- The relationship between app metadata and imported workouts

## Constraints

- Keep app-owned metadata separate from imported HealthKit data.
- Tie metadata to imported workouts through the stable workout identifier.

## Exit Criteria

- The app has a local metadata model for run names and tags tied to imported
  runs.
- Metadata persistence is ready for naming, tagging, and filtering features.
