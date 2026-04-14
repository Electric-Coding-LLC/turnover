# Turnover

Personal iOS run tracker focused on stats and analytics.

Turnover is a personal iOS run tracker built as a Strava replacement for someone who wants the data without the feed.

## V1 Features

- Start/stop/pause runs with live GPS tracking
- Live metrics: pace, distance, time, heart rate
- Pace splits per mile/km
- Weekly/monthly mileage totals
- Heart rate zone breakdown
- Elevation gain
- Personal records (fastest 400m, 800m, mile, 5K, 10K, half, marathon)
- Run history with route map

## Non-Goals (V1)

- No social features
- No backend/cloud sync
- No watchOS app
- No training plans or coaching
- No third-party integrations

## Testing

Use the shared Xcode schemes to keep normal verification scoped to the code that changed.

- Default verification: `./scripts/verify-default.sh`
- UI flow verification: `xcodebuild test -scheme Turnover-UI -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4'`
- Broad pre-merge pass: run both schemes instead of relying on the umbrella `Turnover` scheme
- Full simulator pass: `./scripts/verify-simulator-full.sh`

Strategy:

- Use `Turnover-Unit` for persistence, app-state, metrics, and domain logic changes
- Use `Turnover-UI` only when changing navigation, screen behavior, or critical user flows
- Avoid the default `Turnover` scheme as the routine path because it drags UI tests into every run
- Run the full simulator pass serially; avoid launching both `xcodebuild test` commands in parallel against the same simulator destination
