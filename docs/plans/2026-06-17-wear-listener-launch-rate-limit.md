---
title: Wear Listener Launch Rate Limit
type: security
status: planned
date: 2026-06-17
owner: repository maintainers
---

# Wear Listener Launch Rate Limit

## Context

The Wear listener validates canonical paths, strict bounded payloads, and
source/request replay identity before launching the activity. Exact replay
suppression does not constrain a connected source that emits fresh request IDs
rapidly, so one admitted node can repeatedly relaunch the UI and consume
listener resources. This is a denial-of-service boundary even though the Wear
data layer authenticates messages to the application identity.

## Requirements

- R1. Permit at most one accepted activity delivery per source node within a
  fixed monotonic-time interval.
- R2. Keep different source nodes independent.
- R3. Reject missing sources, negative timestamps, and backward timestamps
  without advancing the accepted-delivery window.
- R4. Do not advance the window when an event is rejected for arriving too
  soon.
- R5. Bound remembered source nodes and evict the oldest source at capacity.
- R6. If activity launch fails, release only the matching source/timestamp
  reservation together with the existing replay identity.
- R7. Apply the limiter after canonical path, payload, and replay validation
  but before `startActivity`.
- R8. Add portable Java tests, static contracts, maintained guidance, and a
  completed verification record without weakening existing checks.

## Key Technical Decisions

- KTD1. Use `SystemClock.elapsedRealtime()` so wall-clock and timezone changes
  cannot bypass or extend the window.
- KTD2. Keep the limiter Android-free and package-private so boundary behavior
  runs under the existing host JDK and Gradle unit tests.
- KTD3. Preserve denied message identities in the replay cache. A rate-limited
  request is consumed, not eligible for later replay.
- KTD4. Rollback requires the exact accepted timestamp so a stale failure
  cannot remove a newer source reservation.

## Implementation Units

### U1: Bounded Per-Source Limiter

**File:** `wear/src/main/java/garethpaul/com/wearer/MessageDeliveryRateLimiter.java`

Implement synchronized monotonic admission, exact rollback, and oldest-source
eviction with constructor-injected limits for deterministic tests.

### U2: Listener Integration

**File:** `wear/src/main/java/garethpaul/com/wearer/WearMessageListenerService.java`

Reserve a source delivery after replay validation and before launch. Release
both reservations only for documented launch failure.

### U3: Portable Tests And Contracts

**Files:** `scripts/test-wear-delivery-rate-limiter.sh`,
`scripts/MessageDeliveryRateLimiterHostTest.java`, `wear/src/test/...`,
`Makefile`, and `scripts/check-baseline.sh`.

Cover first delivery, cooldown boundary, rapid denial, per-source isolation,
negative/backward time, exact rollback, stale rollback, and bounded eviction.

### U4: Guidance

**Files:** `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`,
and this plan.

Document the in-process denial-of-service boundary and its device-dependent
residual risk.

## Test Scenarios

- The first event for a valid source is accepted.
- A second event before the interval is rejected without moving the boundary.
- An event exactly at the interval is accepted.
- Another source remains independently eligible.
- Negative and backward timestamps fail closed without corrupting state.
- Exact launch-failure rollback permits retry; stale rollback does not clear a
  newer reservation.
- Adding more than the configured source count evicts only the oldest source.
- Existing replay, strict UTF-8, canonical path, single-consumption,
  connection-liveness, and launch-failure tests remain green.

## Scope Boundaries

- Do not add persistent identity state, cross-device authorization, a network
  dependency, a background queue, or a modern Wear API migration.
- Do not alter payload content, canonical paths, activity flags, message send
  behavior, or the existing replay cache.
- In-process state resets after service process death; durable abuse controls
  require a separate privacy and lifecycle design.
- Do not claim paired-device or live transport evidence from host tests.
- Do not merge or close stacked pull requests without owner authorization.

## Verification

- Add the host rate-limiter matrix first and confirm it cannot compile before
  the implementation exists.
- Run focused host tests, shell syntax, repository and external-directory
  SDK-backed `make check` with explicit timeouts.
- Reject isolated mutations for interval enforcement, per-source isolation,
  rollback identity, eviction, listener ordering, guidance, status, and
  verification evidence.
- Audit exact diff, generated artifacts, dependencies, credentials, conflict
  markers, file modes, and whitespace before commit.

## References

- Android monotonic clock guidance:
  https://developer.android.com/reference/android/os/SystemClock
- Wear OS data-layer security guidance:
  https://developer.android.com/training/wearables/data/data-layer
