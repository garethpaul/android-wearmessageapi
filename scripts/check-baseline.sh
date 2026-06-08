#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ROOT_BUILD="$ROOT_DIR/build.gradle"
MOBILE_BUILD="$ROOT_DIR/mobile/build.gradle"
WEAR_BUILD="$ROOT_DIR/wear/build.gradle"
MOBILE_ACTIVITY="$ROOT_DIR/mobile/src/main/java/garethpaul/com/wearer/MainActivity.java"
WEAR_ACTIVITY="$ROOT_DIR/wear/src/main/java/garethpaul/com/wearer/MainActivity.java"
WEAR_SERVICE="$ROOT_DIR/wear/src/main/java/garethpaul/com/wearer/WearMessageListenerService.java"
MOBILE_MESSAGE="$ROOT_DIR/mobile/src/main/java/garethpaul/com/wearer/WearMessage.java"
WEAR_MESSAGE="$ROOT_DIR/wear/src/main/java/garethpaul/com/wearer/WearMessage.java"
MOBILE_MESSAGE_TEST="$ROOT_DIR/mobile/src/test/java/garethpaul/com/wearer/WearMessageTest.java"
WEAR_MESSAGE_TEST="$ROOT_DIR/wear/src/test/java/garethpaul/com/wearer/WearMessageTest.java"

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

for build_file in "$MOBILE_BUILD" "$WEAR_BUILD"; do
  if ! grep -Fq "testCompile 'junit:junit:4.12'" "$build_file"; then
    printf '%s\n' "Both modules must declare JUnit for WearMessage tests." >&2
    exit 1
  fi
done

if grep -Fq "com.google.android.support:wearable" "$WEAR_BUILD"; then
  printf '%s\n' "Unused wearable support dependency must not be reintroduced." >&2
  exit 1
fi

if ! grep -Fq ".addConnectionCallbacks( this )" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile GoogleApiClient must register connection callbacks." >&2
  exit 1
fi

if ! grep -Fq "unregisterConnectionCallbacks( this )" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile GoogleApiClient callbacks must be unregistered." >&2
  exit 1
fi

if ! grep -Fq "mApiClient.isConnected() || mApiClient.isConnecting()" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile GoogleApiClient cleanup must handle connected and connecting states." >&2
  exit 1
fi

if ! grep -Fq "mApiClient == null || !mApiClient.isConnected()" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile message sends must guard disconnected GoogleApiClient state." >&2
  exit 1
fi

if ! grep -Fq "WearMessage.START_ACTIVITY" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile start-activity message must use the WearMessage contract." >&2
  exit 1
fi

if ! grep -Fq "WearMessage.WEAR_MESSAGE_PATH" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile text messages must use the WearMessage contract." >&2
  exit 1
fi

if ! grep -Fq "WearMessage.encode(text)" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile messages must encode payloads as UTF-8." >&2
  exit 1
fi

if ! grep -Fq "WearMessage.decode(messageEvent.getData())" "$WEAR_ACTIVITY"; then
  printf '%s\n' "Wear messages must decode payloads as UTF-8." >&2
  exit 1
fi

if ! grep -Fq "WearMessage.isStartActivityPath(messageEvent.getPath())" "$WEAR_SERVICE"; then
  printf '%s\n' "Wear listener must use the WearMessage start path guard." >&2
  exit 1
fi

for message_file in "$MOBILE_MESSAGE" "$WEAR_MESSAGE"; do
  if ! grep -Fq 'START_ACTIVITY = "/start_activity"' "$message_file"; then
    printf '%s\n' "WearMessage must preserve the start-activity path." >&2
    exit 1
  fi
  if ! grep -Fq 'WEAR_MESSAGE_PATH = "/message"' "$message_file"; then
    printf '%s\n' "WearMessage must preserve the text message path." >&2
    exit 1
  fi
  if ! grep -Fq 'Charset.forName("UTF-8")' "$message_file"; then
    printf '%s\n' "WearMessage must use explicit UTF-8 encoding." >&2
    exit 1
  fi
  if ! grep -Fq "path != null && START_ACTIVITY.equalsIgnoreCase(path)" "$message_file"; then
    printf '%s\n' "WearMessage must null-guard startup path checks." >&2
    exit 1
  fi
done

for test_file in "$MOBILE_MESSAGE_TEST" "$WEAR_MESSAGE_TEST"; do
  if ! grep -Fq "encodesMessagesAsUtf8" "$test_file"; then
    printf '%s\n' "WearMessage tests must cover UTF-8 round trips." >&2
    exit 1
  fi
done

if git -C "$ROOT_DIR" ls-files '.idea/*' '*.iml' | grep -q .; then
  printf '%s\n' "Generated IDE metadata must not be tracked." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the baseline check." >&2
  exit 1
fi

printf '%s\n' "Android Wear Message API baseline checks passed."
