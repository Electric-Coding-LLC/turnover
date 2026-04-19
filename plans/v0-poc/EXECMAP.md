# Execution Map

## Goal

Ship the `v0-poc` iOS release path for reviewing outdoor running history and
progress from Apple Health workout data.

## Guardrails

- Keep v0 focused on import, summary, history, and lightweight organization.
- Keep Apple Health as the only source of truth for imported run data.
- Keep app-owned metadata limited to run names and tags.
- Do not expand into training plans, social features, route analysis, or
  advanced analytics.
- Do not depend on complex background sync or multi-provider support in v0.

## Execution Map

- [x] [Define v0 scope](01-scope/01-define-v0-scope.md)
- [x] [Define architecture](02-architecture/01-define-architecture.md)
- [x] [Define data model](02-architecture/02-define-data-model.md)
- [x] [Define core screens](03-design/01-define-core-screens.md)
- [x] [Define navigation flow](03-design/02-define-navigation-flow.md)
- [x] [Define main UI states](03-design/03-define-main-ui-states.md)
- [ ] [Define wireframes](03-design/04-define-wireframes.md)
- [ ] [Set up the iOS project](04-implementation/01-set-up-ios-project.md)
- [ ] [Set up the app structure and navigation](04-implementation/02-set-up-app-structure-and-navigation.md)
- [ ] [Connect Apple Health](04-implementation/03-connect-apple-health.md)
- [ ] [Import eligible outdoor runs](04-implementation/04-import-eligible-outdoor-runs.md)
- [ ] [Store imported run data](04-implementation/05-store-imported-run-data.md)
- [ ] [Store app-owned run metadata](04-implementation/06-store-app-owned-run-metadata.md)
- [ ] [Build distance totals](04-implementation/07-build-distance-totals.md)
- [ ] [Build personal records](04-implementation/08-build-personal-records.md)
- [ ] [Build the run history list](04-implementation/09-build-run-history-list.md)
- [ ] [Build run filtering](04-implementation/10-build-run-filtering.md)
- [ ] [Add run naming](04-implementation/11-add-run-naming.md)
- [ ] [Add run tagging](04-implementation/12-add-run-tagging.md)
- [ ] [Test core functionality](05-testing/01-test-core-functionality.md)
- [ ] [Fix bugs and polish the UI](05-testing/02-fix-bugs-and-polish-ui.md)
- [ ] [Create support documentation](06-release/01-create-support-documentation.md)
- [ ] [Prepare the release build](06-release/02-prepare-release-build.md)
- [ ] [Deploy the build](06-release/03-deploy-build.md)
- [ ] [Verify the deployed build](06-release/04-verify-deployed-build.md)

## Done When

- The app can import eligible outdoor runs from Apple Health and present the
  planned summary, records, history, and detail flows.
- The user can manage run names and tags as app-owned metadata without
  broadening the v0 scope.
- Planning status for `v0-poc` lives in this execution map and its linked step
  docs rather than a separate phase tracker.
