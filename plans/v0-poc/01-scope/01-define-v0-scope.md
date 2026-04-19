# Define the v0 Scope

[Back to Execution Map](../EXECMAP.md)

## Goal

Lock the release scope by defining what is in and out of v0.

## Tasks

### Release Objective

Deliver a simple iOS app that lets the user review outdoor running history and
progress using Apple Health workout data.

### In Scope

- iOS app
- Apple Health as the only source of truth
- Outdoor runs only
- Import of eligible outdoor run workouts from Apple Health
- Automatic import after permission is granted and when the app is opened
- Manual refresh of imported run data
- Distance totals for current week, current month, and year to date
- Week totals starting on Monday
- Distance totals shown in miles by default with a miles/kilometers toggle
- Personal records for:
  - 400m
  - 800m
  - 1 mile
  - 5K
  - 10K
  - half marathon
  - marathon
- PR display including:
  - best time
  - average pace
  - date
  - associated run
- PR calculation from best efforts extracted from longer runs
- Run history list
- Run history sorted newest first
- Run history filters for date range and tags
- Custom run naming
- Run tagging with one or more tags

## Out of Scope

- Indoor runs
- Manually entered runs
- Third-party synced runs
- Training plans
- Workout creation
- Social features
- Route analysis and maps
- Heart rate analytics
- Coaching or recommendations

## Constraints

- The release should stay focused on import, summary, history, and lightweight
  organization.
- Features that do not directly support those outcomes should be deferred.
- Apple Health access should be limited to the minimum data needed for v0.
- App-owned metadata should be limited to names and tags for runs.
- v0 should not depend on complex background sync behavior.

## Exit Criteria

- The v0 scope is explicit enough to guide design and implementation without
  reopening core product questions.
- In-scope and out-of-scope lists are concrete enough to prevent feature drift
  during the release.
