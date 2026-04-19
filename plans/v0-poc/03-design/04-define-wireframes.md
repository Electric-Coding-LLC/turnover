# Define the Wireframes

[Back to Execution Map](../EXECMAP.md)

## Goal

Capture low-fidelity screen wireframes in a form that is stable, reviewable,
and implementation-friendly.

## Tasks

These are text-based wireframes for the v0 app.

They define layout, hierarchy, and navigation without trying to lock visual
styling yet.

Each screen section should capture:

- `Layout`
  The major blocks and their order on the screen
- `Hierarchy`
  What should read as primary, secondary, and tertiary
- `Interaction`
  What is tappable and what each action does
- `Design Intent`
  How the screen should feel without locking high-fidelity styling

## Constraints

### Navigation Rules

- Primary app navigation uses a two-tab bottom bar:
  - `Summary`
  - `Runs`
- `Summary` is the default tab.
- `Run Detail` is pushed from either `Summary` or `Runs`.
- Distance units should behave like a small app-level preference, not a primary
  screen control.
- Top-bar chrome should stay minimal:
  - `Summary`: no top title by default
  - `Runs`: no top title by default
  - `Run Detail`: back only, or back plus small title if needed
- Do not use a hamburger menu.
- Do not include a dedicated visible `Refresh` button in the wireframes.
- Treat refresh as automatic app behavior for v0 unless implementation or
  testing proves a manual control is needed.
- If a visible unit toggle exists in the wireframes, place it as a small utility
  control near the bottom navigation rather than as a prominent top-row module.

## Summary

Purpose:

- quick progress review
- view totals
- scan PRs
- jump into a run when needed

Layout:

- totals block first
- PR list second
- small unit utility near the bottom nav
- bottom tabs last

Hierarchy:

- primary:
  - current week, current month, year-to-date totals
- secondary:
  - personal records list
- tertiary:
  - unit toggle
  - bottom navigation

Interaction:

- PR row tap opens `Run Detail` for the associated run
- `Runs` tab opens the full runs list
- `mi | km` changes the app-wide display unit

Design Intent:

- fast to scan in one pass
- dense, practical, and calm
- no extra chrome competing with the totals
- records should feel like useful reference data, not decorative cards

```text
+------------------------------------------------------------+
|   Current Week       Current Month        Year to Date     |
|     12.5 mi            48.2 mi              342.1 mi       |
+------------------------------------------------------------+
| Personal Records                                           |
| 400m         1:05      4:21/mi      Jun 12, 2023        >  |
| 800m         2:25      4:52/mi      Jul 05, 2023        >  |
| 1 Mile       5:15      5:15/mi      Aug 20, 2023        >  |
| 5K          18:45      6:02/mi      Sep 15, 2023        >  |
| 10K         39:20      6:20/mi      Oct 10, 2023        >  |
| Half      1:28:40      6:46/mi      Nov 12, 2023        >  |
| Marathon  3:10:15      7:15/mi      Dec 03, 2023        >  |
+------------------------------------------------------------+
|                                                  [mi | km] |
+------------------------------------------------------------+
|      [Summary (active)]                  [Runs]            |
+------------------------------------------------------------+
```

Notes:

- The totals block is the top focal point.
- The PR list should be dense and scannable, not a stack of oversized cards.
- The unit toggle should read as a small global preference, not a primary
  control.
- Place the unit toggle near the bottom navigation rather than at the top of
  the screen.
- The bottom `Runs` tab is the path to the full runs list, so `Summary` does
  not need a separate `View All Runs` row.
- `Summary` does not need a visible page title if the bottom tab already makes
  the active section clear.
- `Summary` does not need a visible manual refresh control in the wireframe.

## Runs

Purpose:

- browse imported runs
- filter by date range and tags
- open one run for more detail

Layout:

- compact filter system first
- reverse-chronological run list second
- small unit utility near the bottom nav
- bottom tabs last

Hierarchy:

- primary:
  - run rows
  - date, distance, duration, pace
- secondary:
  - filter controls
  - run name
  - tags
- tertiary:
  - unit toggle
  - clear filter action when present

Interaction:

- run row tap opens `Run Detail`
- filter controls narrow the current list in place
- `Clear` removes active filters
- `mi | km` changes the app-wide display unit

Design Intent:

