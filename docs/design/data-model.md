# Turnover Data Model Design

## Goal

Define the core app entities and relationships before building feature screens or wiring platform services.

## V1 Decisions

- Keep the model storage-agnostic in Step 4 and choose the concrete persistence layer during implementation
- Create a `RunSession` when tracking starts, and create a `Run` only when the workout is finalized
- Do not include route smoothing or elevation correction in V1; use recorded data with only basic validity filtering
- Make heart rate optional; runs may exist without heart rate samples, and heart rate summaries should be absent when no data is available
- Materialize personal records when a run is finalized, using raw samples as the source of truth if records ever need to be recomputed
- Keep run event history for completed runs in V1 so timing can be audited and recalculated if needed

## Core Entities

### Run

Represents a finalized workout stored in run history.

Suggested fields:

- `id`
- `startedAt`
- `endedAt`
- `elapsedTime`
- `movingTime`
- `distance`
- `elevationGain`
- `averageHeartRate`
- `maxHeartRate`
- `notes`

Notes:

- `Run` is created only when a session is finalized
- `averageHeartRate` and `maxHeartRate` should be optional when no heart rate source is available
- Pace is derived from distance and moving time rather than stored as a canonical field

### RunSession

Represents the live state of an in-progress run while tracking is active.

Suggested fields:

- `id`
- `runId` optional
- `startedAt`
- `endedAt`
- `state`
- `elapsedTime`
- `movingTime`
- `pausedTime`

Possible states:

- `idle`
- `running`
- `paused`
- `completed`

Notes:

- `RunSession` exists before any `Run` record exists
- `runId` is set only if completed session history is retained after finalization

### RunEvent

Represents lifecycle transitions used to reconstruct timing accurately.

Suggested fields:

- `id`
- `runSessionId`
- `timestamp`
- `type`

Possible types:

- `start`
- `pause`
- `resume`
- `stop`

### RoutePoint

Represents a recorded GPS sample stored with a finalized run.

Suggested fields:

- `id`
- `runId`
- `timestamp`
- `latitude`
- `longitude`
- `altitude`
- `horizontalAccuracy`
- `verticalAccuracy`

Notes:

- Live GPS samples may be buffered in memory during an active session and persisted to `Run` when the workout is finalized

### Split

Represents an auto-generated segment such as a mile or kilometer split.

Suggested fields:

- `id`
- `runId`
- `index`
- `startDistance`
- `endDistance`
- `startTimestamp`
- `endTimestamp`
- `distance`
- `duration`
- `averageHeartRate`

Notes:

- Splits should be generated from `distanceUnit` or `splitUnit` settings rather than hard-coded
- Pace is derived from distance and duration rather than stored as a canonical field

### HeartRateSample

Represents a captured heart rate reading stored with a finalized run.

Suggested fields:

- `id`
- `runId`
- `timestamp`
- `bpm`

Notes:

- Heart rate samples are optional for a run
- Live heart rate samples may be buffered in memory during an active session and persisted to `Run` when the workout is finalized

### PersonalRecord

Represents a best effort over a standard distance based on recorded runs.

Suggested fields:

- `id`
- `standardDistance`
- `duration`
- `runId`
- `achievedAt`
- `startDistance`
- `endDistance`
- `startTimestamp`
- `endTimestamp`

Notes:

- `standardDistance` should be a fixed V1 enum: `400m`, `800m`, `mile`, `5k`, `10k`, `halfMarathon`, `marathon`
- Personal records should be stored after run finalization for fast stats and history views
- Raw route, timing, and heart rate data remain the source of truth if record logic changes later

## Relationships

- One `RunSession` has many `RunEvent` records
- One `RunSession` may produce zero or one `Run`
- One completed `RunSession` may retain a link to its finalized `Run`
- One `Run` has many `RoutePoint` records
- One `Run` has many `Split` records
- One `Run` has many `HeartRateSample` records
- One `Run` may produce zero or more `PersonalRecord` updates

## Derived Metrics

These should be computed from stored run data rather than entered manually:

- Pace
- Splits
- Weekly mileage
- Monthly mileage
- Heart rate zone breakdown
- Personal records

## Canonical Units

- Distance: meters
- Elevation: meters
- Duration: seconds
- Timestamps: `Date` values in UTC
- Heart rate: beats per minute
- Pace: derived from distance and duration

## Settings And Profile Inputs

These values are not properties of a single run, but they affect how runs are recorded or analyzed:

### UserSettings

Suggested fields:

- `distanceUnit`
- `splitUnit`
- `autoPauseEnabled`

### RunnerProfile

Suggested fields:

- `birthDate`
- `sex` if needed for health integrations
- `restingHeartRate`
- `maxHeartRate`
- `heartRateZoneMethod`

Heart rate zones and split presentation should read from settings/profile data rather than being hard-coded into run records.

## Model Rules

- A discarded `RunSession` does not create a `Run`
- Lifecycle state lives in `RunSession` and `RunEvent`, not in `Run`
- Raw route, timing, and heart rate samples are the source of truth
- Summary values and personal records are derived from raw data and may be materialized for faster reads
- Completed runs retain event history in V1

## Storage Direction

Default direction for V1:

- Store everything locally on device
- Avoid backend or sync concerns
- Choose a persistence layer that works cleanly with SwiftUI and offline use

For Step 4, keep the model storage-agnostic and finalize the concrete persistence choice during implementation. The model should still distinguish between persisted history, live tracking state, and user configuration.
