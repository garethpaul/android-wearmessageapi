# Android Wear Message API Changes

## 2026-06-09

- Guarded mobile and wear activity startup view binding so required controls are
  validated before wearable API connections are opened.
- Guarded mobile input clearing after successful sends when lifecycle teardown
  makes the input view unavailable.
- Guarded the Wear listener service against null message events before checking
  start-activity paths.
- Added root `make lint`, `make test`, and `make build` gates around the
  existing SDK-free and Gradle verification commands.
- Guarded the wear activity message receiver so null or non-message callbacks
  are ignored before UI dispatch and adapter updates tolerate lifecycle races.
- Preserved mobile message text when no paired Wear node reports a successful
  send result, with an SDK-free baseline guard for the send-success check.
- Added a baseline gate for the null-safe, case-insensitive `/start_activity`
  and `/message` path contracts already covered by the mobile and wear unit
  tests.
- Documented the path-matching maintenance contract in the README and vision.

## 2026-06-08

- Added null text and null payload handling to both mobile and wear
  `WearMessage` contracts, with matching unit coverage in each module.
- Added `make check` as the SDK-free verification wrapper.
- Cleaned the mobile and wear lint gates by removing starter resources, moving wear background ownership into a theme, and adding resource-backed mobile input labels.
- Added narrow lint configurations for the legacy SDK, pinned Play Services, and API-database warnings.
- Documented and enforced the lint, unit test, and debug assemble verification path.
