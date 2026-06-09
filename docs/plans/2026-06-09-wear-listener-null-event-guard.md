---
title: Wear Listener Null Event Guard
type: reliability
status: completed
date: 2026-06-09
---

# Wear Listener Null Event Guard

## Problem Frame

The wear activity already ignores null message callbacks before decoding or
dispatching to the UI. The wearable listener service still called `getPath()`
on the incoming `MessageEvent` before checking whether the event was present.

## Scope Boundaries

- Preserve the `/start_activity` launch path behavior.
- Keep text message handling and mobile send-result behavior unchanged.
- Do not migrate away from the legacy Wearable listener service API.
- Keep verification available through the SDK-free baseline script.

## Implementation Units

### U1: Guard Listener Events

Files:

- Modify `wear/src/main/java/garethpaul/com/wearer/WearMessageListenerService.java`

Approach:

- Return immediately when `onMessageReceived` receives a null event.
- Keep the existing `WearMessage.isStartActivityPath(...)` path check for
  non-null events.
- Continue delegating non-start paths to the superclass.

### U2: Cover And Document The Contract

Files:

- Modify `scripts/check-baseline.sh`
- Modify `README.md`
- Modify `VISION.md`
- Modify `CHANGES.md`

Approach:

- Add SDK-free checks for the listener-service null guard.
- Document the null-event behavior in project notes.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `make verify`
- `git diff --check`
