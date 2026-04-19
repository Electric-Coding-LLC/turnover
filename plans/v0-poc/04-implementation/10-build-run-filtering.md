# Build Run Filtering

[Back to Execution Map](../EXECMAP.md)

## Goal

Let the user narrow down the run list.

## Tasks

- Date-range filtering
- Tag-based filtering
- How filters are applied and cleared

## Constraints

- Keep filtering attached to the run history flow rather than introducing
  separate filter management screens.
- Support only the date and tag filtering promised for v0.

## Exit Criteria

- Users can narrow the run list by date range and tags and clear those filters
  predictably.
- Filtering works in place without disrupting the main run browsing flow.