- feel like a work surface, not a dashboard
- easy to scan vertically with low friction
- filters should feel compact and utilitarian
- rows should feel information-dense, not padded

```text
+------------------------------------------------------------+
| Date Range: Last 30 Days                         [Clear]   |
| Tags: Morning, Trail                                       |
+------------------------------------------------------------+
| Nov 12, 2023                                               |
| Morning Long Run                                           |
| 13.1 mi            1:28:40            6:46/mi         >    |
| #LongRun  #Road                                            |
+------------------------------------------------------------+
| Nov 10, 2023                                               |
| 5.2 mi             42:15              8:07/mi         >    |
| #Easy                                                      |
+------------------------------------------------------------+
| Nov 08, 2023                                               |
| Track Session                                              |
| 6.0 mi             47:10              7:52/mi         >    |
| #Intervals  #Track                                         |
+------------------------------------------------------------+
| Nov 05, 2023                                               |
| 10.0 mi            1:14:30            7:27/mi         >    |
| #Trail                                                     |
+------------------------------------------------------------+
|                                                  [mi | km] |
+------------------------------------------------------------+
|          [Summary]                  [Runs (active)]        |
+------------------------------------------------------------+
```

Notes:

- Filters should read as one compact filter system, not separate floating
  controls.
- The unit toggle should be available on `Runs` because distance and pace are
  shown here too.
- The unit toggle should stay visually secondary to filtering and run rows.
- The row priority is:
  - date
  - distance
  - duration
  - pace
- Name and tags are secondary metadata.
- Tappable affordance should stay subtle.

## Run Detail

Purpose:

- read one run clearly
- edit app-owned metadata without leaving context

Layout:

- back affordance first
- run facts block second
- metadata editing block third
- saved feedback near the metadata block
- bottom tabs last

Hierarchy:

- primary:
  - date
  - distance
  - duration
  - pace
- secondary:
  - name
  - tags
  - edit affordances
- tertiary:
  - saved feedback
  - bottom tabs

Interaction:

- back returns to the screen that launched this detail view
- `Edit` on name updates custom run name
- `Edit` on tags adds or removes tags
- bottom tabs remain visible but should not visually compete with the detail
  content

Design Intent:

- focused and quiet
- one run at a time, with no dashboard feel
- metadata editing should feel lightweight and subordinate to the run facts
- no extra analytics, maps, or decoration

```text
+------------------------------------------------------------+
| < Back                                                     |
+------------------------------------------------------------+
| Nov 12, 2023                                               |
+------------------------------------------------------------+
| Distance             Duration              Pace            |
| 13.1 mi              1:28:40               6:46/mi         |
+------------------------------------------------------------+
| Name                                                       |
| Morning Long Run                                 [Edit]    |
+------------------------------------------------------------+
| Tags                                                       |
| #LongRun   #Road                                 [Edit]    |
+------------------------------------------------------------+
| Saved                                                      |
+------------------------------------------------------------+
|          [Summary]                        [Runs]           |
+------------------------------------------------------------+
```

Notes:

- Run facts come first.
- Metadata editing is secondary and compact.
- The saved state should be small and inline.
- `Run Detail` follows the current app unit setting and does not need its own
  dedicated unit toggle.
- Do not add maps, charts, or extra analytics in v0.

## State Overlays

These are not separate screens. They layer onto the wireframes above.

### Permission Needed

Use on `Summary` when HealthKit access has not been granted yet.

```text
[Permission needed to import eligible outdoor runs]
[Grant Access]
```

### Initial Loading

Use on `Summary` or `Runs` when the app has no usable imported data yet.

```text
[Importing runs...]
```

### Refreshing Existing Data

Use lightweight inline progress while keeping existing content visible.

```text
[Refreshing...]
```

### Empty Runs

Use on `Runs` when no eligible runs exist.

```text
[No runs imported yet]
```

### Empty Filter Result

Use on `Runs` when filters exclude all rows.

```text
[No runs match these filters]
[Clear Filters]
```

### Save Failure

Use on `Run Detail` if name or tag editing fails.

```text
[Could not save changes]
[Retry]
```

## Exit Criteria

- The main v0 screens have reviewable text wireframes that capture layout,
  hierarchy, interaction, and design intent.
- The wireframes reinforce the agreed navigation rules and keep chrome,
  refresh, and unit controls lightweight.
