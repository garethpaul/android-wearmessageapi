---
title: Android Wear Message API CI Baseline
type: chore
status: completed
date: 2026-06-10
---

# Android Wear Message API CI Baseline

## Summary

Run the existing mobile/wear message baseline in GitHub Actions so path,
payload, send-result, and lifecycle guards run before review.

## Work Completed

- Added `.github/workflows/check.yml` to run `make check` on pushes, pull
  requests, and manual dispatches.
- Pinned checkout to an immutable revision, limited permissions to repository
  reads, disabled persisted checkout credentials, and bounded the job to fifteen
  minutes.
- Added immutable Java 8 and Android SDK setup actions and installed API 21
  with build-tools 24.0.3.
- Reused the guarded Makefile targets so hosted runners execute the SDK-free
  baseline plus Gradle lint, unit tests, and debug assembly for both modules.
- Removed the maintainer-specific default SDK path; local Gradle checks still
  require explicit SDK configuration.
- Extended `scripts/check-baseline.sh` to require the CI workflow and this
  completed maintenance plan.
- Added focused workflow checks for immutable actions, read-only permissions,
  credential isolation, required Android packages, and the full Make gate.
- Added repository-wide owner coverage, rejected hidden workflows and build
  inputs, and checksum-verified the Gradle distribution used by Make.
- Updated README, VISION, SECURITY, and CHANGES with the CI baseline.

## Verification

- `make check`
- `git diff --check`

## Follow-Up Candidates

- Modernize the legacy Gradle, Android plugin, Google Play Services, SDK, and
  build-tools baseline while retaining SDK-backed CI.
