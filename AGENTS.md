# Repo Instructions

- Install: no install step yet
- Lint: no lint step yet
- Typecheck: no typecheck step yet
- Test: `xcodebuild test -scheme Turnover-Unit -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4'`
- Verify: run the Test command by default; for UI flow changes also run `xcodebuild test -scheme Turnover-UI -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4'`
- Sensitive paths: none currently; reevaluate after adding app code or secrets
- Keep files to around 500 lines of code when possible

Workflow: inspect, short plan, assumptions, smallest viable change, verify, summarize.
