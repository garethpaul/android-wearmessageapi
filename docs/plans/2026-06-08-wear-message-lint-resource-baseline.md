# Android Wear Message API Lint Resource Baseline

## Goal

Make the legacy mobile/wear sample pass lint without changing the Wearable Message API contract or the pinned legacy dependency stack.

## Scope

- Keep compile and target SDK 21 for both modules.
- Keep Google Play Services Wearable pinned at 7.0.0.
- Clean starter-template resources from the mobile and wear modules.
- Add source-only checks for the documented lint baseline and changelog.

## Verification

- `scripts/check-baseline.sh`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew lint --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew test --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon`
