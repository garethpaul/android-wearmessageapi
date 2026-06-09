#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ROOT_BUILD="$ROOT_DIR/build.gradle"
MOBILE_BUILD="$ROOT_DIR/mobile/build.gradle"
WEAR_BUILD="$ROOT_DIR/wear/build.gradle"
MOBILE_ACTIVITY="$ROOT_DIR/mobile/src/main/java/garethpaul/com/wearer/MainActivity.java"
WEAR_ACTIVITY="$ROOT_DIR/wear/src/main/java/garethpaul/com/wearer/MainActivity.java"
WEAR_SERVICE="$ROOT_DIR/wear/src/main/java/garethpaul/com/wearer/WearMessageListenerService.java"
MOBILE_MANIFEST="$ROOT_DIR/mobile/src/main/AndroidManifest.xml"
WEAR_MANIFEST="$ROOT_DIR/wear/src/main/AndroidManifest.xml"
MOBILE_LINT="$ROOT_DIR/mobile/lint.xml"
WEAR_LINT="$ROOT_DIR/wear/lint.xml"
MOBILE_LAYOUT="$ROOT_DIR/mobile/src/main/res/layout/activity_main.xml"
WEAR_LAYOUT="$ROOT_DIR/wear/src/main/res/layout/activity_main.xml"
MOBILE_STRINGS="$ROOT_DIR/mobile/src/main/res/values/strings.xml"
WEAR_STRINGS="$ROOT_DIR/wear/src/main/res/values/strings.xml"
WEAR_STYLES="$ROOT_DIR/wear/src/main/res/values/styles.xml"
MOBILE_MESSAGE="$ROOT_DIR/mobile/src/main/java/garethpaul/com/wearer/WearMessage.java"
WEAR_MESSAGE="$ROOT_DIR/wear/src/main/java/garethpaul/com/wearer/WearMessage.java"
MOBILE_MESSAGE_TEST="$ROOT_DIR/mobile/src/test/java/garethpaul/com/wearer/WearMessageTest.java"
WEAR_MESSAGE_TEST="$ROOT_DIR/wear/src/test/java/garethpaul/com/wearer/WearMessageTest.java"
NULL_PAYLOAD_PLAN="$ROOT_DIR/docs/plans/2026-06-08-wear-message-null-payloads.md"
PATH_CONTRACT_PLAN="$ROOT_DIR/docs/plans/2026-06-09-wear-message-path-contract-baseline.md"
SEND_RESULT_PLAN="$ROOT_DIR/docs/plans/2026-06-09-wear-message-send-result-baseline.md"
WEAR_RECEIVER_PLAN="$ROOT_DIR/docs/plans/2026-06-09-wear-message-receiver-lifecycle.md"

if [ ! -f "$ROOT_DIR/CHANGES.md" ]; then
  printf '%s\n' "CHANGES.md must document repository maintenance." >&2
  exit 1
fi

if ! grep -Fq "Android Wear Message API Changes" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "CHANGES.md must identify the project." >&2
  exit 1
fi

if [ ! -f "$NULL_PAYLOAD_PLAN" ]; then
  printf '%s\n' "Wear message null payload plan is missing." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$NULL_PAYLOAD_PLAN" || ! grep -Fq "make check" "$NULL_PAYLOAD_PLAN"; then
  printf '%s\n' "Wear message null payload plan must record completed status and make check verification." >&2
  exit 1
fi

if [ ! -f "$PATH_CONTRACT_PLAN" ]; then
  printf '%s\n' "Wear message path contract plan is missing." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$PATH_CONTRACT_PLAN" || ! grep -Fq "make check" "$PATH_CONTRACT_PLAN"; then
  printf '%s\n' "Wear message path contract plan must record completed status and make check verification." >&2
  exit 1
fi

if [ ! -f "$SEND_RESULT_PLAN" ]; then
  printf '%s\n' "Wear message send result plan is missing." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$SEND_RESULT_PLAN" || ! grep -Fq "make check" "$SEND_RESULT_PLAN"; then
  printf '%s\n' "Wear message send result plan must record completed status and make check verification." >&2
  exit 1
fi

