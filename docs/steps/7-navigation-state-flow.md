# Turnover - Step 7: Wire Navigation And State Flow

## Goal

Turn the current screen shells into a coherent app flow by defining root navigation, shared UI state, and the handoff points to upcoming business logic and platform integrations.

## Tasks

- Define the root app navigation structure for V1
- Decide which state stays local to a screen versus shared across the app
- Wire detail presentation and cross-screen actions through a single app flow
- Establish a lightweight app state container for navigation-driving state
- Keep business logic, persistence, and platform service implementation out of this step

## Deliverables

- A documented Step 7 plan for navigation and state ownership
- A defined root flow covering:
  - Tab-based primary navigation
  - Run detail presentation from home and history
  - Entry into live run tracking
  - Completion flow from live run into summary/detail
- A clear state ownership split between:
  - View-local presentation state
  - Shared app/session state
  - Deferred service and persistence state
- A list of the Step 8 and Step 9 dependencies this wiring is expected to support

## Scope

### 1. Root Navigation Structure

- Keep the tab bar as the primary top-level navigation for Home, Run, History, and Settings
- Decide whether each tab owns its own `NavigationStack` or whether a shared root stack is needed
- Ensure run detail can be presented consistently from both Home and History
- Ensure live run can be entered directly from the Home quick action and the Run tab

### 2. Shared App State

- Define the minimum shared state needed before real services exist
- Track active tab selection at the app level if cross-screen actions need to switch tabs
- Reserve a shared active-run/session state model that later steps can populate with real tracking data
- Keep sample and placeholder values acceptable in this step if they unblock navigation flow work

### 3. Local Vs Shared State Ownership

- Keep ephemeral UI concerns local to each screen
- Move only navigation-driving or session-driving state into shared ownership
- Avoid putting formatting or static screen content into a global store
- Keep the state model small enough that Step 8 can add logic without refactoring the whole app shell

### 4. Run Flow Hand-Offs

- Define how the app transitions between idle, active run, paused run, and completed run states
- Define what should happen when the user taps Start Run from Home
- Define what should happen when the user finishes a run from the live run screen
- Make the post-run route explicit so Step 8 can attach real business rules without changing navigation structure

## Decisions

- Treat Step 7 as app-shell wiring, not service implementation
- Preserve the screen set from Step 6 and focus only on how screens connect and share state
- Defer metric calculation, tracking orchestration, storage writes, and platform API calls to later steps
- Prefer the smallest shared state surface that can support the V1 run flow cleanly

## Exit Criteria

- The Step 7 scope and tasks are documented clearly
- The app navigation plan covers top-level tabs, run detail, and the live-run entry/exit flow
- Shared versus local state ownership is clear enough to guide implementation
- The plan leaves business logic and storage concerns for Steps 8 and 9 without ambiguity

## Outcome

- Implemented a shared app state container for tab selection and run session phase
- Moved `NavigationStack` ownership to the app root so each tab manages navigation consistently
- Wired Home and History into shared run-detail presentation
- Wired the live run flow through idle, active, paused, and completed session states
- Added a post-run summary handoff on the Run tab while keeping real tracking and persistence deferred to Steps 8 and 9
