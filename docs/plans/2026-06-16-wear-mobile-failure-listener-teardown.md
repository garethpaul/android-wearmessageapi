# Wear Mobile Failure Listener Teardown

Status: Planned

## Problem

The handset activity registers itself with `GoogleApiClient` as both connection
callbacks and a connection-failure listener. `onDestroy` unregisters only the
connection callbacks before disconnecting, leaving the destroyed activity
registered for a late connection-failure callback during teardown.

## Priorities

1. Symmetrically release every activity-owned Google API callback registration.
2. Unregister both listener types before disconnecting the client.
3. Preserve message paths, payload validation, send state, timeouts, and Wear
   listener behavior.
4. Add mutation-sensitive lifecycle and documentation contracts.

## Requirements

- Call `unregisterConnectionFailedListener(this)` exactly once from
  `onDestroy` when the client exists.
- Keep failure-listener removal adjacent to connection-callback removal and
  before the connected-or-connecting disconnect branch.
- Preserve the existing destroy-time connection-state reset and final
  `super.onDestroy()` ordering.
- Record the lifecycle ownership rule in maintained guidance and this plan.
- Keep repository-root and external-directory verification equivalent.

## Implementation Units

### 1. Release the failure listener

**File:** `mobile/src/main/java/garethpaul/com/wearer/MainActivity.java`

Unregister the activity's failure listener immediately after its connection
callbacks and before disconnecting the client.

### 2. Enforce symmetric teardown

**File:** `scripts/check-baseline.sh`

Require one registration and one unregistration for each callback interface,
bind both unregistrations to the destroy block, and enforce their ordering
before disconnect and `super.onDestroy()`.

### 3. Synchronize guidance

**Files:** `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`,
and this plan.

Document that the handset releases both Google API callback registrations at
activity teardown.

## Verification

- Run POSIX shell syntax and the focused baseline checker.
- Run repository-root and external-directory `make check` with Java 8 and the
  configured Android SDK.
- Reject isolated missing-unregistration, duplicate-unregistration,
  after-disconnect ordering, guidance-removal, and reopened-plan mutations.
- Audit exact paths, generated artifacts, conflict markers, file modes,
  dependency/workflow drift, whitespace, and credential-shaped additions.

## Risks

- The API is legacy, so the checker must preserve the existing registration and
  disconnect structure rather than broadening this change into modernization.
- This PR is stacked on PR #12 and must retain base-first merge ordering.

## Out Of Scope

- Google Play Services, Gradle, Android plugin, SDK, or dependency upgrades.
- Message transport, node selection, paths, payload handling, replay, activity
  launch, user-visible text, and paired-device behavior.
- Emulator, physical-device, live disconnect, and late-callback injection.
