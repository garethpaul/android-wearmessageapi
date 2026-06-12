# Wear Mobile Send Timeouts

Status: Completed

## Context

The mobile sender performs connected-node lookup and per-node message delivery
with unbounded `PendingResult.await()` calls. A stalled Google Play Services or
Wear transport operation can retain the worker thread and activity indefinitely,
including after the activity is destroyed.

## Changes

- Add one explicit timeout for wearable node lookup and message sends.
- Use timed `await` calls for both blocking operations.
- Preserve existing null, node, status, and user-result handling on timeout.
- Extend the SDK-free baseline and README with the bounded-send contract.

## Verification

- `make check`
- Android lint, debug/release JVM tests, and debug assembly for both modules
- Focused mutations covering unbounded, duplicated, reordered, and altered waits
- `git diff --check`

The Android SDK-backed gates pass on this host. A paired Wear runtime remains
unavailable, so live transport timeout behavior still requires device or
emulator verification.