if [ ! -f "$WEAR_RECEIVER_PLAN" ]; then
  printf '%s\n' "Wear message receiver lifecycle plan is missing." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$WEAR_RECEIVER_PLAN" || ! grep -Fq "make check" "$WEAR_RECEIVER_PLAN"; then
  printf '%s\n' "Wear message receiver lifecycle plan must record completed status and make check verification." >&2
  exit 1
fi

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

for lint_file in "$MOBILE_LINT" "$WEAR_LINT"; do
  if [ ! -f "$lint_file" ]; then
    printf '%s\n' "Both modules must track legacy lint configuration." >&2
    exit 1
  fi
  for lint_id in GradleDependency LintError OldTargetApi; do
    if ! grep -Fq "<issue id=\"$lint_id\" severity=\"ignore\" />" "$lint_file"; then
      printf '%s\n' "Legacy lint config must suppress $lint_id for the pinned stack." >&2
      exit 1
    fi
  done
done

if grep -Fq "com.google.android.support:wearable" "$WEAR_BUILD"; then
  printf '%s\n' "Unused wearable support dependency must not be reintroduced." >&2
  exit 1
fi

for manifest in "$MOBILE_MANIFEST" "$WEAR_MANIFEST"; do
  if ! grep -Fq 'android:allowBackup="false"' "$manifest"; then
    printf '%s\n' "Android backup must stay disabled in both manifests." >&2
    exit 1
  fi
done

if ! grep -Fq 'android:theme="@style/WearTheme"' "$WEAR_MANIFEST"; then
  printf '%s\n' "Wear manifest must use the tracked WearTheme." >&2
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

if ! grep -Fq "MessageApi.SendMessageResult result" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile message sends must inspect the Wear message result." >&2
  exit 1
fi

if ! grep -Fq "result.getStatus().isSuccess()" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile message input must clear only after a successful send." >&2
  exit 1
fi

if ! grep -Fq "if (messageSent)" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile message sends must preserve text when no paired node accepts it." >&2
  exit 1
fi

if ! grep -Fq "private void clearMessageInput()" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile input clearing must stay isolated behind the send-success guard." >&2
  exit 1
fi

if ! grep -Fq "WearMessage.decode(messageEvent.getData())" "$WEAR_ACTIVITY"; then
  printf '%s\n' "Wear messages must decode payloads as UTF-8." >&2
  exit 1
fi

if ! grep -Fq "messageEvent == null || !WearMessage.isWearMessagePath(messageEvent.getPath())" "$WEAR_ACTIVITY"; then
  printf '%s\n' "Wear message receiver must ignore null events and non-message paths before UI dispatch." >&2
  exit 1
fi

if ! grep -Fq "final String text = WearMessage.decode(messageEvent.getData())" "$WEAR_ACTIVITY"; then
  printf '%s\n' "Wear message receiver must decode payloads before posting UI work." >&2
  exit 1
fi

if ! grep -Fq "private void addWearMessage( String text )" "$WEAR_ACTIVITY"; then
  printf '%s\n' "Wear message receiver must isolate adapter updates behind a helper." >&2
  exit 1
fi

if ! grep -Fq "if( mAdapter == null )" "$WEAR_ACTIVITY"; then
  printf '%s\n' "Wear message receiver must tolerate callbacks when the adapter is unavailable." >&2
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
  if ! grep -Fq "if (text == null)" "$message_file"; then
    printf '%s\n' "WearMessage must encode null text as an empty payload." >&2
    exit 1
  fi
  if ! grep -Fq "if (data == null)" "$message_file"; then
    printf '%s\n' "WearMessage must decode null payloads as empty text." >&2
    exit 1
  fi
  if ! grep -Fq "path != null && START_ACTIVITY.equalsIgnoreCase(path)" "$message_file"; then
    printf '%s\n' "WearMessage must null-guard startup path checks." >&2
    exit 1
  fi
  if ! grep -Fq "path != null && WEAR_MESSAGE_PATH.equalsIgnoreCase(path)" "$message_file"; then
    printf '%s\n' "WearMessage must null-guard text message path checks." >&2
    exit 1
  fi
done

