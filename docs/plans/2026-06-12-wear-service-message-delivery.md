# Wear Service Message Delivery

## Status: Completed

## Context

The handset enabled user sends immediately after its data-layer connection and
sent `/start_activity` on a separate thread. A first `/message` could therefore
arrive before the Wear activity registered its listener and be silently lost.

## Changes

- Made `WearMessageListenerService` handle both `/start_activity` and
  `/message` paths.
- Routed accepted payloads into one activity instance through a private intent
  extra and `CLEAR_TOP | SINGLE_TOP` launch flags.
- Split the public launcher from the private message activity so external
  applications cannot inject message extras into the UI.
- Removed the activity's data-layer listener registration and lifecycle race.
- Limited normalized outgoing text and incoming payloads to 4096 UTF-8 bytes.
- Added mobile and wear helper tests for exact UTF-8 byte boundaries plus
  valid, empty, null, and oversized payloads.

## Verification

- `make check`
- `git diff --check`

## Follow-Up

- Verify cold-start delivery on a paired handset and Wear device or emulator.
- Add Android activity/service integration tests after modernizing the legacy
  Gradle and Android SDK baseline.
