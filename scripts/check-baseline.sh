#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ROOT_BUILD="$ROOT_DIR/build.gradle"
MOBILE_BUILD="$ROOT_DIR/mobile/build.gradle"
WEAR_BUILD="$ROOT_DIR/wear/build.gradle"
SETTINGS_GRADLE="$ROOT_DIR/settings.gradle"
GRADLE_PROPERTIES="$ROOT_DIR/gradle.properties"
WRAPPER_PROPERTIES="$ROOT_DIR/gradle/wrapper/gradle-wrapper.properties"
GRADLEW="$ROOT_DIR/gradlew"
GRADLEW_BAT="$ROOT_DIR/gradlew.bat"
WRAPPER_JAR="$ROOT_DIR/gradle/wrapper/gradle-wrapper.jar"
VERIFIED_GRADLE="$ROOT_DIR/scripts/verified-gradle.sh"
MOBILE_ACTIVITY="$ROOT_DIR/mobile/src/main/java/garethpaul/com/wearer/MainActivity.java"
WEAR_ACTIVITY="$ROOT_DIR/wear/src/main/java/garethpaul/com/wearer/MainActivity.java"
WEAR_LAUNCHER="$ROOT_DIR/wear/src/main/java/garethpaul/com/wearer/LauncherActivity.java"
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
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"
CODEOWNERS="$ROOT_DIR/.github/CODEOWNERS"
SEND_TIMEOUT_PLAN="$ROOT_DIR/docs/plans/2026-06-12-wear-mobile-send-timeouts.md"

require_sha256() {
  file=$1
  expected=$2
  message=$3

  if [ "$(sha256sum "$file" | awk '{print $1}')" != "$expected" ]; then
    printf '%s\n' "$message" >&2
    exit 1
  fi
}

if git -C "$ROOT_DIR" ls-files -s | awk '$1 == "120000" { found = 1 } END { exit found ? 0 : 1 }'; then
  printf '%s\n' "Tracked symbolic links are outside the audited repository baseline." >&2
  exit 1
fi

manifest_paths=$(find "$ROOT_DIR/mobile/src" "$ROOT_DIR/wear/src" -type f -name 'AndroidManifest.xml' -print | LC_ALL=C sort)
expected_manifest_paths=$(printf '%s\n' "$MOBILE_MANIFEST" "$WEAR_MANIFEST" | LC_ALL=C sort)
if [ "$manifest_paths" != "$expected_manifest_paths" ]; then
  printf '%s\n' "Mobile and Wear must keep exactly the audited manifests." >&2
  exit 1
fi

if find "$ROOT_DIR/mobile" "$ROOT_DIR/wear" -type f \
  \( -name '*.so' -o -name '*.dex' -o -name '*.jar' -o -name '*.aar' -o -name '*.apk' \) \
  ! -path '*/build/*' -print | grep -q .; then
  printf '%s\n' "Packaged Android binary payloads are outside the auditable source baseline." >&2
  exit 1
fi

gradle_paths=$(find "$ROOT_DIR" \
  -path "$ROOT_DIR/.git" -prune -o \
  -path "$ROOT_DIR/mobile/build" -prune -o \
  -path "$ROOT_DIR/wear/build" -prune -o \
  -type f \( -name '*.gradle' -o -name 'gradle.properties' -o -name 'gradle-wrapper.properties' \) \
  -print | LC_ALL=C sort)
expected_gradle_paths=$(printf '%s\n' \
  "$MOBILE_BUILD" \
  "$ROOT_BUILD" \
  "$SETTINGS_GRADLE" \
  "$GRADLE_PROPERTIES" \
  "$WRAPPER_PROPERTIES" \
  "$WEAR_BUILD" | LC_ALL=C sort)
if [ "$gradle_paths" != "$expected_gradle_paths" ]; then
  printf '%s\n' "The fixed legacy build must not add executable Gradle configuration." >&2
  exit 1
fi

if [ -e "$ROOT_DIR/buildSrc" ] || [ -L "$ROOT_DIR/buildSrc" ]; then
  printf '%s\n' "Gradle buildSrc is an unapproved implicit executable build input." >&2
  exit 1
fi

require_sha256 "$GRADLEW" "874d75d37bf38c810a8314e0b2f78a3c77fce9437963ae33cec8543d92662b61" \
  "The Unix Gradle wrapper must match the recorded trusted hash."
