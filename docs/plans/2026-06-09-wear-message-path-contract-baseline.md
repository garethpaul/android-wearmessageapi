# Wear Message Path Contract Baseline

## Status: Completed

## Goal

Keep the mobile and wear message path helpers null-safe and case-insensitive so
startup and text message routing stay compatible across both modules.

## Scope

- Preserve `/start_activity` and `/message` as the explicit message paths.
- Require both path helpers to null-guard inputs before case-insensitive
  matching.
- Require both module test suites to keep path recognition coverage.
- Document the path contract in the README and changelog.

## Out Of Scope

- Changing message path strings or listener routing behavior.
- Migrating from `GoogleApiClient` or legacy Wearable APIs.
- Adding paired-device runtime verification.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew lint --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew test --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon`
- `git diff --check`
