# Turnover - Step 6: Build Core SwiftUI Screens

## Goal

Replace the placeholder app UI with the core V1 screen shells needed for run tracking, history, analytics, and settings.

## Tasks

- Define the minimum V1 screen set to support the product goals from Step 1
- Build SwiftUI screen shells and reusable sections for those screens
- Use preview/sample data so screens can be developed before services and persistence are wired
- Keep screen responsibilities clear so navigation and app state can be wired in Step 7
- Keep the implementation scoped to presentation and local view state only

## Deliverables

- A root app view that no longer shows the default Xcode placeholder
- Core SwiftUI screens for:
  - Dashboard or home overview
  - Live run screen
  - Run history list
  - Run detail / summary
  - Settings
- Reusable view components for common metrics and section layouts where duplication would otherwise appear immediately
- SwiftUI previews or equivalent sample configurations for the main screens

## Screen Scope

### 1. Dashboard / Home

- Show the app's primary landing screen
- Surface key summary stats such as recent mileage, latest run, and quick access to start a run
- Use static or sample-derived values in this step

### 2. Live Run

- Show elapsed time, distance, pace, and heart rate placeholders
- Include visible controls for start, pause, resume, and finish states
- Use view-local mock state in this step rather than real tracking services

### 3. Run History

- Show a list of completed runs with enough summary data to scan past activity
- Support empty-state presentation for a fresh install
- Use sample runs from local mock data

### 4. Run Detail

- Show the main completed-run summary surface
- Reserve areas for splits, heart rate summary, elevation, and route map content
- Use placeholders where later platform or persistence integration is still pending

### 5. Settings

- Show the V1 settings surface for distance units, split units, and auto-pause
- Keep settings presentation-only for this step

## Decisions

- Use local mock/sample models in the view layer for Step 6 instead of binding screens to storage or Core Location
- Keep business logic out of the views except for trivial formatting needed to render sample content
- Defer app-wide navigation coordination to Step 7
- Defer service-backed live tracking, persistence, and platform API integration to Steps 8 and 9
- Favor a small reusable view set over premature abstraction

## Exit Criteria

- The app launches into a purposeful Turnover UI instead of `Hello, world!`
- Each core V1 screen exists as a SwiftUI implementation, even if some sections still use placeholders
- The screens are reviewable in previews or equivalent local sample states
- Screen code is separated enough that navigation wiring can happen cleanly in Step 7
- No real tracking, persistence, or platform integration is required yet for the screens to render