require_sha256 "$GRADLEW_BAT" "c13c6e91b9a517783976de213d46398c661ea9e17651376d7301e839eaedcc62" \
  "The Windows Gradle wrapper must match the recorded trusted hash."
require_sha256 "$WRAPPER_JAR" "e2b82129ab64751fd40437007bd2f7f2afb3c6e41a9198e628650b22d5824a14" \
  "The Gradle wrapper JAR must match the recorded trusted hash."
if [ ! -f "$CI_WORKFLOW" ]; then
  printf '%s\n' "GitHub Actions check workflow is missing." >&2
  exit 1
fi

workflow_paths=$(find "$ROOT_DIR/.github/workflows" -type f \( -name '*.yml' -o -name '*.yaml' \) -print | LC_ALL=C sort)
if [ "$workflow_paths" != "$CI_WORKFLOW" ]; then
  printf '%s\n' "The canonical check workflow must be the only GitHub Actions workflow." >&2
  exit 1
fi

if grep -E '^[[:space:]]*(-[[:space:]]+)?uses:' "$CI_WORKFLOW" | grep -Ev '@[0-9a-f]{40}([[:space:]]+#.*)?$' >/dev/null; then
  printf '%s\n' "GitHub Actions must use immutable commit SHAs." >&2
  exit 1
fi

workflow_uses=$(grep -E '^[[:space:]]*(-[[:space:]]+)?uses:' "$CI_WORKFLOW" | sed -E 's/^[[:space:]]*(-[[:space:]]+)?//' | LC_ALL=C sort)
expected_workflow_uses=$(printf '%s\n' \
  'uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10 # v6.0.3' \
  'uses: actions/setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654 # v5.2.0' | LC_ALL=C sort)
if [ "$workflow_uses" != "$expected_workflow_uses" ]; then
  printf '%s\n' "GitHub Actions must use only the audited setup actions." >&2
  exit 1
fi

if [ "$(grep -Ec '^[[:space:]]*permissions:' "$CI_WORKFLOW")" -ne 1 ] ||
   grep -Eq 'write-all|contents:[[:space:]]*write|pull-requests:[[:space:]]*write|actions:[[:space:]]*write' "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions permissions must remain globally read-only." >&2
  exit 1
fi

if [ "$(grep -Ec '^[[:space:]]*(-[[:space:]]+)?run:' "$CI_WORKFLOW")" -ne 2 ] ||
   ! grep -Fq 'run: '\''"${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-21" "build-tools;24.0.3"'\''' "$CI_WORKFLOW" ||
   ! grep -Eq '^[[:space:]]*run: make check[[:space:]]*$' "$CI_WORKFLOW" ||
   grep -Eq 'continue-on-error:[[:space:]]*true|if:[[:space:]]*false' "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions must run exactly the required Make gate without bypasses." >&2
  exit 1
fi

for workflow_contract in \
  'push:' \
  'branches:' \
  '- master' \
  'pull_request:' \
  'workflow_dispatch:' \
  'permissions:' \
  'contents: read' \
  'FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true' \
  'runs-on: ubuntu-24.04' \
  'timeout-minutes: 15' \
  'cancel-in-progress: true' \
  'persist-credentials: false' \
  '"${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-21" "build-tools;24.0.3"' \
  'java-version: "8"' \
  'run: make check'; do
  if ! grep -Fq -- "$workflow_contract" "$CI_WORKFLOW"; then
    printf '%s\n' "GitHub Actions workflow must keep contract: $workflow_contract" >&2
    exit 1
  fi
done

if ! awk '
  /^  pull_request:$/ {
    found = 1
    if (getline <= 0 || $0 != "  workflow_dispatch:") exit 1
  }
  END { if (!found) exit 1 }
' "$CI_WORKFLOW"; then
  printf '%s\n' "Pull request verification must apply without branch restrictions." >&2
  exit 1
fi

android_setup_line=$(grep -n 'cmdline-tools/latest/bin/sdkmanager' "$CI_WORKFLOW" | cut -d: -f1)
java_setup_line=$(grep -n 'actions/setup-java@' "$CI_WORKFLOW" | cut -d: -f1)
if [ -z "$android_setup_line" ] || [ -z "$java_setup_line" ] || [ "$android_setup_line" -ge "$java_setup_line" ]; then
  printf '%s\n' "Android SDK installation must run under the runner JDK before selecting Java 8 for Gradle." >&2
  exit 1
fi

