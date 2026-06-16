# Wear Mobile Callback Liveness

Status: Completed

## Problem

The handset activity unregisters both `GoogleApiClient` callback interfaces
during `onDestroy`, but callbacks already queued on the main thread may still
run after teardown begins. `onConnected` already rejects finishing or destroyed
activity instances, while `onConnectionSuspended` and `onConnectionFailed`
still mutate connection state and update the destroyed activity's send button.

## Priorities

1. Make every activity-owned Google API callback enforce the same liveness
   boundary before mutating activity or view state.
2. Preserve the existing callback registration and symmetric teardown order.
3. Keep message transport, paths, payloads, timeouts, and user-visible behavior
   unchanged for live activities.
4. Add mutation-sensitive static coverage for both previously unguarded
   callback bodies and completed plan evidence.

## Requirements

- `onConnectionSuspended` and `onConnectionFailed` must return immediately when
  the activity is finishing or destroyed.
- The liveness check must precede connection-state mutation and send-button
  updates in each callback.
- `onConnected` must retain its equivalent guard before marking the Wear
  connection ready or launching the remote activity.
- `onDestroy` must continue unregistering both callback interfaces before
  disconnecting the client.
- Repository-root and external-directory validation must remain equivalent.

## Implementation Units

### 1. Guard late connection callbacks

**File:** `mobile/src/main/java/garethpaul/com/wearer/MainActivity.java`

Apply the existing finish/destroy liveness boundary to the suspension and
failure callbacks before they alter activity-owned state.

### 2. Enforce callback-local ordering

**File:** `scripts/check-baseline.sh`

Require one early liveness guard inside each Google API callback, prove the
guard precedes state mutation and UI updates, and reject missing, misplaced, or
duplicated guards.

### 3. Synchronize maintained guidance

**Files:** `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`,
and this plan.

Record that queued connection callbacks cannot update a finishing or destroyed
handset activity.

## Verification

- Run POSIX shell syntax and the focused baseline checker.
- Run repository-root and external-directory `make check` with Java 8 and the
  configured Android SDK.
- Reject isolated missing suspension guard, missing failure guard,
  after-state-mutation guard, duplicate guard, guidance removal, and reopened
  plan status mutations.
- Audit exact paths, generated artifacts, conflict markers, file modes,
  dependency and workflow drift, whitespace, and credential-shaped additions.

## Risks

- Static source contracts cannot inject a platform callback after activity
  destruction, so emulator or device verification remains the runtime proof.
- This change must not infer that unregistering listeners cancels callbacks
  already queued by Google Play services.
- The pull request will be stacked on PR #13 and must retain base-first order.

## Out Of Scope

- Google Play services, Gradle, Android plugin, SDK, or dependency upgrades.
- Message sending, node selection, paths, payload validation, replay handling,
  Wear activity launch behavior, or user-visible text.
- Emulator, physical-device, paired transport, or late-callback injection.

## Completion Evidence

- POSIX shell syntax and the focused baseline checker passed with one liveness
  guard in each Google API callback before connection-state and send-button
  updates.
- Repository-root and external-directory `make check` passed with Java 8 and
  Android API 21 tooling on June 16, 2026, including zero-issue mobile and Wear
  lint, both modules' debug/release JVM suites, two canonical-path host runs,
  and both debug APK assemblies.
- Five isolated hostile mutations were rejected for a missing suspension
  guard, missing failure guard, guard after state mutation, duplicate guard,
  and removed maintained guidance. A reopened plan-status mutation is also
  enforced by the final checker contract.
- Emulator, physical-device, paired transport, and late-callback injection
  remain unexecuted and are not claimed by this plan.
