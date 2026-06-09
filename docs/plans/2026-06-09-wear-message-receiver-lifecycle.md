# Wear Message Receiver Lifecycle Guard

Status: Completed
Date: 2026-06-09

## Goal

Keep the wear activity receiver resilient when wearable callbacks arrive with
unexpected paths, null events, or while the list adapter is not ready for UI
updates.

## Changes

- Ignored null message events and non-`/message` paths before posting UI work.
- Decoded accepted message payloads before dispatching to the UI thread.
- Isolated list adapter updates behind a helper that safely returns when the
  adapter is unavailable.
- Extended the SDK-free baseline check to enforce the receiver lifecycle guard.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `./gradlew test --no-daemon`
- `git diff --check`
