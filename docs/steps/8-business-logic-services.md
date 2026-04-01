# Turnover - Step 8: Implement Business Logic And Services

## Goal

Add the app-side logic that turns the Step 7 flow into a real run-tracking system, while still deferring persistence and direct platform API integration to Step 9.

## Tasks

- Define the business rules for starting, pausing, resuming, and finishing a run
- Introduce service boundaries for live tracking, metrics calculation, and run summarization
- Replace placeholder session transitions with a run session model that can carry live values
- Keep service interfaces testable and independent from storage details
- Leave Core Location, HealthKit, and durable storage implementation for Step 9

## Deliverables

- A documented Step 8 plan for business rules, state transitions, and service responsibilities
- A run session domain model that represents:
  - Idle state
  - Active state
  - Paused state
  - Completed summary handoff
- Protocols or equivalent interfaces for:
  - Live tracking input
  - Metrics calculation
  - Run finalization / summary building
- Clear ownership boundaries between:
  - UI-facing app state
  - Business logic services
  - Deferred persistence and platform adapters
- A defined handoff contract for Step 9 storage and platform integration, including:
  - Tracking sample input consumed by Step 8 logic
  - Settings/config input consumed by metrics and split rules
  - Finalized run payloads produced for persistence
  - History/query inputs needed for aggregate and record comparisons
  - Authorization and availability state surfaced from platform adapters

## Scope

### 1. Run Session Domain Logic

- Replace the coarse `RunSessionPhase`-only flow with a session model that can hold evolving run data
- Define the legal transitions between idle, active, paused, and completed
- Decide what happens to elapsed time, moving time, and in-progress metrics while paused
- Ensure the finish action produces a stable completed-run payload for the summary screen

### 2. Metrics And Summary Rules

- Define how distance, pace, elapsed time, moving time, and heart rate are derived in app logic
- Decide which values are calculated continuously during an active run versus only on finish
- Define split generation rules for kilometer or mile-based splits based on app settings
- Define the comparison rules and service inputs for personal records and weekly/monthly aggregates without requiring persistent history in this step
- Limit Step 8 aggregate and record work to rule definition plus temporary in-memory evaluation used to exercise the logic locally

### 3. Service Boundaries

- Introduce interfaces that separate business logic from concrete data sources
- Keep tracking input abstract so Step 9 can plug in Core Location and optional HealthKit without rewriting Step 8 logic
- Keep summary-building logic abstract so completed runs can later be saved locally without view-layer changes
- Define the domain-facing contracts Step 9 adapters must implement for tracking input, settings input, history reads, and finalized run writes
- Avoid binding views directly to raw platform events or persistence concerns

### 4. App State Integration

- Extend the shared app state only enough to drive the real run flow
- Keep presentation formatting out of the domain and service layer
- Treat distance unit, split unit, and auto-pause preferences as business-logic inputs even if their persistence is deferred
- Keep history, analytics, and settings screens able to consume mock or in-memory outputs until Step 9 lands
- Preserve the navigation routes established in Step 7

## Decisions

- Treat Step 8 as domain logic and service orchestration, not platform wiring
- Prefer protocol-backed services so Step 9 can provide concrete adapters cleanly
- Keep sample or in-memory implementations acceptable if they exercise the real business rules
- Define aggregate and record evaluation rules in Step 8, but defer persisted-history execution to Step 9
- Do not implement production history reads, writes, or backfill flows for aggregates and records in this step
- Defer background execution edge cases, permission prompts, and storage migrations to Step 9
- Favor the smallest domain model that can support V1 metrics without forcing a later rewrite

## Assumptions

- Step 7 navigation structure stays intact and should not need another shell-level refactor
- Step 8 may still use fake input streams or seeded data as long as the business rules are real
- Heart rate remains optional for V1 when platform data is unavailable
- Temporary in-memory history may be used to exercise aggregate and record rules before Step 9 persistence exists

## Exit Criteria

- The Step 8 scope and responsibilities are documented clearly
- Run lifecycle rules are explicit enough to implement without guessing
- Service interfaces are defined clearly enough that Step 9 can supply platform-backed implementations
- The UI can consume business-logic outputs without depending on storage or platform APIs directly
- Aggregate and record logic is scoped to rules and temporary in-memory evaluation rather than production persistence work
- The plan leaves storage, permissions, and platform adapter details for Step 9 without ambiguity
