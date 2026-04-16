# Define Architecture

## Goal

Set the technical structure for the app before implementation begins.

## Recommended Approach

- Build a native iOS app using Swift and SwiftUI.
- Keep v0 as a single app target with a clear layered structure rather than a
  multi-module setup.
- Use HealthKit as a read-only external data source.
- Use local persistence for imported run snapshots and app-owned metadata.
- Keep calculation logic outside the UI layer.

## Technical Direction

### App Structure

- `App` layer for app entry, navigation setup, and dependency wiring
- `Features` layer for summary, personal records, run history, and run details
- `Services` layer for HealthKit access and sync orchestration
- `Storage` layer for local storage
- `Domain` layer for models and calculations

### UI Layer

- Use SwiftUI for screens and navigation.
- Keep views focused on presentation and user interaction.
- Avoid putting HealthKit queries, persistence logic, or calculation logic
  directly in views.

### State and Flow

- Use screen-level state objects to load and manage data for each feature.
- Use a small shared app-level dependency container to provide access to
  services and persistence.
- Prefer simple unidirectional data flow:
  - user action or app lifecycle event
  - service or sync work
  - persistence update
  - UI refresh from stored data

### HealthKit Boundary

- HealthKit is the only external data source for v0.
- The app should treat HealthKit as read-only.
- All HealthKit access should go through a dedicated service layer.
- The HealthKit service should:
  - request only the permissions needed for outdoor run workouts
  - fetch eligible workouts
  - normalize the returned data into app models
  - avoid exposing raw HealthKit types directly to the UI layer

### Storage Boundary

- Persist imported run data locally so the app can read from a stable local
  store instead of querying HealthKit directly from the UI.
- Persist app-owned metadata separately from imported workout data.
- For v0, prefer a simple Apple-native persistence approach such as SwiftData.
- Keep persistence concerns behind repository-style interfaces so the storage
  choice does not leak into feature code.

### Calculation Boundary

- Totals and PR calculations should live in the domain layer.
- The calculation layer should operate on normalized run data, not on raw
  HealthKit objects.
- Keep calculation code independent from UI and persistence details so it is
  easier to test.

### Sync Model

- Run an automatic import after permission is granted.
- Run an automatic refresh when the app opens.
- Support manual refresh.
- Do not depend on complex background sync behavior for v0.

### Privacy and Security

- Request the minimum HealthKit permissions needed for v0.
- Store only the data needed for import, display, filtering, and calculations.
- Avoid logging sensitive run data in development or production flows.
- Keep app-owned metadata tied to imported workouts through stable identifiers.

### Non-Goals for Architecture

- Multi-target or plugin-based architecture
- Real-time sync architecture
- Complex offline conflict resolution
- Support for multiple workout providers in v0

## Output

- A clear architecture direction for the v0 build
- A layered structure that can guide implementation and the data model
