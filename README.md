# Android Wear Message API

Legacy two-module Android sample that sends text from a mobile app to a Wear app
through the Google Play Services Wearable Message API.

## Toolchain

This project currently uses the original Android build stack:

- Gradle wrapper 2.2.1
- Android Gradle Plugin 1.1.0
- compile SDK 21 / target SDK 21
- Android build-tools 24.0.3
- Google Play Services Wearable 7.0.0

Gradle resolves Android plugin artifacts from HTTPS Maven Central and Google
Play Services artifacts from Google Maven.

Configure an Android SDK path before running Gradle:

```sh
export ANDROID_HOME=/path/to/android-sdk
```

or create an untracked `local.properties` file:

```properties
sdk.dir=/path/to/android-sdk
```

## Verify

Run the SDK-free source baseline check first:

```sh
scripts/check-baseline.sh
```

Then run Gradle after Android SDK configuration is available:

```sh
ANDROID_HOME=/home/gjones/android-sdk ./gradlew tasks --no-daemon
ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon
ANDROID_HOME=/home/gjones/android-sdk ./gradlew test --no-daemon
```

## Modernization Notes

The current baseline pins wearable dependencies, uses UTF-8 for message payload
encoding/decoding, registers and unregisters mobile connection callbacks so the
watch launch message can be sent, and keeps the legacy mobile/wear module
layout. Future work should add paired-device verification, migrate away from
deprecated Wearable Message APIs, and modernize SDK/dependency levels in a
dedicated pass.
