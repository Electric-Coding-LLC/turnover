# Turnover - Step 10: Test On Simulator And Device

## Goal

Validate the Step 9 app on both simulator and physical device so core run flows, persistence, permissions, and platform-backed behavior are confirmed before bug-fixing and optimization begin in Step 11.

## Tasks

- Run the shared automated test schemes on the standard simulator target
- Execute a focused manual regression pass on simulator for core navigation and persistence flows
- Execute a focused manual validation pass on at least one physical iPhone for real permissions and live tracking behavior
- Record failures, inconsistencies, and environment-specific gaps with enough detail to drive Step 11 fixes
- Keep this step centered on validation and issue capture rather than broad implementation changes

## Deliverables

- A documented Step 10 plan for simulator and device validation
- Automated verification coverage using:
  - `./scripts/verify-default.sh`
  - `xcodebuild test -scheme Turnover-UI -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4'`
  - `./scripts/verify-simulator-full.sh`
- A manual simulator test checklist covering:
  - App launch and initial state
  - Tab navigation and run-detail presentation
  - Settings changes and persistence across relaunch
  - Run start, pause, resume, finish, and post-run history refresh
- A manual device test checklist covering:
  - Location permission request, denial, approval, and settings recovery flow
  - Real GPS-backed run tracking behavior
  - Background or lock-screen interruption handling within the currently enabled app capabilities
  - Persistence of settings and completed runs across relaunch on device
- A Step 11 bug/input list with reproduction notes, expected behavior, observed behavior, and environment

## Scope

### 1. Automated Simulator Verification

- Run the unit suite as the default regression pass for app-state, persistence, and domain logic
- Run the UI suite for navigation and high-value end-to-end flows because Step 9 changed persistence and platform integration boundaries
- Treat test failures as Step 10 findings to document unless the fix is trivial and required to continue validation
- Keep simulator automation on the shared iPhone 17 / iOS 26.4 destination so runs stay consistent with repo guidance
- Execute the simulator automation serially via `./scripts/verify-simulator-full.sh` to avoid test-bundle collisions

### 2. Manual Simulator Validation

- Verify clean launch, tab switching, history rendering, and settings interaction on a fresh simulator state
- Confirm persisted settings and completed-run history survive terminate-and-relaunch behavior
- Exercise the run lifecycle using simulator-safe inputs to confirm the app shell remains coherent after Step 9 integration
- Check empty-state or first-launch behavior if seeded or persisted data is cleared before launch
- Use simulator checks to validate repeatable UI behavior, not to sign off on real-world GPS fidelity

### 3. Manual Device Validation

- Install and run the app on a physical iPhone with supported iOS
- Validate real location authorization behavior from first launch through denied and later-approved states
- Verify a real run can start, pause, resume, and finish while location updates arrive from the device
- Confirm app behavior during common interruptions such as backgrounding, screen lock, or brief app switching, limited to the capabilities already enabled in earlier steps
- Verify completed runs and settings remain durable after app termination and relaunch on device
- Treat heart rate as optional: unavailable or unsupported behavior is acceptable if the app reports that state honestly

### 4. Findings And Triage

- Record every issue with its environment:
  - Simulator only
  - Device only
  - Both environments
- Capture reproduction steps, observed result, expected result, and severity
- Separate shipping blockers from polish or optimization work
- Hand performance tuning, bug fixes, and reliability hardening to Step 11 instead of expanding Step 10 into implementation work

## Decisions

- Treat Step 10 as a validation gate, not a broad fix-it step
- Use simulator runs for repeatable automation and device runs for real permission and GPS behavior
- Re-run both shared schemes during this step instead of relying on ad hoc spot checks alone
- Keep the manual checklist short and centered on the flows most affected by Steps 8 and 9
- Accept honest unsupported-state handling for optional heart rate behavior rather than forcing hardware-specific coverage

## Assumptions

- Step 9 has already introduced local persistence and platform-backed tracking adapters that are ready for validation
- At least one physical iPhone is available for manual testing
- The simulator remains the standard environment for automated test execution in this repo
- Any issues found in Step 10 can be queued into Step 11 unless they fully block basic validation

## Exit Criteria

- The Step 10 validation scope and non-goals are documented clearly
- Both shared simulator test commands are identified as the baseline automated pass for this step
- The manual simulator checklist covers the core flows affected by persistence and state integration
- The manual device checklist covers real permissions, live tracking, interruptions, and relaunch durability
- Findings are captured with enough detail to drive Step 11 fixes without repeating discovery work
- The plan leaves optimization, bug-fixing implementation, and release preparation for later steps without ambiguity

## Outcome

- `Turnover-Unit` passed on `platform=iOS Simulator,name=iPhone 17,OS=26.4` when executed serially
- `Turnover-UI` passed on `platform=iOS Simulator,name=iPhone 17,OS=26.4`
- Simulator coverage now confirms:
  - App launch reaches the main run entry flow
  - Settings changes persist across relaunch
  - Current unit coverage still passes for app state, persistence, metrics, and platform-status handling
- Added `./scripts/verify-default.sh` for the routine unit-only verification path
- Added `./scripts/verify-simulator-full.sh` so the standard Step 10 simulator pass runs the shared schemes serially
- An attempted parallel execution of both `xcodebuild test` commands produced a simulator bundle-load failure for `Turnover-Unit`; treat the Step 10 automation path as serial unless separate derived data or isolated destinations are introduced
- No app-level simulator regression was reproduced after rerunning the unit suite in isolation
- Physical-device validation remains pending from this environment, so Step 10 should not be marked fully complete until a real iPhone pass covers permissions, live GPS behavior, interruption handling, and relaunch durability on device
