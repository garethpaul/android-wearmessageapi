# Android Wear Message API Changes

## 2026-06-26 10:15 - P2 - Reject failed Wear node discovery

### Summary
The handset sender now validates the connected-node result status before
reading or iterating its node list.

### Work completed
- Mobile Wear sends reject missing or unsuccessful connected-node discovery status before node-list access.
- Added the fail-closed discovery status guard without changing paths, payloads,
  deadlines, or per-node send behavior.
- Added a focused source contract and three hostile mutations.
- Added design and implementation plans plus synchronized maintenance guidance.

### Threads
- Started: connected-node discovery audit — traced the send flow and official
  Google Play services result contract.
- Continued: shared sender deadline — preserved its monotonic budget unchanged.
- Stopped: `NodeClient` migration — too broad for the focused legacy API fix.

### Files changed
- `mobile/src/main/java/garethpaul/com/wearer/MainActivity.java` — validates
  discovery status before node-list access.
- `scripts/` and `docs/plans/` — add executable contracts and durable evidence.

### Validation
- Red-first focused contract — failed before implementation, then passed.
- Hostile discovery mutations — all three rejected.
- Repository and external-Makefile `make check`, shell syntax, and diff checks passed.
- Android SDK-backed Gradle lint, tests, and builds skipped locally because no SDK is configured.

### Bugs / findings
- P2: an unsuccessful discovery result could expose a node list that the sender
  treated as valid without checking the operation status.

### Blockers
- Android SDK and paired-device runtime verification remain pending.

### Next action
- Run the full local and hosted exact-head gates, review, and merge the PR.

## 2026-06-26

- Wear node lookup and per-node sends consume one shared five-second deadline,
  replacing the previous fresh five-second wait for every connected node.
- Added a Java 7 portable deadline helper and four deterministic host cases.
- Repository and external-directory `make check`, shell syntax, and diff checks
  passed; isolated source and deadline-helper mutations failed as intended.
- Android SDK, paired handset, and paired-Wear runtime checks remain unverified locally.
- Exact-head Check run `28251310730` passed the SDK-backed gate in 1m15;
  CodeQL run `28251308824` passed Actions and Java/Kotlin analysis.
- Codex review was blocked before analysis by repeated OpenAI API HTTP 401
  failures; immutable exact-head manual review found no actionable findings.

## 2026-06-25

- Added source-backed paired-device prerequisites, exact-commit and matching
  signing-certificate install requirements, connection evidence, and
  privacy-safe manual send/receive steps; removed
  completed dependency-pin, behavior-test, and pairing-doc roadmap items.
- Review caught that matching package names are insufficient without a matching
  signing identity; the pending-state evidence gate also rejected an imprecise
  hosted-check sentence before final local validation.
- Separated delivery cooldown lanes by source node and exact canonical path so
  startup and message events do not throttle each other while replay identity
  remains shared by source and request ID.
- Revalidated mixed-path ordering, rollback, replay, source isolation, bounded
  lane eviction, and hostile mutations with an independent Codex review.

- Made Wear replay and rate-limit admission atomic so throttled requests remain
  retryable after cooldown and stale launch-failure callbacks cannot clear a
  newer reservation.
- Pinned in-flight source/request identities outside the bounded completed
  replay cache, preventing cache eviction from reopening an active delivery.
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
