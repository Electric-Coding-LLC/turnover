# Define the Main UI States

## Goal

Define the key UI states the app needs to handle cleanly.

## Covers

- Loading states
- Empty states
- Permission states
- Error states
- Basic success and saved states

## State Principles

- Keep the state model small and predictable.
- Prefer a few durable UI states over many one-off edge-case screens.
- Treat permission, loading, empty, and error handling as states layered onto
  the core screens.
- Keep recovery actions obvious so the user can retry, refresh, or continue
  without guessing.
- Distinguish between:
  - first-use states where no data is available yet
  - transient states where data exists but the app is refreshing or saving

## Global States

These states affect the app broadly and should be designed consistently across
screens.

### 1. Permission Needed

Use when:

- the app does not yet have the HealthKit permission needed to read eligible
  outdoor runs

Must communicate:

- why permission is needed
- that Apple Health data is the only source for v0
- the primary action to grant permission

Primary action:

- request or re-request permission

### 2. Initial Loading

Use when:

- the app is opening for the first time after permission is granted
- the app is importing eligible runs and has not produced usable data yet

Must communicate:

- that the app is importing run data
- that the user should wait rather than take unrelated action

### 3. Refreshing Existing Data

Use when:

- the app already has stored data and is refreshing in the background or from a
  manual refresh action

Must communicate:

- that data is being updated
- that the current content is still usable unless the refresh fails

Preferred treatment:

- keep existing content visible
- use lightweight progress feedback rather than replacing the whole screen

### 4. Global Import Failure

Use when:

- the app cannot complete import or refresh because of a recoverable failure

Must communicate:

- that the latest data update did not complete
- whether existing stored data is still available
- the action to retry

Primary action:

- retry refresh

## Screen-Specific States

### Summary

Must support:

- permission needed
- initial loading
- first import empty state when no eligible runs are available
- partial PR empty state when some target distances do not yet have qualifying
  efforts
- refreshing existing data
- refresh failure with retry

Empty-state guidance:

- If no runs exist yet, focus the message on importing eligible outdoor runs.
- If runs exist but some PR distances do not, keep totals and available PRs
  visible and mark only the missing PR items as unavailable.

### Runs

Must support:

- initial loading
- no runs imported yet
- empty filtered-results state
- refreshing existing data
- refresh failure with retry

Empty-state guidance:

- Distinguish between:
  - no imported runs at all
  - no runs matching the active filters

Recovery actions:

- retry refresh when import failed
- clear filters when the current filters exclude all runs

### Run Detail

Must support:

- loading detail content when opened
- metadata save in progress
- metadata save success feedback
- metadata save failure with retry

Editing guidance:

- Keep the run data visible while saving metadata when practical.
- Saving name or tags should not force the user out of `Run Detail`.

## Success and Saved States

Use lightweight success feedback for:

- successful refresh started from a manual action
- successful name change
- successful tag add or remove

Preferred treatment:

- brief inline confirmation, status text, or equivalent lightweight feedback
- avoid full success screens

## Validation States

The app should explicitly handle:

- empty custom name input if the user tries to save a blank name in an edit mode
  that requires content
- duplicate tag name creation if tag creation is allowed from the run-detail
  flow

Preferred treatment:

- show the problem close to the input
- keep the user in the current editing context

## States Not Needed in v0

- No offline-only mode with a separate visual treatment
- No multi-step sync conflict state
- No background sync center or activity log state
- No celebratory success screens after simple saves
- No complex skeleton-state system if straightforward loading treatments are
  sufficient

## Output

- A list of UI states that must be designed and implemented
