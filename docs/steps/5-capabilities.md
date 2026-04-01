# Turnover - Step 5: Set Up Capabilities And Entitlements

## Tasks

- Add the location permission descriptions needed for live run tracking
- Enable Background Modes for location tracking
- Keep unused capabilities disabled for now
- Defer HealthKit entitlements until heart rate integration is implemented

## Sub-Tasks

### 1. Add Location Permission Descriptions

- Add `NSLocationWhenInUseUsageDescription`
- Add `NSLocationAlwaysAndWhenInUseUsageDescription`
- Make both descriptions specific to run tracking, pace, distance, and route capture
- Confirm the strings match the intended foreground and background authorization flow

### 2. Enable Background Modes For Location Tracking

- Enable the `location` background mode on the app target
- Confirm the setting is present in both Debug and Release
- Confirm the capability supports continuing an active run while the app is backgrounded

### 3. Keep Unused Capabilities Disabled

- Confirm Push Notifications is not enabled
- Confirm iCloud is not enabled
- Confirm App Groups is not enabled
- Avoid adding an entitlements file unless a real entitlement requires one

### 4. Defer HealthKit Entitlements

- Do not add a HealthKit entitlement in this step
- Do not add HealthKit usage descriptions in this step
- Revisit HealthKit setup when heart rate collection is implemented
- Document that heart rate remains optional for V1 until that integration exists

## Verification

- The app target declares location usage descriptions
- The app target declares background location mode
- No extra capabilities are enabled yet
- HealthKit setup remains deferred
