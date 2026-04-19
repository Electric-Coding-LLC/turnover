# Connect Apple Health

[Back to Execution Map](../EXECMAP.md)

## Goal

Enable Apple Health as the v0 data source.

## Tasks

- HealthKit permissions
- Access to the required workout data
- Basic handling for denied or unavailable access

## Constraints

- Request only the HealthKit access needed for eligible outdoor runs in v0.
- Keep Apple Health read-only and isolate it behind the planned service
  boundary.

## Exit Criteria

- The app can request permission and access the workout data needed for v0.
- Denied or unavailable HealthKit access is handled cleanly enough for feature
  work to continue.
