---
title: Wear Message Send Result Baseline
type: reliability
status: completed
date: 2026-06-09
---

# Wear Message Send Result Baseline

## Problem Frame

The mobile app cleared the typed message after iterating connected Wear nodes
without checking whether any send succeeded. If no paired node was connected, or
all sends failed, the user could lose unsent text.

## Scope Boundaries

- Preserve the existing `/message` path, UTF-8 payload contract, and background
  send thread.
- Do not add retries, queues, notifications, or new dependencies in this pass.
- Do not change wear-side receive behavior.

## Implementation Units

### U1: Check Send Results

Files:

- Modify `mobile/src/main/java/garethpaul/com/wearer/MainActivity.java`

Approach:

- Capture `MessageApi.SendMessageResult` for each connected node.
- Treat the send as successful when at least one result status is successful.
- Clear the input only after a successful send.

### U2: Guard The Result Contract

Files:

- Modify `scripts/check-baseline.sh`

Approach:

- Fail the baseline if mobile sends stop inspecting `SendMessageResult`.
- Fail the baseline if input clearing is no longer behind a successful-send
  guard.

### U3: Document The User Data Behavior

Files:

- Modify `README.md`
- Modify `VISION.md`
- Modify `CHANGES.md`

Approach:

- Record that typed messages are preserved when no paired Wear node accepts the
  message.
- Keep the no-silent-discard behavior visible for future wearable send changes.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `./gradlew lint test assembleDebug --no-daemon`
- `git diff --check`
