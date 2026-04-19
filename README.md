# Turnover

Turnover is a simple iOS app for reviewing outdoor running history and progress
using Apple Health workout data.

## Current Status

This repository is in early POC definition. The current execution path and
release requirements live in [`plans/v0-poc/EXECMAP.md`](plans/v0-poc/EXECMAP.md)
and the repo-level plan index lives in [`PLAN.md`](PLAN.md).

## V0 Scope

- Import outdoor run workouts from Apple Health
- Show distance totals for week, month, and year to date
- Show personal records for key distances
- Show a list of past runs
- Support naming and tagging runs

## Out of Scope for V0

- Indoor runs
- Third-party synced runs
- Manually entered runs
- Training plans
- Social features
- Coaching and advanced analytics

## Notes

- Distance totals default to miles
- The app should allow toggling between miles and kilometers
- Week totals start on Monday