codeowner_rules=$(grep -Ev '^[[:space:]]*(#|$)' "$CODEOWNERS" 2>/dev/null || true)
if [ "$codeowner_rules" != '* @garethpaul' ]; then
  printf '%s\n' "CODEOWNERS must protect repository and module trust boundaries." >&2
  exit 1
fi

for make_contract in \
  'ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' \
  'ANDROID_SDK := $(if $(ANDROID_HOME),$(ANDROID_HOME),$(ANDROID_SDK_ROOT))' \
  'GRADLE ?= $(ROOT)scripts/verified-gradle.sh'; do
  if ! grep -Fq "$make_contract" "$ROOT_DIR/Makefile"; then
    printf '%s\n' "Makefile must keep contract: $make_contract" >&2
    exit 1
  fi
done

for gradle_contract in \
  'https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip' \
  '1d7c28b3731906fd1b2955946c1d052303881585fc14baedd675e4cf2bc1ecab' \
  'curl --fail --location --silent --show-error' \
  'sha256sum "$download"' \
  'exec "$GRADLE_INSTALLATION/bin/gradle" "$@"'; do
  if ! grep -Fq "$gradle_contract" "$VERIFIED_GRADLE"; then
    printf '%s\n' "Verified Gradle launcher must keep contract: $gradle_contract" >&2
    exit 1
  fi
done

if grep -Eq '/(home|Users)/[^/]+/.+android-sdk' "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must not embed a maintainer-specific Android SDK path." >&2
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

  dependency_lines=$(grep -E '^[[:space:]]*(compile|testCompile)[[:space:]]' "$build_file" | sed 's/^[[:space:]]*//' | LC_ALL=C sort)
  expected_dependency_lines=$(printf '%s\n' \
    "compile 'com.google.android.gms:play-services-wearable:7.0.0'" \
    "compile fileTree(dir: 'libs', include: ['*.jar'])" \
    "testCompile 'junit:junit:4.12'" | LC_ALL=C sort)
  if [ "$dependency_lines" != "$expected_dependency_lines" ]; then
    printf '%s\n' "Android modules must keep the reviewed dependency inventory." >&2
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

main_activity_manifest=$(awk '/android:name=".MainActivity"/ { capture = 1 } capture { print } capture && />/ { exit }' "$WEAR_MANIFEST")
launcher_activity_manifest=$(awk '/android:name=".LauncherActivity"/ { capture = 1 } capture { print } capture && />/ { exit }' "$WEAR_MANIFEST")
if ! printf '%s\n' "$main_activity_manifest" | grep -Fq 'android:exported="false"' ||
   ! printf '%s\n' "$launcher_activity_manifest" | grep -Fq 'android:exported="true"'; then
  printf '%s\n' "Wear message UI must be private and its launcher explicitly exported." >&2
  exit 1
fi

for launcher_contract in \
  'new Intent(this, MainActivity.class)' \
  'Intent.FLAG_ACTIVITY_CLEAR_TOP' \
  'Intent.FLAG_ACTIVITY_SINGLE_TOP' \
  'startActivity(intent)' \
  'finish()'; do
  if ! grep -Fq "$launcher_contract" "$WEAR_LAUNCHER"; then
    printf '%s\n' "Wear launcher must discard external extras before opening the private message UI." >&2
    exit 1
  fi
done

if grep -Eq 'getIntent\(|getExtras\(|putExtra\(|putExtras\(' "$WEAR_LAUNCHER"; then
  printf '%s\n' "Wear launcher must not forward externally supplied extras." >&2
  exit 1
fi

if ! grep -Fq ".addConnectionCallbacks( this )" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile GoogleApiClient must register connection callbacks." >&2
  exit 1
fi

if ! grep -Fq ".addOnConnectionFailedListener( this )" "$MOBILE_ACTIVITY" || \
   ! grep -Fq "GoogleApiClient.OnConnectionFailedListener" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile GoogleApiClient must register connection failure callbacks." >&2
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

if ! grep -Fq "GoogleApiClient apiClient = mApiClient" "$MOBILE_ACTIVITY" || \
   ! grep -Fq "apiClient == null || !apiClient.isConnected()" "$MOBILE_ACTIVITY"; then
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

if ! grep -Fq "WearMessage.normalizeText(mEditText.getText())" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile sends must normalize typed text before empty-message checks." >&2
  exit 1
fi

if ! grep -Fq "MessageApi.SendMessageResult result" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile message sends must inspect the Wear message result." >&2
  exit 1
fi

