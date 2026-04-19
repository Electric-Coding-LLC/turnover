# Define the Core Screens

[Back to Execution Map](../EXECMAP.md)

## Goal

Identify the minimum set of screens needed for the release.

## Tasks

### Covers

- The summary experience
- The personal records experience
- The runs experience
- The run detail and editing experience

### Core Screens

### 1. Summary Screen

Purpose:

- Act as the default landing screen for the app.
- Give the user a fast read on recent progress without making them drill into
  lists first.

Must include:

- current week distance total
- current month distance total
- year-to-date distance total
- a personal-records section covering the v0 target distances:
  - 400m
  - 800m
  - 1 mile
  - 5K
  - 10K
  - half marathon
  - marathon
- best time for each available PR
- average pace for the best effort
- date of the effort
- a link from each PR result to the associated run
- unit toggle for miles and kilometers
- visible indication of import or refresh state when relevant
- a clear path to the full runs view

Should also handle:

- permission-needed state before HealthKit access is granted
- first-import empty state
- no-record-yet state when the user does not yet have qualifying efforts for
  one or more PR distances
- refresh-in-progress state
- refresh failure state

Reason to keep it:

- The app needs one obvious home for progress review and import status.
- Totals and PRs are core product needs and belong together in the default
  review surface.

Top chrome guidance:

- Do not require a visible page title on `Summary` if the active bottom tab
  already makes the section clear.
- Do not require a dedicated visible refresh button on `Summary`.

### 2. Runs Screen

Purpose:

- Let the user browse imported runs and narrow the list when they want to find
  a specific period or set of tagged runs.

Must include:

- reverse-chronological run list
- date for each run
- distance for each run
- duration for each run
- derived average pace for each run
- filter controls for date range
- filter controls for one or more tags
- a path into run detail

Should also handle:

- empty history state when no eligible runs have been imported
- empty filtered-results state when filters exclude all runs
- refresh state when imported data changes

Reason to keep it:

- History browsing and filtering is a distinct task from high-level progress
  review.

### 3. Run Detail Screen

Purpose:

- Show the full context for a single imported run and provide lightweight
  editing for app-owned metadata.

Must include:

- run date
- distance
- duration
- derived average pace
- custom run name if one exists
- associated tags
- edit affordance for custom naming
- edit affordance for adding or removing tags

Should also handle:

- saved-state feedback after editing metadata
- basic validation for empty or duplicate tag names if tag creation happens here

Reason to keep it:

- Naming and tagging need a stable place to live.
- A dedicated detail view avoids overloading the list with editing controls.

### Screens Not Needed in v0

- No dedicated settings screen is required if the distance unit can be changed
  inline from the main product UI.
- No dedicated personal-records screen is required if PRs can live as a section
  on the summary screen.
- No standalone tag-management screen is required; tags can be created and
  assigned while editing a run.
- No separate import-history or sync-debug screen is required for v0.
- No separate edit-name or edit-tags full-screen flow is required if sheets or
  inline editing are sufficient.

### Minimum Screen Set

- Summary
- Runs
- Run Detail

## Constraints

### Screen Principles

- Keep v0 focused on review and lightweight organization, not workout creation
  or coaching.
- Use the fewest screen-level surfaces needed to cover the in-scope features.
- Keep naming and tagging attached to a run rather than split into separate
  management areas.
- Treat permission, loading, empty, and error handling as UI states layered
  onto core screens, not as a large set of extra screens.

## Exit Criteria

- The minimum screen set is explicit enough to guide navigation and
  implementation work.
- Screen responsibilities are narrow enough that v0 does not sprawl into
  separate management or settings surfaces.
