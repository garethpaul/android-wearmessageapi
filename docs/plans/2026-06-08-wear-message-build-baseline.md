---
title: Android Wear Message API Build and Message Baseline
type: fix
status: completed
date: 2026-06-08
---

# Android Wear Message API Build and Message Baseline

## Summary

Raise the baseline for the legacy mobile/wear message sample by making Gradle
configure on the local SDK, pinning wearable dependencies, preserving message
paths, registering the mobile connection callback, using explicit UTF-8 payloads,
guarding mobile client cleanup, and documenting a source check.

---

## Problem Frame

The project currently fails during Gradle configuration because both modules pin
missing build-tools 21.1.2. The mobile module also uses dynamic
`com.google.android.gms:play-services:+`, root repositories use JCenter, the
wear module declares an unused wearable support dependency, and the mobile
`GoogleApiClient` does not register its connection callbacks despite sending the
watch launch message from `onConnected`.

---

## Requirements

- R1. Both mobile and wear modules must configure and assemble with the local Android SDK.
- R2. Google Play Services dependencies must be pinned, not dynamic.
- R3. Root repositories must use HTTPS Maven Central and Google Maven instead of JCenter.
- R4. The mobile `GoogleApiClient` must register and unregister connection callbacks so `onConnected` can send the start message without leaking callbacks after destroy.
- R5. The mobile `GoogleApiClient` must unregister callbacks and disconnect during cleanup.
- R6. Message payload encoding and decoding must use explicit UTF-8.
- R7. The `/message` and `/start_activity` paths must remain explicit in source.
- R8. The repository must include README verification notes and an SDK-free baseline check.

---

## Key Technical Decisions

- **Pin build-tools 24.0.3:** The installed 24.0.3 tools work on this host while preserving compile/target SDK 21.
- **Use Google Maven:** Play Services Wearable 7.0.0 resolves from Google Maven; the Android Gradle plugin resolves from Maven Central.
- **Pin wearable dependency:** The mobile module only uses Wearable APIs, so `play-services-wearable:7.0.0` replaces broad dynamic `play-services:+`.
- **Remove unused wearable support dependency:** Source does not reference support wearable widgets, so this dependency is unnecessary.
- **Use explicit message charset:** UTF-8 keeps mobile/wear payload behavior deterministic across devices.
- **Guard client cleanup:** Callback unregistration and connected/connecting
  disconnect checks keep lifecycle behavior explicit.

---

## Scope Boundaries

- This pass does not migrate to modern Wear OS APIs or GoogleApiClient replacements.
- This pass does not change message path strings, UI layouts, package names, or module structure.
- This pass does not add paired-device/emulator runtime verification.
- This pass does not update compile SDK, target SDK, or Android Gradle Plugin versions.

---

## Implementation Units

### U1. Stabilize Gradle Build

- **Goal:** Make the two-module project configure and assemble locally.
- **Files:** `build.gradle`, `mobile/build.gradle`, `wear/build.gradle`, `README.md`
- **Patterns:** Maven Central plus Google Maven, build-tools 24.0.3, pinned Play Services Wearable 7.0.0.
- **Test Scenarios:**
  - `./gradlew tasks --no-daemon` configures successfully.
  - `./gradlew assembleDebug --no-daemon` succeeds.
  - Source check fails if dynamic dependencies or JCenter return.
- **Verification:** Gradle commands and `scripts/check-baseline.sh`

### U2. Preserve Message Flow

- **Goal:** Keep mobile-to-wear startup and text messaging explicit and deterministic.
- **Files:** `mobile/src/main/java/garethpaul/com/wearer/MainActivity.java`, `wear/src/main/java/garethpaul/com/wearer/MainActivity.java`, `wear/src/main/java/garethpaul/com/wearer/WearMessageListenerService.java`
- **Patterns:** Register and unregister connection callbacks, disconnect connected or connecting clients, keep path constants, encode/decode message payloads with UTF-8.
- **Patterns:** Register and unregister connection callbacks, keep path constants, encode/decode message payloads with UTF-8.
- **Test Scenarios:**
  - Source check fails if callback registration or cleanup is removed.
  - Source check fails if callback cleanup is removed.
  - Source check fails if path constants are changed or hidden.
  - Source check fails if default platform charset is used for message payloads.
- **Verification:** `scripts/check-baseline.sh`, `./gradlew assembleDebug --no-daemon`

### U3. Document Baseline

- **Goal:** Give future maintainers a repeatable maintenance gate.
- **Files:** `README.md`, `docs/plans/2026-06-08-wear-message-build-baseline.md`, `scripts/check-baseline.sh`
- **Patterns:** Short toolchain, verification, and modernization notes.
- **Test Scenarios:**
  - README documents `scripts/check-baseline.sh`.
  - Plan documents build and runtime verification limits.
- **Verification:** `scripts/check-baseline.sh`

---

## Risks & Dependencies

- Runtime message delivery still requires paired mobile and Wear devices or emulators with Google Play Services.
- Wearable APIs and GoogleApiClient are deprecated; migration should be a separate behavior-aware pass.
- Dependency resolution depends on Google Maven availability for the legacy Play Services artifacts.

---

## Sources / Research

- `mobile/src/main/java/garethpaul/com/wearer/MainActivity.java` sends `/start_activity` and `/message` messages.
- `wear/src/main/java/garethpaul/com/wearer/MainActivity.java` displays `/message` payloads.
- `wear/src/main/java/garethpaul/com/wearer/WearMessageListenerService.java` launches the Wear activity from `/start_activity`.
- `mobile/build.gradle` used dynamic `play-services:+`; `wear/build.gradle` already pinned `play-services-wearable:7.0.0`.
- Local Gradle configuration failed because build-tools 21.1.2 is not installed.
