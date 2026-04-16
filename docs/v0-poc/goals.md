# Goals

## Product Goal

Build a simple iOS app for reviewing running history and progress using run
workout data captured on the phone.

## V0 Scope

The first version should focus on import, summary, history, and lightweight
organization. It does not need training plans, social features, coaching, or
advanced analytics.

## Data Source

- The app is an iOS app.
- The app uses run workout data available on the phone.
- For v0, Apple Health / Apple workout data is the only source of truth.
- The app should only read data that the user has granted permission to access.

## Core Needs

### 1. Import Run Workouts

- The app needs to load past run workouts from phone data.
- The app should support outdoor runs only.
- For this POC, the app should not include runs recorded by third-party apps
  that sync into Apple Health.
- For this POC, the app should not include manually entered runs.

### 2. Show Distance Totals

- The app needs to show total distance for:
  - current week
  - current month
  - year to date
- Totals should be based on the user's local calendar and timezone.
- The week should start on Monday.
- Distance totals should default to miles.
- The app should let the user toggle between miles and kilometers.

### 3. Show Personal Records

- The app needs to show personal records for:
  - 400m
  - 800m
  - 1 mile
  - 5K
  - 10K
  - half marathon
  - marathon
- For each distance, the app should show:
  - best time
  - average pace for that effort
  - date of the effort
  - run associated with the effort
- For this POC, PRs should be calculated by extracting the best effort for each
  target distance, including from longer runs.

### 4. Show Run History

- The app needs a list of past runs.
- Each run in the list should include at least:
  - date
  - distance
  - duration
  - average pace
- The default sort should be newest first.
- The run list should support filtering by tagged runs.
- The run list should support filtering by date range.

### 5. Name and Tag Runs

- The user needs to be able to add a custom name to a run.
- The user needs to be able to add one or more tags to a run.
- Names and tags are app-specific metadata and should not depend on the source
  workout provider supporting them.

## Non-Goals For V0

- Training plan generation
- Workout creation
- Social sharing
- Route analysis and maps
- Heart rate analytics
- Coaching or recommendations
