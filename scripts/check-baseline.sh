#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ROOT_BUILD="$ROOT_DIR/build.gradle"
MOBILE_BUILD="$ROOT_DIR/mobile/build.gradle"
WEAR_BUILD="$ROOT_DIR/wear/build.gradle"
MOBILE_ACTIVITY="$ROOT_DIR/mobile/src/main/java/garethpaul/com/wearer/MainActivity.java"
WEAR_ACTIVITY="$ROOT_DIR/wear/src/main/java/garethpaul/com/wearer/MainActivity.java"
WEAR_SERVICE="$ROOT_DIR/wear/src/main/java/garethpaul/com/wearer/WearMessageListenerService.java"

for repo in "https://repo1.maven.org/maven2" "https://dl.google.com/dl/android/maven2"; do
  if ! grep -Fq "$repo" "$ROOT_BUILD"; then
    printf '%s\n' "Root build must include repository: $repo" >&2
    exit 1
  fi
done

if grep -Fq "jcenter()" "$ROOT_BUILD"; then
  printf '%s\n' "Root build must not use JCenter." >&2
  exit 1
fi

for build_file in "$MOBILE_BUILD" "$WEAR_BUILD"; do
  if ! grep -Fq 'buildToolsVersion "24.0.3"' "$build_file"; then
    printf '%s\n' "Both modules must pin Android build-tools 24.0.3." >&2
    exit 1
  fi
done

if grep -Fq "play-services:+" "$MOBILE_BUILD"; then
  printf '%s\n' "Mobile module must not use dynamic Google Play Services dependencies." >&2
  exit 1
fi

if ! grep -Fq "com.google.android.gms:play-services-wearable:7.0.0" "$MOBILE_BUILD"; then
  printf '%s\n' "Mobile module must pin play-services-wearable 7.0.0." >&2
  exit 1
fi

if ! grep -Fq "com.google.android.gms:play-services-wearable:7.0.0" "$WEAR_BUILD"; then
  printf '%s\n' "Wear module must pin play-services-wearable 7.0.0." >&2
  exit 1
fi

if grep -Fq "com.google.android.support:wearable" "$WEAR_BUILD"; then
  printf '%s\n' "Unused wearable support dependency must not be reintroduced." >&2
  exit 1
fi

if ! grep -Fq ".addConnectionCallbacks( this )" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile GoogleApiClient must register connection callbacks." >&2
  exit 1
fi

if ! grep -Fq 'START_ACTIVITY = "/start_activity"' "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile start-activity message path must remain documented." >&2
  exit 1
fi

if ! grep -Fq 'WEAR_MESSAGE_PATH = "/message"' "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile message path must remain documented." >&2
  exit 1
fi

if ! grep -Fq "Charset.forName(\"UTF-8\")" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile messages must encode payloads as UTF-8." >&2
  exit 1
fi

if ! grep -Fq "new String(messageEvent.getData(), MESSAGE_CHARSET)" "$WEAR_ACTIVITY"; then
  printf '%s\n' "Wear messages must decode payloads as UTF-8." >&2
  exit 1
fi

if ! grep -Fq 'START_ACTIVITY = "/start_activity"' "$WEAR_SERVICE"; then
  printf '%s\n' "Wear listener start-activity path must remain documented." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the baseline check." >&2
  exit 1
fi

printf '%s\n' "Android Wear Message API baseline checks passed."