for test_file in "$MOBILE_MESSAGE_TEST" "$WEAR_MESSAGE_TEST"; do
  if ! grep -Fq "recognizesStartActivityPathCaseInsensitively" "$test_file"; then
    printf '%s\n' "WearMessage tests must cover case-insensitive start path matching." >&2
    exit 1
  fi
  if ! grep -Fq "recognizesWearMessagePathCaseInsensitively" "$test_file"; then
    printf '%s\n' "WearMessage tests must cover case-insensitive text path matching." >&2
    exit 1
  fi
  if ! grep -Fq "encodesMessagesAsUtf8" "$test_file"; then
    printf '%s\n' "WearMessage tests must cover UTF-8 round trips." >&2
    exit 1
  fi
  if ! grep -Fq "encodesNullTextAsEmptyPayload" "$test_file"; then
    printf '%s\n' "WearMessage tests must cover null text encoding." >&2
    exit 1
  fi
  if ! grep -Fq "decodesNullPayloadAsEmptyText" "$test_file"; then
    printf '%s\n' "WearMessage tests must cover null payload decoding." >&2
    exit 1
  fi
done

for removed_resource in \
  "$ROOT_DIR/mobile/src/main/res/menu/menu_main.xml" \
  "$ROOT_DIR/wear/src/main/res/layout/rect_activity_main.xml" \
  "$ROOT_DIR/wear/src/main/res/layout/round_activity_main.xml"; do
  if [ -e "$removed_resource" ]; then
    printf '%s\n' "Unused starter menu and wear shape layouts must not be present." >&2
    exit 1
  fi
done

if grep -Fq "Hello world!" "$MOBILE_STRINGS"; then
  printf '%s\n' "Mobile starter hello_world string must not be tracked." >&2
  exit 1
fi

if grep -Fq "Hello Round World!" "$WEAR_STRINGS" || grep -Fq "Hello Square World!" "$WEAR_STRINGS"; then
  printf '%s\n' "Wear starter shape strings must not be tracked." >&2
  exit 1
fi

if ! grep -Fq 'android:labelFor="@+id/input"' "$MOBILE_LAYOUT"; then
  printf '%s\n' "Mobile message input must have an accessibility label." >&2
  exit 1
fi

if ! grep -Fq 'android:hint="@string/message_input_hint"' "$MOBILE_LAYOUT"; then
  printf '%s\n' "Mobile message input must have a resource-backed hint." >&2
  exit 1
fi

if grep -Fq 'android:text="Send"' "$MOBILE_LAYOUT"; then
  printf '%s\n' "Mobile send button text must use a string resource." >&2
  exit 1
fi

if ! grep -Fq 'android:text="@string/send_button"' "$MOBILE_LAYOUT"; then
  printf '%s\n' "Mobile send button string resource must be wired into the layout." >&2
  exit 1
fi

if grep -Fq 'android:background="@android:color/white"' "$WEAR_LAYOUT"; then
  printf '%s\n' "Wear background must be provided by the theme to avoid overdraw." >&2
  exit 1
fi

if ! grep -Fq '<item name="android:windowBackground">@android:color/white</item>' "$WEAR_STYLES"; then
  printf '%s\n' "WearTheme must provide the white list background." >&2
  exit 1
fi

if git -C "$ROOT_DIR" ls-files '.idea/*' '*.iml' | grep -q .; then
  printf '%s\n' "Generated IDE metadata must not be tracked." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the baseline check." >&2
  exit 1
fi

if [ ! -f "$ROOT_DIR/Makefile" ]; then
  printf '%s\n' "Makefile is missing." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must run the SDK-free baseline check." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the make check wrapper." >&2
  exit 1
fi

if ! grep -Fq "./gradlew lint --no-daemon" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the lint gate." >&2
  exit 1
fi

if ! grep -Fq "./gradlew test --no-daemon" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the unit test gate." >&2
  exit 1
fi

if ! grep -Fq "./gradlew assembleDebug --no-daemon" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the debug assemble gate." >&2
  exit 1
fi

if ! grep -Fq "CHANGES.md" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must point to CHANGES.md." >&2
  exit 1
fi

printf '%s\n' "Android Wear Message API baseline checks passed."
