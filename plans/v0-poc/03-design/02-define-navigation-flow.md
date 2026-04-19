# Define the Navigation Flow

[Back to Execution Map](../EXECMAP.md)

## Goal

Decide how the user moves through the app.

## Tasks

### Covers

- The primary entry points
- The relationship between list, detail, and editing views
- The simplest navigation model that fits v0

### Recommended Navigation Model

- Use a two-tab app structure:
  - `Summary`
  - `Runs`
- Give each tab its own navigation stack.
- Present `Run Detail` by pushing from either tab's stack.
- Present naming and tagging edits from `Run Detail` using sheets or inline edit
  controls rather than separate full-screen flows.

### Primary Entry Points

### Summary Tab

Use as:

- the default selected tab on app launch
- the main home for progress review
- the place where the user sees totals, PRs, and refresh status first

Primary onward paths:

- tap a PR item to open the associated `Run Detail`
- tap a runs entry point to switch to or open `Runs`

Top chrome:

- no visible page title required by default
- no dedicated visible refresh button required by default

### Runs Tab

Use as:

- the main destination for browsing imported runs
- the place for filtering by date range and tags

Primary onward paths:

- tap a run row to open `Run Detail`
- adjust filters and remain in the same screen context

Top chrome:

- no visible page title required by default

### Detail and Editing Flow

### Run Detail

Entry paths:

- from a PR result on `Summary`
- from a run row on `Runs`

Behavior:

- open in the current tab's navigation stack
- show run information and app-owned metadata together
- let the user edit the run name and tags without leaving the detail context

Editing model:

- use a sheet, confirmation dialog, or inline editing for name changes
- use a sheet or focused picker/editor for tag assignment
- return to the same `Run Detail` view after save

### Save Result

After editing:

- keep the user on `Run Detail`
- show lightweight saved feedback
- reflect the updated name or tags immediately in detail
- let upstream screens reflect the change when the user goes back

### Back Navigation Rules

- From `Run Detail`, back returns to the exact screen that launched it.
- From `Runs`, switching tabs preserves the current list state and active
  filters if practical.
- From `Summary`, automatic refresh behavior and unit-toggle actions should not
  navigate away from the screen.

### Flow Summary

### Default review path

- Launch app
- Open `Summary`
- Review totals and PRs
- Open a PR-linked run in `Run Detail`
- Return to `Summary`

### Browse-and-edit path

- Open `Runs`
- Filter or scan the list
- Open a run in `Run Detail`
- Edit name or tags
- Return to `Runs`

### Flows Not Needed in v0

- No onboarding carousel or multi-step intro flow
- No separate personal-records tab
- No standalone settings flow
- No standalone tag-management flow
- No multi-screen edit wizard for run metadata

## Constraints

### Navigation Principles

- Keep top-level navigation shallow.
- Make `Summary` the default home because it combines import status, totals,
  and personal records.
- Give `Runs` equal top-level access because browsing and filtering runs is a
  distinct primary task.
- Keep top chrome minimal and avoid duplicating what the bottom tabs already
  communicate.
- Keep editing close to the run being edited instead of creating separate
  management areas.
- Avoid navigation branches for features that are out of scope for v0.

## Exit Criteria

- The app has a clear navigation model that covers summary, runs, detail, and
  metadata editing flows.
- Back-navigation and editing behavior are explicit enough to guide
  implementation without extra flow documents.
