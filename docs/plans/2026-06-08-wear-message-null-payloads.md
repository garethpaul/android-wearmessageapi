# Wear Message Null Payloads

## Status: Completed

## Goal

Keep mobile and wear message encoding/decoding tolerant of null inputs so
message helpers return empty values instead of throwing `NullPointerException`.

## Red

- Added `encodesNullTextAsEmptyPayload` and `decodesNullPayloadAsEmptyText` to
  both mobile and wear `WearMessageTest` classes.
- Confirmed `./gradlew test --no-daemon` failed on the mobile null cases with
  the previous implementation.

## Green

- Updated both module-local `WearMessage` implementations to encode null text as
  an empty byte array and decode null payloads as an empty string.
- Extended `scripts/check-baseline.sh` to require the null guards and tests in
  both modules.
- Added `make check` as the root SDK-free verification wrapper.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew lint --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew test --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon`
- `git diff --check`
