# Android Wear Message API Changes

- The mobile explicit launcher export boundary is limited to .MainActivity and preserves its MAIN/LAUNCHER entry point.
- The handset releases both Google API connection callback registrations before disconnecting during activity teardown.
- The handset ignores queued Google API connection callbacks once its activity is finishing or destroyed.

## 2026-06-14

- Added an exact-commit Wear Message device verification matrix for pairing,
  canonical paths, strict payload handling, replay, launch-failure retry,
  disconnects, relaunch, and privacy-safe evidence, with every runtime row explicitly unexecuted.
- Disabled PNG crunching and AGP 1.1.0's unstable queued implementation in
  both modules while retaining AAPT resource packaging, lint, tests, and
  assembly.
- Isolated documented Wear activity launch failures from listener message
  handling.
- Released the matching replay reservation after a contained Wear activity
  launch failure so valid redelivery can retry.
- Incoming Wear activity launches are limited per source node with a bounded monotonic in-process cooldown.
- Restricted Wear transport dispatch to exact canonical paths and added
  portable cross-module path tests.

## 2026-06-13

- Wear listener rejects semantically blank payloads before replay recording or activity launch.
- Coupled Wear payload validation and delivered text through a single-pass
  strict payload decode over one captured byte array.
- Rejected malformed strict UTF-8 Wear payloads before replay-state mutation
  and private activity delivery.
- Added a bounded in-process listener replay cache keyed by source node and
  request ID.
- Rejected missing source-node IDs and duplicate recognized events before watch
  activity launch.

## 2026-06-12

- Regenerated the direct Gradle wrapper with official Gradle 8.14.5 tooling,
  retained the Gradle 2.2.1 runtime, and pinned its official distribution
  checksum without replacing the existing verified Make launcher.
- Made the Wear listener service export policy explicit and constrained its
  manifest filter to the required Google Play services listener action.
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
- Installed Android packages under the runner JDK and upgraded setup-java to
  its Node 24 release ahead of GitHub's June 2026 runtime migration.
- Added a checksum-verifying Gradle launcher and rejected alternate manifests,
  packaged binaries, symlinks, hidden Gradle inputs, and `buildSrc`.
- Split the exported launcher from the private message activity so external
  intents cannot inject unbounded or spoofed message extras.
- Bounded connected-node lookup and per-node message delivery waits so stalled
  Wear transport operations cannot retain sender threads indefinitely.

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
- Added a baseline gate for the historical null-safe path contracts; current
  mobile and Wear dispatch now requires exact canonical identifiers.
- Documented the path-matching maintenance contract in the README and vision.

## 2026-06-08

- Added null text and null payload handling to both mobile and wear
  `WearMessage` contracts, with matching unit coverage in each module.
- Added `make check` as the SDK-free verification wrapper.
- Cleaned the mobile and wear lint gates by removing starter resources, moving wear background ownership into a theme, and adding resource-backed mobile input labels.
- Added narrow lint configurations for the legacy SDK, pinned Play Services, and API-database warnings.
- Documented and enforced the lint, unit test, and debug assemble verification path.
