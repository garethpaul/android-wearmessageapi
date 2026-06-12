# Android Wear Message API Changes

## 2026-06-12

- Routed `/message` events through the Wear listener service so cold-start
  delivery no longer depends on activity listener registration timing.
- Reused a single Wear activity instance for service-delivered messages and
  bounded outgoing and incoming payloads to 4096 UTF-8 bytes.
- Added matching mobile and wear unit coverage for blank, null, valid, and
  oversized message payloads.
- Disabled persisted checkout credentials, added repository-wide ownership,
  and enforced focused immutable-action and read-only workflow contracts.
- Upgraded hosted verification from SDK-free skips to pinned Java 8 and Android
  API 21 lint, unit tests, and debug assembly for both modules.
- Added a checksum-verifying Gradle launcher and rejected alternate manifests,
  packaged binaries, symlinks, hidden Gradle inputs, and `buildSrc`.
- Split the exported launcher from the private message activity so external
  intents cannot inject unbounded or spoofed message extras.

## 2026-06-10

- Serialized mobile sends through an explicit pending state, disabled repeated
  taps, and added generic failure feedback.
- Gated the mobile send control on Wear connection lifecycle state so startup,
  suspension, failure, and completion cannot expose a disconnected sender.
- Moved outgoing history updates behind confirmed node delivery and only clear
  input when it still matches the message that completed, preserving newer
  edits.
- Kept connection-time `/start_activity` control sends outside user-message
  history and failure feedback.
- Added matching mobile/wear unit coverage for input cleanup decisions and made
  root checks portable with hardened Ubuntu 24.04 CI concurrency.
- Added pinned, read-only GitHub Actions that runs `make check` for the
  mobile/wear message baseline with explicit SDK-free execution.
- Extended the SDK-free baseline to require the CI workflow and completed CI
  plan.
- Removed the maintainer-specific Android SDK path from the Makefile.

## 2026-06-09

- Normalized mobile message input so blank or whitespace-only messages are not
  added or sent.
- Guarded mobile Wear message sends when connected-node results, node IDs, send
  results, or statuses are unavailable.
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
