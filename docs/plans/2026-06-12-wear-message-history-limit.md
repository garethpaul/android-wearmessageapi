# Wear Message History Limit

## Status: Completed

## Context

The mobile and Wear activities keep every confirmed or accepted message in an
in-memory `ArrayAdapter`. A long-running activity can therefore grow its
visible history without a bound even though individual payloads are limited.

## Goal

Keep the newest 100 messages in each activity while preserving the existing
send confirmation, payload validation, and service-delivery behavior.

## Changes

- Add a shared `MAX_HISTORY_ENTRIES` policy to both module-local
  `WearMessage` helpers.
- Add a pure helper that reports when the oldest entry must be removed before
  appending another message.
- Evict old entries before confirmed mobile sends and validated Wear messages
  are appended.
- Add JVM boundary tests in both modules and enforce the contract in the
  repository checker.
- Document the bounded history behavior in the maintenance notes.

## Verification

- Passed focused mobile and Wear JVM tests with
  `ANDROID_HOME=/home/gjones/android-sdk ANDROID_SDK_ROOT=/home/gjones/android-sdk make test`.
- Passed full lint, unit-test, and debug-build verification with
  `ANDROID_HOME=/home/gjones/android-sdk ANDROID_SDK_ROOT=/home/gjones/android-sdk make check`.
- Passed the same full `make check` gate from an external working directory.
- Confirmed seven hostile mutations are rejected for limit drift, predicate
  weakening, activity bypass, missing tests, documentation drift, incomplete
  plan status, and missing plan verification.
- Passed `git diff --check`.

## Boundaries

- Do not change payload size limits, message paths, send timeouts, or
  cold-start delivery.
- Do not add persistence, replay detection, sender identity validation, or
  transport rate limiting in this unit.
- Do not record failed mobile sends or invalid Wear payloads in history.
