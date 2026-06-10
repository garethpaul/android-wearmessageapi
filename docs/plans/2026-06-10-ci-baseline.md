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
  reads, and bounded the job to five minutes.
- Reused the guarded Makefile targets so hosted runners still execute the
  SDK-free baseline when the legacy Android SDK is unavailable.
- Removed the maintainer-specific default SDK path and cleared ambient hosted
  SDK variables so CI cannot accidentally invoke the unsupported Gradle path.
- Extended `scripts/check-baseline.sh` to require the CI workflow and this
  completed maintenance plan.
- Updated README, VISION, SECURITY, and CHANGES with the CI baseline.

## Verification

- `make check`
- `git diff --check`

## Follow-Up Candidates

- Add Android SDK-backed CI after migrating and pinning the legacy Gradle,
  Android plugin, Google Play Services, SDK, and build-tools baseline.
