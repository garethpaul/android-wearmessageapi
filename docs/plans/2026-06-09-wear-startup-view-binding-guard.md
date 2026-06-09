---
title: Wear Startup View Binding Guard
type: reliability
status: completed
date: 2026-06-09
---

# Wear Startup View Binding Guard

## Problem Frame

The mobile and wear activities attach adapters and listeners to views that are
required by their checked-in layouts. If a future layout split, wearable shape
resource, or refactor drops one of those IDs, startup would fail with a null
view dereference after the activity has already begun connecting to Wear APIs.

## Scope Boundaries

- Preserve message paths, payload encoding, and send-result behavior.
- Keep the existing mobile and wear layouts unchanged.
- Avoid broad Google Play services or lifecycle rewrites.
- Keep the guard enforceable through the SDK-free baseline script.

## Implementation Units

### U1: Guard Mobile Startup Controls

Files:

- Modify `mobile/src/main/java/garethpaul/com/wearer/MainActivity.java`

Approach:

- Make mobile view initialization report success.
- Validate the list, input, and send button before setting the adapter or
  installing the send listener.
- Finish the activity before opening a Wear API connection when required views
  are unavailable.

### U2: Guard Wear Startup Views

Files:

- Modify `wear/src/main/java/garethpaul/com/wearer/MainActivity.java`

Approach:

- Isolate wear view setup behind a boolean helper.
- Validate the required list view before assigning the adapter.
- Finish the activity before connecting to Wear APIs when the required view is
  unavailable.

### U3: Document And Enforce The Contract

Files:

- Modify `scripts/check-baseline.sh`
- Modify `README.md`
- Modify `VISION.md`
- Modify `CHANGES.md`

Approach:

- Add SDK-free checks for both startup binding guards and this completed plan.
- Document the guard alongside the existing wearable lifecycle notes.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