for timeout_contract in \
  "private static final long MESSAGE_OPERATION_TIMEOUT_SECONDS = 5L;" \
  "import java.util.concurrent.TimeUnit;" \
  ".await(MESSAGE_OPERATION_TIMEOUT_SECONDS, TimeUnit.SECONDS)" \
  "MESSAGE_OPERATION_TIMEOUT_SECONDS," \
  "TimeUnit.SECONDS);"; do
  if ! grep -Fq "$timeout_contract" "$MOBILE_ACTIVITY"; then
    printf '%s\n' "Mobile Wear operations must keep bounded wait contract: $timeout_contract" >&2
    exit 1
  fi
done

if [ "$(grep -Fc "private static final long MESSAGE_OPERATION_TIMEOUT_SECONDS = 5L;" "$MOBILE_ACTIVITY" || true)" -ne 1 ] || \
   [ "$(grep -Fc "import java.util.concurrent.TimeUnit;" "$MOBILE_ACTIVITY" || true)" -ne 1 ] || \
   [ "$(grep -Ec '\.await[[:space:]]*\(' "$MOBILE_ACTIVITY" || true)" -ne 2 ] || \
   [ "$(grep -Fc "MESSAGE_OPERATION_TIMEOUT_SECONDS" "$MOBILE_ACTIVITY" || true)" -ne 3 ] || \
   [ "$(grep -Fc "TimeUnit.SECONDS" "$MOBILE_ACTIVITY" || true)" -ne 2 ]; then
  printf '%s\n' "Mobile Wear node lookup and message send must each use the shared timeout exactly once." >&2
  exit 1
fi

if grep -Eq '\.await[[:space:]]*\([[:space:]]*\)' "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile Wear operations must not block indefinitely." >&2
  exit 1
fi

