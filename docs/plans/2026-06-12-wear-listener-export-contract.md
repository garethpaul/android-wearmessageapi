# Wear Listener Export Contract

Status: Completed

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

## Verification Evidence

- SDK-free `make check` passed the manifest and source contracts.
- SDK-backed `make check` passed mobile and Wear lint with zero issues, all
  debug and release JVM test variants, and both debug APK assemblies.
- The complete SDK-backed gate and structured manifest parsing passed from a
  fresh external clone with the staged patch applied.
- All 13 focused service declaration, export policy, listener action,
  documentation, and plan mutations were rejected.
- Implementation SHA `ac0428a132e59fb001b32043364f1e16b668d486`
  passed pull-request run `27404104907` and CodeQL run `27404102731`.
  The exact PR ref reported zero open code-scanning alerts after Java/Kotlin
  analysis.

## Boundaries

- Do not make the listener private while this sample uses the legacy
  `WearableListenerService` manifest binding model.
- Do not add unrelated exported components or broaden the listener filter.
- Do not change message paths, payload handling, activity launch behavior, or
  Google Play services versions in this pass.
