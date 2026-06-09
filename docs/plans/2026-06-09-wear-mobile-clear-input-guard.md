---
title: Wear Mobile Clear Input Guard
type: reliability
status: completed
date: 2026-06-09
---

# Wear Mobile Clear Input Guard

## Problem Frame

The mobile sender clears the text input after at least one paired Wear node
accepts a message. That UI cleanup runs asynchronously on the main thread and
can race with Android lifecycle teardown, where the input view may no longer be
available.

## Scope Boundaries

- Preserve the existing send-success behavior.
- Keep typed text preserved when no paired node accepts the message.
- Do not change message paths, payload encoding, or GoogleApiClient wiring.
- Keep verification available through the SDK-free baseline script.

## Implementation Units

### U1: Guard Mobile Input Cleanup

Files:

- Modify `mobile/src/main/java/garethpaul/com/wearer/MainActivity.java`

Approach:

- Keep input clearing isolated behind `clearMessageInput()`.
- Return early if the input view is unavailable when the UI-thread cleanup runs.

### U2: Cover And Document The Contract

Files:

- Modify `scripts/check-baseline.sh`
- Modify `README.md`
- Modify `VISION.md`
- Modify `CHANGES.md`

Approach:

- Add SDK-free checks that require the input-view guard and this completed
  plan.
- Document the lifecycle-safe cleanup behavior alongside the send-result
  guardrail.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