if [ ! -f "$SEND_TIMEOUT_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$SEND_TIMEOUT_PLAN" || \
   ! grep -Fq "make check" "$SEND_TIMEOUT_PLAN"; then
  printf '%s\n' "Wear mobile send timeout plan must record completed make check verification." >&2
  exit 1
fi

if ! grep -Fq "if (nodes == null || nodes.getNodes() == null)" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile message sends must guard missing connected-node results." >&2
  exit 1
fi

if ! grep -Fq "if (node == null || node.getId() == null)" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile message sends must guard missing connected-node ids." >&2
  exit 1
fi

if ! grep -Fq "result != null && result.getStatus() != null" "$MOBILE_ACTIVITY" || \
   ! grep -Fq "result.getStatus().isSuccess()" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile message sends must guard null send results before checking status." >&2
  exit 1
fi

for send_state_contract in \
  "if (TextUtils.isEmpty(text) || !WearMessage.isValidMessageText(text)" \
  "messageSendInProgress = true" \
  "private boolean wearConnected;" \
  "private boolean isWearConnected()" \
  "return wearConnected && mApiClient != null && mApiClient.isConnected()" \
  "private void updateSendButtonState()" \
  "mSendButton.setEnabled(!messageSendInProgress && isWearConnected()" \
  "sendMessage(WearMessage.WEAR_MESSAGE_PATH, text, true)" \
  "final boolean reportUserResult" \
  "finally" \
  "if (reportUserResult)" \
  "completeMessageSend(text, messageSent)" \
  "private void completeMessageSend(final String sentText, final boolean messageSent)" \
  "if (isFinishing() || isDestroyed())" \
  "messageSendInProgress = false" \
  "public void onConnectionSuspended(int i)" \
  "public void onConnectionFailed(ConnectionResult connectionResult)" \
  "if (!messageSent)" \
  "R.string.message_send_failed" \
  "mAdapter.add(sentText)" \
  "WearMessage.shouldClearInput(mEditText.getText(), sentText)"; do
  if ! grep -Fq "$send_state_contract" "$MOBILE_ACTIVITY"; then
    printf '%s\n' "Missing mobile send-state contract: $send_state_contract" >&2
    exit 1
  fi
done

if [ "$(grep -Fc "wearConnected = false;" "$MOBILE_ACTIVITY")" -lt 3 ] || \
   [ "$(grep -Fc "wearConnected = true;" "$MOBILE_ACTIVITY")" -ne 1 ]; then
  printf '%s\n' "Mobile Wear connection state must follow connect, suspend, failure, and destroy callbacks." >&2
  exit 1
fi

if ! awk '
  /public void onConnected\(Bundle bundle\)/ { in_connected = 1 }
  in_connected && /wearConnected = true;/ { found = 1 }
  in_connected && /sendMessage\(WearMessage.START_ACTIVITY/ { in_connected = 0 }
  END { exit found ? 0 : 1 }
' "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile Wear connection state must become ready inside onConnected." >&2
  exit 1
fi

if [ "$(grep -Fc "updateSendButtonState();" "$MOBILE_ACTIVITY")" -lt 5 ]; then
  printf '%s\n' "Mobile send controls must follow initialization, completion, and connection callbacks." >&2
  exit 1
fi

if grep -Fq "mSendButton.setEnabled(true)" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile send controls must not bypass connection-aware state." >&2
  exit 1
fi

if ! grep -Fq 'sendMessage(WearMessage.START_ACTIVITY, "", false)' "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Start-activity control sends must not update user-message UI state." >&2
  exit 1
fi

if awk '
  /catch \(RuntimeException ignored\)/ { in_catch = 1 }
  in_catch && /messageSent = false/ { found = 1 }
  in_catch && /finally/ { in_catch = 0 }
  END { exit found ? 0 : 1 }
' "$MOBILE_ACTIVITY"; then
  printf '%s\n' "A later node exception must not erase an earlier successful send." >&2
  exit 1
fi

if grep -Fq "mAdapter.add(text);" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile history must not record a message before a node accepts it." >&2
  exit 1
fi

for message_file in "$MOBILE_MESSAGE" "$WEAR_MESSAGE"; do
  if ! grep -Fq "static boolean shouldClearInput(CharSequence currentText, String sentText)" "$message_file" || \
     ! grep -Fq "normalizedSentText.equals(normalizeText(currentText))" "$message_file"; then
    printf '%s\n' "WearMessage must clear only unchanged matching input." >&2
    exit 1
  fi
done

if ! grep -Fq 'name="message_send_failed"' "$MOBILE_STRINGS"; then
  printf '%s\n' "Mobile send failure feedback must use a string resource." >&2
  exit 1
fi

if ! grep -Fq "private boolean init()" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile startup view binding must report whether required controls are available." >&2
  exit 1
fi

if ! grep -Fq "if( !init() )" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile activity must stop before connecting when startup views are unavailable." >&2
  exit 1
fi

if ! grep -Fq "if( mListView == null || mEditText == null || mSendButton == null )" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile activity must validate list, input, and send controls before wiring listeners." >&2
  exit 1
fi

for delivery_contract in \
  "WearMessage.isWearMessagePath(messageEvent.getPath())" \
  "WearMessage.isValidPayload(messageEvent.getData())" \
  "startWearActivity(WearMessage.decode(messageEvent.getData()))" \
  "Intent.FLAG_ACTIVITY_CLEAR_TOP" \
  "Intent.FLAG_ACTIVITY_SINGLE_TOP" \
  "intent.putExtra(WearMessage.EXTRA_MESSAGE, message)"; do
  if ! grep -Fq "$delivery_contract" "$WEAR_SERVICE"; then
    printf '%s\n' "Missing service-owned Wear message delivery contract: $delivery_contract" >&2
    exit 1
  fi
done

for activity_contract in \
  "protected void onNewIntent(Intent intent)" \
  "intent.hasExtra(WearMessage.EXTRA_MESSAGE)" \
  "String message = intent.getStringExtra(WearMessage.EXTRA_MESSAGE)" \
  "intent.removeExtra(WearMessage.EXTRA_MESSAGE)" \
  "WearMessage.isValidMessageText(message)" \
  "addWearMessage(message)" \
  "private void addWearMessage(String text)" \
  "if (mAdapter == null)"; do
  if ! grep -Fq "$activity_contract" "$WEAR_ACTIVITY"; then
    printf '%s\n' "Missing Wear activity intent-delivery contract: $activity_contract" >&2
    exit 1
  fi
done

if grep -Eq 'MessageApi\.MessageListener|Wearable\.MessageApi\.addListener|onMessageReceived\(' "$WEAR_ACTIVITY"; then
  printf '%s\n' "Wear activity must not restore listener-registration timing dependence." >&2
  exit 1
fi

if ! grep -Fq "private boolean initViews()" "$WEAR_ACTIVITY"; then
  printf '%s\n' "Wear startup view binding must report whether required views are available." >&2
  exit 1
fi

if ! grep -Fq "if( !initViews() )" "$WEAR_ACTIVITY"; then
  printf '%s\n' "Wear activity must stop before connecting when startup views are unavailable." >&2
  exit 1
fi

if ! grep -Fq "if( mListView == null )" "$WEAR_ACTIVITY"; then
  printf '%s\n' "Wear activity must validate its list view before attaching the adapter." >&2
  exit 1
fi

if ! grep -Fq "WearMessage.isStartActivityPath(messageEvent.getPath())" "$WEAR_SERVICE"; then
  printf '%s\n' "Wear listener must use the WearMessage start path guard." >&2
  exit 1
fi

if ! grep -Fq "if( messageEvent == null )" "$WEAR_SERVICE"; then
  printf '%s\n' "Wear listener service must ignore null message events before path checks." >&2
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
  if ! grep -Fq "static String normalizeText(CharSequence text)" "$message_file"; then
    printf '%s\n' "WearMessage must expose shared text normalization." >&2
    exit 1
  fi
  if ! grep -Fq "text.toString().trim()" "$message_file"; then
    printf '%s\n' "WearMessage text normalization must trim whitespace-only sends." >&2
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
  if ! grep -Fq "MAX_MESSAGE_BYTES = 4096" "$message_file" || \
     ! grep -Fq "static boolean isValidMessageText(String text)" "$message_file"; then
    printf '%s\n' "WearMessage must enforce the shared text payload bound." >&2
    exit 1
  fi
done

if ! grep -Fq "static boolean isValidPayload(byte[] data)" "$WEAR_MESSAGE"; then
  printf '%s\n' "WearMessage must validate incoming Wear payload bytes." >&2
  exit 1
fi

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
  if ! grep -Fq "normalizesBlankMessageTextAsEmpty" "$test_file"; then
    printf '%s\n' "WearMessage tests must cover blank text normalization." >&2
    exit 1
  fi
  if ! grep -Fq "clearsOnlyMatchingCurrentInput" "$test_file"; then
    printf '%s\n' "WearMessage tests must cover matching-input cleanup." >&2
    exit 1
  fi
  if ! grep -Fq "acceptsOnlyBoundedNonBlankMessages" "$test_file"; then
    printf '%s\n' "WearMessage tests must cover UTF-8 message boundaries." >&2
    exit 1
  fi
done


for boundary_contract in \
  "repeat('x', WearMessage.MAX_MESSAGE_BYTES)" \
  "repeat('x', WearMessage.MAX_MESSAGE_BYTES + 1)" \
  "repeat('\\u00e9', WearMessage.MAX_MESSAGE_BYTES / 2)" \
  "repeat('\\u00e9', WearMessage.MAX_MESSAGE_BYTES / 2 + 1)"; do
  for test_file in "$MOBILE_MESSAGE_TEST" "$WEAR_MESSAGE_TEST"; do
    if ! grep -Fq "$boundary_contract" "$test_file"; then
      printf '%s\n' "WearMessage tests must retain exact ASCII and UTF-8 boundary assertion: $boundary_contract" >&2
      exit 1
    fi
  done
done


if ! grep -Fq "acceptsOnlyBoundedNonEmptyPayloads" "$WEAR_MESSAGE_TEST"; then
  printf '%s\n' "Wear tests must cover incoming payload boundaries." >&2
  exit 1
fi

for payload_contract in \
  'new byte[WearMessage.MAX_MESSAGE_BYTES]' \
  'new byte[WearMessage.MAX_MESSAGE_BYTES + 1]'; do
  if ! grep -Fq "$payload_contract" "$WEAR_MESSAGE_TEST"; then
    printf '%s\n' "Wear payload tests must retain exact byte boundary assertion: $payload_contract" >&2
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

if [ ! -f "$ROOT_DIR/Makefile" ]; then
  printf '%s\n' "Makefile is missing." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must run the SDK-free baseline check." >&2
  exit 1
fi

if ! grep -Fq "lint:" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose a lint gate." >&2
  exit 1
fi

if ! grep -Fq "test:" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose a test gate." >&2
  exit 1
fi

if ! grep -Fq "build:" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose a build gate." >&2
  exit 1
fi

if ! grep -Fq "verify: lint test build" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile verify must run lint, test, and build gates." >&2
  exit 1
fi

if ! grep -Fq "mobile sender bounds node lookup and message delivery waits" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document bounded Wear send waits." >&2
  exit 1
fi

if ! grep -Fq "docs/plans/2026-06-12-wear-mobile-send-timeouts.md" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must link the Wear send timeout plan." >&2
  exit 1
fi
printf '%s\n' "Android Wear Message API baseline checks passed."
