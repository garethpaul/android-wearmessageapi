# Wear Listener Export Contract

Status: Planned

## Context

CodeQL alert 1 (`java/android/implicitly-exported-component`) identifies
`WearMessageListenerService` in `wear/src/main/AndroidManifest.xml`. Its
`com.google.android.gms.wearable.BIND_LISTENER` intent filter makes the service
exported under the legacy target SDK, but the manifest does not state that
trust-boundary decision explicitly.

The listener must remain bindable by Google Play Services 7.0 for background
Wear data-layer delivery. Marking it private would break cold-start message
delivery, so the compatible remediation is an explicit exported declaration
paired with the single expected listener action.

## Goal

Remove the implicit component exposure while preserving service-owned Wear
message delivery and making future manifest drift fail closed.

## Changes

- Declare `WearMessageListenerService` explicitly exported.
- Require the exported service to retain exactly the expected
  `BIND_LISTENER` action and no additional intent-filter actions.
- Extend the SDK-free manifest contract and security documentation.
- Preserve private `MainActivity`, explicit exported launcher behavior,
  payload bounds, message history limits, and cold-start delivery.

## Verification

- Run SDK-free and SDK-backed `make check`.
- Run the complete gate through an absolute Makefile path.
- Repeat the complete gate from a fresh external clone.
- Reject focused service export, action, checker, documentation, and plan
  mutations.
- Pass exact-head pull-request baseline and CodeQL verification.

## Boundaries

- Do not make the listener private while this sample uses the legacy
  `WearableListenerService` manifest binding model.
- Do not add unrelated exported components or broaden the listener filter.
- Do not change message paths, payload handling, activity launch behavior, or
  Google Play services versions in this pass.
