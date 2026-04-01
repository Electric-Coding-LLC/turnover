# Turnover - Step 9: Integrate Storage And Platform APIs

## Goal

Replace the in-memory Step 8 adapters with local persistence and platform-backed services so live runs, settings, and completed history survive app launches and can use real device data.

## Tasks

- Add durable local storage for settings and completed run history
- Replace the mock tracking service with a Core Location-backed implementation for live run input
- Surface real authorization and availability state for location and optional heart rate integration
- Persist finalized run payloads without changing the Step 8 domain rules
- Keep the implementation local-only for V1 and avoid introducing backend or sync work

## Deliverables

- A documented Step 9 plan for persistence, platform adapters, and app wiring
- Concrete storage-backed implementations for the Step 8 interfaces:
  - `RunSettingsReading`
  - A new settings write/update interface for persisted user preferences
  - `RunHistoryReading`
  - `FinalizedRunWriting`
  - `RunPlatformStatusProviding`
- A production `RunTrackingService` implementation that converts platform events into `RunTrackingSnapshot`
- A local persistence model for:
  - User settings
  - Completed run summaries and supporting run detail data
  - Enough metadata to rebuild history metrics and run detail views after relaunch
- A permission and availability flow that can represent:
  - Not determined
  - Authorized
  - Denied
  - Tracking unavailable on device
  - Heart rate unavailable or unsupported
- A defined refresh or observation path for platform status changes so permission updates can reach app state after launch
- A dependency composition path that can swap the app off `TurnoverAppDependencies.inMemory()` for a local production setup

## Scope

### 1. Local Persistence

- Persist `SettingsSnapshot` locally so the settings screen no longer depends on sample data
- Add a persisted settings write path so changes made in the settings screen can be saved and reloaded
- Persist completed run outputs produced by `FinalizedRunPayload`
- Store the fields already needed by the app shell:
  - Run identity and start date
  - Distance, elapsed time, and moving time
  - Average pace and optional heart rate summary
  - Elevation gain
  - Route shape or an equivalent locally stored route representation
  - Split summaries, heart rate zones, and personal-record annotations used by the current detail UI
- Keep storage local to the device for V1; do not add sync, sharing, or remote services
- Keep schema choices small and explicit so later migrations remain manageable

### 2. Tracking Adapter

- Replace `MockRunTrackingService` with a real adapter backed by Core Location
- Translate location updates into the `RunTrackingSnapshot` shape expected by Step 8 business logic
- Keep pause and resume behavior consistent with the session rules already defined in Step 8
- Support background-safe active tracking only to the extent already enabled by Step 5 capabilities
- Continue to treat heart rate as optional so a run can proceed when HealthKit is unavailable or not yet granted

### 3. Platform Status And Permissions

- Implement a real `RunPlatformStatusProviding` adapter using current authorization and hardware availability state
- Define how location authorization transitions refresh app state after launch without leaking Core Location types into the view layer
- Revisit HealthKit only as an optional extension for heart rate reads and availability reporting
- If heart rate remains deferred in implementation, keep the interface honest by reporting unavailable instead of synthesizing data
- Keep permission prompting, status refresh, and settings deep-link behavior contained within adapter or app-composition boundaries
- If the current one-time `currentPlatformStatus()` read is insufficient, add a small observation or refresh seam instead of pushing platform framework types into `TurnoverAppState`

### 4. App Integration

- Replace the in-memory dependency graph with a production dependency assembly path
- Load persisted settings and history during app startup
- Update `TurnoverAppState` only as needed to support persisted settings updates and refreshed platform status while keeping protocol-based dependencies in front of platform frameworks
- Ensure finishing a run writes durable data before refreshing history-derived metrics
- Preserve the Step 7 and Step 8 navigation and lifecycle behavior while swapping in production adapters

### 5. Deferred Work

- Do not add cloud sync, user accounts, or social sharing
- Do not broaden Step 9 into watchOS support
- Do not take on advanced migration tooling unless the first storage format requires it
- Do not expand V1 into post-hoc workout editing or import flows

## Decisions

- Keep Step 9 focused on adapter replacement and persistence, not a redesign of Step 8 domain logic
- Treat Core Location as required for V1 live tracking
- Treat HealthKit heart rate integration as optional, even if its adapter is added in this step
- Keep all persistence on-device for V1
- Prefer adapters that map platform data into the existing domain contracts instead of making the UI depend on Apple frameworks directly
- Prefer small interface additions for settings writes and platform-status refresh over broad app-state refactors
- Accept a small storage model that duplicates some derived display data if that keeps the read path simple for V1

## Assumptions

- The Step 8 contracts are the intended seam for production integration and should not be replaced casually
- Current completed-run UI can continue rendering from summary-shaped stored data rather than requiring raw sample streams to be replayed
- Step 5 location capability work is already present and only needs to be consumed by Step 9 code
- V1 can tolerate local-only history storage with no import or sync recovery path

## Exit Criteria

- Step 9 responsibilities and non-goals are documented clearly
- There is a defined plan for replacing every in-memory Step 8 dependency with a production adapter
- The storage plan covers settings and completed runs with enough detail to support the existing history and detail screens after relaunch
- The plan explicitly covers how settings changes are written back to local storage
- The tracking plan explains how live platform data will be translated into `RunTrackingSnapshot`
- Permission and availability handling is explicit enough to implement without leaking framework concerns into the view layer
- The plan explicitly covers how platform status changes propagate into app state after the initial load
- The plan leaves testing, simulator/device validation, and bug-fixing work for Steps 10 and 11 without ambiguity
