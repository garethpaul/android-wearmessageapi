# Document Wear Pairing Prerequisites

status: pending_hosted_verification

## Context

The roadmap still listed dynamic dependency pinning, message behavior tests,
and pairing documentation as future work even though the repository already
pins play-services-wearable 7.0.0 in both modules and enforces extensive
portable message contracts. The remaining documentation gap was the concrete
setup needed before the exact-commit device matrix can produce truthful runtime
evidence.

## Requirements

- Document that mobile and Wear builds come from the same exact commit and use
  the shared `garethpaul.com.wearer` application ID.
- Require a matching signing certificate for the mobile and Wear packages;
  package-name equality alone does not satisfy the private Data Layer boundary.
- Record the `wearApp project(':wear')` packaging relationship without assuming
  one modern companion installation mechanism.
- Require a platform-supported paired handset/Wear or emulator flow with a live
  Google Play services Data Layer connection.
- Distinguish successful installation from a connected `GoogleApiClient` and an
  accepted send to at least one paired node.
- Preserve synthetic payloads, privacy-safe evidence, and explicit unexecuted
  runtime rows.
- Remove completed roadmap items and retain the dedicated modernization and
  exact-commit paired-device work.

## Test-Driven Implementation

The source baseline was changed first to require the paired-device heading and
source-backed identity, connection, and synthetic payload evidence. The
unchanged README then failed on the missing heading before documentation was
added.

## Validation

- Run `scripts/check-baseline.sh` and the complete `make check` gate.
- Run the same Make gate from an external working directory.
- Reject isolated documentation mutations covering the README prerequisites,
  device matrix, roadmap cleanup, change history, plan status, and non-claim.
- Audit the diff for application, manifest, workflow, Gradle, binary, and
  credential drift.

## Scope Boundaries

- Do not change Gradle, SDK, manifest, application, transport, replay, launch,
  or UI behavior.
- Do not claim a currently supported modern Wear OS pairing path for this
  legacy API 21 and Play Services 7.0.0 sample.
- Do not mark any device matrix row as passed without exact-commit evidence.

## Verification Results

Repository-root and external-directory `make check` passed the source baseline,
mixed-path cooldown contract, five mixed-path source mutations, two eight-case
canonical path runs, eight rate-limiter cases, thirteen delivery-gate cases,
and nine existing delivery-gate hostile mutations.

All eleven isolated documentation mutations were rejected for the intended
reason across README identity, commit, connection, and synthetic-payload
prerequisites; device-matrix setup; stale roadmap items; change history; plan
status; and the runtime non-claim.
Three additional review mutations rejected removal of the signing-certificate
requirement from the README, device matrix, and plan.

No Android SDK was configured locally, so Gradle lint, unit tests, and assembly
were explicitly skipped. No handset, Wear device, emulator pair, or live Data Layer connection was used.

Initial implementation commit `3df5daaa8f180b06b7d55bc331c0477f795638f1`
passed hosted Check and CodeQL. Review then added the required
matching-signature prerequisite. Exact-head hosted checks remain pending.

## Sources

- Android Developers, Data Layer overview (matching package name and signature):
  https://developer.android.com/training/wearables/data/overview
- Android Developers, connecting a watch and phone:
  https://developer.android.com/training/wearables/get-started/connect-phone
