#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ROOT_BUILD="$ROOT_DIR/build.gradle"
README_FILE="$ROOT_DIR/README.md"
SECURITY_FILE="$ROOT_DIR/SECURITY.md"
VISION_FILE="$ROOT_DIR/VISION.md"
CHANGES_FILE="$ROOT_DIR/CHANGES.md"
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
MESSAGE_SEND_DEADLINE="$ROOT_DIR/mobile/src/main/java/garethpaul/com/wearer/MessageSendDeadline.java"
MESSAGE_SEND_DEADLINE_HOST_TEST="$ROOT_DIR/scripts/MessageSendDeadlineHostTest.java"
MESSAGE_SEND_DEADLINE_HOST_RUNNER="$ROOT_DIR/scripts/test-wear-message-send-deadline.sh"
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
DELIVERY_RATE_LIMITER="$ROOT_DIR/wear/src/main/java/garethpaul/com/wearer/MessageDeliveryRateLimiter.java"
DELIVERY_RATE_LIMITER_TEST="$ROOT_DIR/wear/src/test/java/garethpaul/com/wearer/MessageDeliveryRateLimiterTest.java"
DELIVERY_RATE_HOST_TEST="$ROOT_DIR/scripts/MessageDeliveryRateLimiterHostTest.java"
DELIVERY_RATE_HOST_RUNNER="$ROOT_DIR/scripts/test-wear-delivery-rate-limiter.sh"
DELIVERY_GATE="$ROOT_DIR/wear/src/main/java/garethpaul/com/wearer/MessageDeliveryGate.java"
DELIVERY_GATE_TEST="$ROOT_DIR/wear/src/test/java/garethpaul/com/wearer/MessageDeliveryGateTest.java"
DELIVERY_GATE_HOST_TEST="$ROOT_DIR/scripts/MessageDeliveryGateHostTest.java"
DELIVERY_GATE_HOST_RUNNER="$ROOT_DIR/scripts/test-wear-delivery-gate.sh"
DELIVERY_GATE_MUTATION_RUNNER="$ROOT_DIR/scripts/test-wear-delivery-gate-mutations.sh"
PATH_HOST_TEST="$ROOT_DIR/scripts/WearMessagePathHostTest.java"
PATH_HOST_RUNNER="$ROOT_DIR/scripts/test-wear-message-paths.sh"
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"
CODEOWNERS="$ROOT_DIR/.github/CODEOWNERS"
SEND_TIMEOUT_PLAN="$ROOT_DIR/docs/plans/2026-06-12-wear-mobile-send-timeouts.md"
SHARED_SEND_DEADLINE_PLAN="$ROOT_DIR/docs/plans/2026-06-26-wear-shared-message-send-deadline.md"
HISTORY_LIMIT_PLAN="$ROOT_DIR/docs/plans/2026-06-12-wear-message-history-limit.md"
LISTENER_EXPORT_PLAN="$ROOT_DIR/docs/plans/2026-06-12-wear-listener-export-contract.md"
WRAPPER_PLAN="$ROOT_DIR/docs/plans/2026-06-12-gradle-wrapper-verification.md"
LISTENER_REPLAY_PLAN="$ROOT_DIR/docs/plans/2026-06-13-wear-listener-replay-guard.md"
STRICT_UTF8_PLAN="$ROOT_DIR/docs/plans/2026-06-13-wear-strict-utf8-payload.md"
SINGLE_PASS_PAYLOAD_PLAN="$ROOT_DIR/docs/plans/2026-06-13-wear-single-pass-payload-decode.md"
LISTENER_SEMANTIC_PAYLOAD_PLAN="$ROOT_DIR/docs/plans/2026-06-13-wear-listener-semantic-payload.md"
CANONICAL_PATH_PLAN="$ROOT_DIR/docs/plans/2026-06-14-canonical-wear-message-paths.md"
LISTENER_LAUNCH_FAILURE_PLAN="$ROOT_DIR/docs/plans/2026-06-14-wear-listener-launch-failure-isolation.md"
LAUNCH_FAILURE_REPLAY_PLAN="$ROOT_DIR/docs/plans/2026-06-14-wear-launch-failure-replay-rollback.md"
PNG_CRUNCHER_PLAN="$ROOT_DIR/docs/plans/2026-06-14-legacy-png-cruncher-stability.md"
DEVICE_VERIFICATION_PLAN="$ROOT_DIR/docs/plans/2026-06-14-android-wearmessageapi-device-verification-checklist.md"
DEVICE_VERIFICATION="$ROOT_DIR/DEVICE_VERIFICATION.md"
MOBILE_LAUNCHER_EXPORT_PLAN="$ROOT_DIR/docs/plans/2026-06-15-wear-mobile-explicit-launcher-export.md"
FAILURE_LISTENER_TEARDOWN_PLAN="$ROOT_DIR/docs/plans/2026-06-16-wear-mobile-failure-listener-teardown.md"
CALLBACK_LIVENESS_PLAN="$ROOT_DIR/docs/plans/2026-06-16-wear-mobile-callback-liveness.md"
DELIVERY_RATE_LIMIT_PLAN="$ROOT_DIR/docs/plans/2026-06-17-wear-listener-launch-rate-limit.md"
PAIRING_PREREQUISITES_PLAN="$ROOT_DIR/docs/plans/2026-06-25-wear-pairing-prerequisites.md"

require_sha256() {
  file=$1
  expected=$2
  message=$3

  if [ "$(sha256sum "$file" | awk '{print $1}')" != "$expected" ]; then
    printf '%s\n' "$message" >&2
    exit 1
  fi
}

expected_wrapper_properties() {
  cat <<'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionSha256Sum=1d7c28b3731906fd1b2955946c1d052303881585fc14baedd675e4cf2bc1ecab
distributionUrl=https\://services.gradle.org/distributions/gradle-2.2.1-all.zip
networkTimeout=10000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF
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

if [ ! -x "$GRADLEW" ] || [ ! -f "$GRADLEW_BAT" ] || \
   [ ! -f "$WRAPPER_JAR" ] || [ ! -f "$WRAPPER_PROPERTIES" ]; then
  printf '%s\n' "Generated Gradle wrapper files must be present and gradlew must be executable." >&2
  exit 1
fi

if [ "$(cat "$WRAPPER_PROPERTIES")" != "$(expected_wrapper_properties)" ]; then
  printf '%s\n' "Gradle wrapper properties must retain the reviewed Gradle 2.2.1 URL and checksum." >&2
  exit 1
fi

require_sha256 "$GRADLEW" "b187b4c52e749f5760afdd6fadc31b2a98ad35fb249bf0dff03b72650f320409" \
  "The Unix Gradle wrapper must match the recorded trusted hash."
require_sha256 "$GRADLEW_BAT" "94102713eb8fb22d032397924c0f38ab2da783ba60d07054339f1190a0c4e2cd" \
  "The Windows Gradle wrapper must match the recorded trusted hash."
require_sha256 "$WRAPPER_JAR" "7d3a4ac4de1c32b59bc6a4eb8ecb8e612ccd0cf1ae1e99f66902da64df296172" \
  "The Gradle wrapper JAR must match Gradle's published 8.14.5 wrapper checksum."
require_sha256 "$WRAPPER_PROPERTIES" "42874592f15508aa0a9135568ad3f9705b5f35bf987591bc73dd428f2250de5d" \
  "The Gradle wrapper properties must match the reviewed URL and checksum contract."

if ! grep -Fq "Gradle start up script for POSIX generated by Gradle." "$GRADLEW" || \
   ! grep -Fq "Gradle startup script for Windows" "$GRADLEW_BAT"; then
  printf '%s\n' "Gradle wrapper launchers must retain generated provenance markers." >&2
  exit 1
fi

if [ ! -f "$WRAPPER_PLAN" ] || \
   ! grep -Fq "status: completed" "$WRAPPER_PLAN" || \
   ! grep -Fq "fresh temporary Gradle user home" "$WRAPPER_PLAN" || \
   ! grep -Fq "incorrect checksum was rejected" "$WRAPPER_PLAN" || \
   ! grep -Fq 'SDK-backed `make check` passed' "$WRAPPER_PLAN" || \
   ! grep -Fq "external working directory" "$WRAPPER_PLAN" || \
   ! grep -Fq "hostile mutations rejected" "$WRAPPER_PLAN"; then
  printf '%s\n' "Gradle wrapper plan must record completed local verification evidence." >&2
  exit 1
fi

if ! grep -Fq "distributionSha256Sum" "$README_FILE" || \
   ! grep -Fq "verified-gradle.sh" "$README_FILE" || \
   ! grep -Fq "generated Gradle 8.14.5 bootstrap" "$SECURITY_FILE" || \
   ! grep -Fq "checksum-verified direct wrapper" "$VISION_FILE" || \
   ! grep -Fq "direct Gradle wrapper" "$CHANGES_FILE"; then
  printf '%s\n' "Documentation must describe both authenticated Gradle launch paths." >&2
  exit 1
fi
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
  'override ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' \
  'ANDROID_HOME ?=' \
  'ANDROID_SDK_ROOT ?=' \
  'ANDROID_SDK := $(if $(ANDROID_HOME),$(ANDROID_HOME),$(ANDROID_SDK_ROOT))' \
  'GRADLE ?= $(ROOT)scripts/verified-gradle.sh'; do
  if ! grep -Fxq "$make_contract" "$ROOT_DIR/Makefile"; then
    printf '%s\n' "Makefile must keep contract: $make_contract" >&2
    exit 1
  fi
done
if [ "$(grep -Fc '$(ROOT)scripts/check-baseline.sh' "$ROOT_DIR/Makefile")" -ne 1 ]; then
  printf '%s\n' "Baseline verification must use the protected root." >&2; exit 1
fi
for gradle_contract in \
  'cd $(ROOT) && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" $(GRADLE) lint --no-daemon; \' \
  'cd $(ROOT) && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" $(GRADLE) test --no-daemon; \' \
  'cd $(ROOT) && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" $(GRADLE) assembleDebug --no-daemon; \' ; do
  if [ "$(grep -Fc "$gradle_contract" "$ROOT_DIR/Makefile")" -ne 1 ]; then
    printf '%s\n' "Makefile must keep complete rooted Gradle contract: $gradle_contract" >&2; exit 1
  fi
done
if ! grep -Fxq "Status: Completed" "$ROOT_DIR/docs/plans/2026-06-14-wear-message-make-root-override-protection.md"; then
  printf '%s\n' "Wear Message Make root plan must record completed status." >&2; exit 1
fi

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
  if [ "$(grep -Fc 'cruncherEnabled = false' "$build_file")" -ne 1 ]; then
    printf '%s\n' "Both modules must disable the unstable legacy PNG cruncher exactly once." >&2
    exit 1
  fi
  if [ "$(grep -Fc 'useNewCruncher = false' "$build_file")" -ne 1 ]; then
    printf '%s\n' "Both modules must disable AGP 1.1.0's queued PNG implementation exactly once." >&2
    exit 1
  fi
done

if [ ! -f "$PNG_CRUNCHER_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$PNG_CRUNCHER_PLAN" || \
   ! grep -Fq "AGP 1.1.0" "$PNG_CRUNCHER_PLAN" || \
   ! grep -Fq "QueuedCruncher" "$PNG_CRUNCHER_PLAN" || \
   ! grep -Fq "SDK-backed make check" "$PNG_CRUNCHER_PLAN" || \
   ! grep -Fq "external working directory" "$PNG_CRUNCHER_PLAN" || \
   ! grep -Fq "hostile mutations" "$PNG_CRUNCHER_PLAN" || \
   ! grep -Fq "two application modules disable both PNG crunching and AGP 1.1.0's queued PNG" "$README_FILE"; then
  printf '%s\n' "Legacy PNG cruncher plan must record completed verification evidence." >&2
  exit 1
fi

for required_device_path in "$ROOT_DIR/DEVICE_VERIFICATION.md" "$DEVICE_VERIFICATION_PLAN"; do
  if [ ! -f "$required_device_path" ]; then
    printf '%s\n' "Required Wear Message device verification file is missing: ${required_device_path#"$ROOT_DIR/"}" >&2
    exit 1
  fi
done

for device_contract in \
  'commit SHA and pull request' \
  'synthetic payload' \
  'Paired connection' \
  'Mobile to Wear message' \
  'Wear to mobile start' \
  'Canonical `/message` path' \
  'Canonical `/start_activity` path' \
  'Malformed UTF-8' \
  'Blank semantic payload' \
  'Duplicate replay' \
  'Activity-not-found launch' \
  'Security-rejected launch' \
  'Redelivery after launch failure' \
  'Disconnect during send' \
  'Reconnect and retry' \
  'Do not convert `not run` into passing evidence.' \
  'node identifiers, device serials, payload dumps' \
  'every mobile, Wear, Data Layer, and UI row as unexecuted'; do
  if ! grep -Fq "$device_contract" "$ROOT_DIR/DEVICE_VERIFICATION.md"; then
    printf '%s\n' "Wear Message device checklist must keep contract: $device_contract" >&2
    exit 1
  fi
done

if ! grep -Fq 'DEVICE_VERIFICATION.md' "$README_FILE" || \
   ! grep -Fq 'explicit unexecuted rows' "$README_FILE" || \
   ! grep -Fq 'Wear Message device verification matrix' "$VISION_FILE" || \
   ! grep -Fq 'every runtime row explicitly unexecuted' "$CHANGES_FILE"; then
  printf '%s\n' 'Repository guidance must document the unexecuted Wear Message device matrix.' >&2
  exit 1
fi

for device_plan_contract in \
  'Status: Completed' \
  'make check' \
  'hostile mutations' \
  'No mobile or Wear emulator, paired device, Wear Data Layer connection, Play services runtime, or live UI scenario was executed'; do
  if ! grep -Fq "$device_plan_contract" "$DEVICE_VERIFICATION_PLAN"; then
    printf '%s\n' "Wear Message device plan must keep completion evidence: $device_plan_contract" >&2
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

mobile_exported_count=$(awk '
  {
    line = $0
    while (match(line, /android:exported[[:space:]]*=/)) {
      count++
      line = substr(line, RSTART + RLENGTH)
    }
  }
  END { print count + 0 }
' "$MOBILE_MANIFEST")
if [ "$mobile_exported_count" -ne 1 ]; then
  printf '%s\n' "Mobile manifest must contain exactly one explicit exported declaration." >&2
  exit 1
fi

mobile_launcher_block=$(awk '
  /^[[:space:]]*<activity([[:space:]]|$)/ {
    capture = 1
    block = ""
  }
  capture {
    block = block $0 "\n"
  }
  capture && /<\/activity>/ {
    if (index(block, "android:name=\".MainActivity\"") != 0) {
      matched++
      selected = block
    }
    capture = 0
  }
  END {
    if (matched != 1) {
      exit 1
    }
    printf "%s", selected
  }
' "$MOBILE_MANIFEST") || {
  printf '%s\n' "Mobile manifest must keep exactly one named launcher activity block." >&2
  exit 1
}

for mobile_launcher_contract in \
  'android:name=".MainActivity"' \
  'android:exported="true"' \
  'android.intent.action.MAIN' \
  'android.intent.category.LAUNCHER'; do
  if ! printf '%s\n' "$mobile_launcher_block" | grep -Fq -- "$mobile_launcher_contract"; then
    printf '%s\n' "Mobile activity must preserve its explicit launcher boundary: $mobile_launcher_contract" >&2
    exit 1
  fi
done

mobile_launcher_guidance="The mobile explicit launcher export boundary is limited to .MainActivity and preserves its MAIN/LAUNCHER entry point."
for mobile_launcher_document in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq "$mobile_launcher_guidance" "$ROOT_DIR/$mobile_launcher_document"; then
    printf '%s\n' "$mobile_launcher_document must document the mobile launcher export boundary." >&2
    exit 1
  fi
done
for mobile_launcher_plan_contract in \
  "Status: Completed" \
  "make check" \
  "mutations"; do
  if ! grep -Fq "$mobile_launcher_plan_contract" "$MOBILE_LAUNCHER_EXPORT_PLAN"; then
    printf '%s\n' "Mobile launcher export plan must preserve completion evidence: $mobile_launcher_plan_contract" >&2
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

if [ "$(grep -Fc 'android:name=".WearMessageListenerService"' "$WEAR_MANIFEST")" -ne 1 ]; then
  printf '%s\n' "Wear manifest must declare exactly one listener service." >&2
  exit 1
fi
wear_listener_manifest=$(awk '/android:name=".WearMessageListenerService"/ { capture = 1 } capture { print } capture && /<\/service>/ { exit }' "$WEAR_MANIFEST")
if [ "$(printf '%s\n' "$wear_listener_manifest" | grep -Fc 'android:exported="true"')" -ne 1 ]; then
  printf '%s\n' "Wear listener service must state its required exported policy explicitly." >&2
  exit 1
fi
if [ "$(printf '%s\n' "$wear_listener_manifest" | grep -c '<action ' || true)" -ne 1 ] ||
   ! printf '%s\n' "$wear_listener_manifest" | grep -Fq '<action android:name="com.google.android.gms.wearable.BIND_LISTENER" />'; then
  printf '%s\n' "Exported Wear listener must keep exactly the required BIND_LISTENER action." >&2
  exit 1
fi

if [ ! -f "$LISTENER_EXPORT_PLAN" ] ||
   ! grep -Fq "Status: Completed" "$LISTENER_EXPORT_PLAN" ||
   ! grep -Fq "CodeQL alert 1" "$LISTENER_EXPORT_PLAN" ||
   ! grep -Fq "fresh external clone" "$LISTENER_EXPORT_PLAN" ||
   ! grep -Fq "lint with zero issues" "$LISTENER_EXPORT_PLAN" ||
   ! grep -Fq "All 13 focused service declaration" "$LISTENER_EXPORT_PLAN" ||
   ! grep -Fq "ac0428a132e59fb001b32043364f1e16b668d486" "$LISTENER_EXPORT_PLAN" ||
   ! grep -Fq 'pull-request run `27404104907` and CodeQL run `27404102731`' "$LISTENER_EXPORT_PLAN" ||
   ! grep -Fq "zero open code-scanning alerts" "$LISTENER_EXPORT_PLAN"; then
  printf '%s\n' "Wear listener export plan must record completed hosted verification." >&2
  exit 1
fi
if ! grep -Fq "explicitly exported only" "$README_FILE" ||
   ! grep -Fq "single legacy" "$ROOT_DIR/SECURITY.md" ||
   ! grep -Fq "listener service export policy explicit" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Documentation must record the explicit Wear listener trust boundary." >&2
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

if [ "$(grep -Fc "unregisterConnectionCallbacks( this )" "$MOBILE_ACTIVITY" || true)" -ne 1 ] || \
   [ "$(grep -Fc "unregisterConnectionFailedListener( this )" "$MOBILE_ACTIVITY" || true)" -ne 1 ]; then
  printf '%s\n' "Mobile GoogleApiClient callback registrations must each be released once." >&2
  exit 1
fi

MOBILE_DESTROY=$(sed -n '/protected void onDestroy()/,/super.onDestroy();/p' "$MOBILE_ACTIVITY")
callbacks_line=$(printf '%s\n' "$MOBILE_DESTROY" | grep -nF "unregisterConnectionCallbacks( this )" | cut -d: -f1)
failure_listener_line=$(printf '%s\n' "$MOBILE_DESTROY" | grep -nF "unregisterConnectionFailedListener( this )" | cut -d: -f1)
disconnect_guard_line=$(printf '%s\n' "$MOBILE_DESTROY" | grep -nF "mApiClient.isConnected() || mApiClient.isConnecting()" | cut -d: -f1)
disconnect_line=$(printf '%s\n' "$MOBILE_DESTROY" | grep -nF "mApiClient.disconnect();" | cut -d: -f1)
super_destroy_line=$(printf '%s\n' "$MOBILE_DESTROY" | grep -nF "super.onDestroy();" | cut -d: -f1)
if [ -z "$callbacks_line" ] || [ -z "$failure_listener_line" ] || \
   [ -z "$disconnect_guard_line" ] || [ -z "$disconnect_line" ] || \
   [ -z "$super_destroy_line" ] || \
   [ "$callbacks_line" -ge "$failure_listener_line" ] || \
   [ "$failure_listener_line" -ge "$disconnect_guard_line" ] || \
   [ "$disconnect_guard_line" -ge "$disconnect_line" ] || \
   [ "$disconnect_line" -ge "$super_destroy_line" ]; then
  printf '%s\n' "Mobile GoogleApiClient listeners must be released before disconnect and activity teardown." >&2
  exit 1
fi

for failure_listener_plan_contract in \
  "Status: Completed" \
  "unregisterConnectionFailedListener" \
  "make check" \
  "mutations"; do
  if ! grep -Fq "$failure_listener_plan_contract" "$FAILURE_LISTENER_TEARDOWN_PLAN"; then
    printf '%s\n' "Wear failure-listener teardown plan must record completed verification: $failure_listener_plan_contract" >&2
    exit 1
  fi
done

for failure_listener_doc in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq "The handset releases both Google API connection callback registrations before disconnecting during activity teardown." "$ROOT_DIR/$failure_listener_doc"; then
    printf '%s\n' "$failure_listener_doc must document symmetric Google API callback teardown." >&2
    exit 1
  fi
done

assert_callback_liveness() {
  callback_name=$1
  state_assignment=$2
  callback_block=$(awk -v callback_name="$callback_name" '
    $0 ~ "public void " callback_name "\\(" { capture = 1 }
    capture && seen && /^[[:space:]]*@Override/ { exit }
    capture { print; seen = 1 }
  ' "$MOBILE_ACTIVITY")
  callback_compact=$(printf '%s\n' "$callback_block" | tr -d '[:space:]')
  guard='if(isFinishing()||isDestroyed()){return;}'

  if [ -z "$callback_block" ] || \
     [ "$(printf '%s\n' "$callback_block" | grep -Fc "if (isFinishing() || isDestroyed())" || true)" -ne 1 ] || \
     ! printf '%s\n' "$callback_compact" | grep -Fq "${guard}${state_assignment}updateSendButtonState();"; then
    printf '%s\n' "Mobile $callback_name must reject dead activity callbacks before state and UI mutation." >&2
    exit 1
  fi
}

assert_callback_liveness "onConnected" "wearConnected=true;"
assert_callback_liveness "onConnectionSuspended" "wearConnected=false;"
assert_callback_liveness "onConnectionFailed" "wearConnected=false;"

for callback_liveness_doc in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq "The handset ignores queued Google API connection callbacks once its activity is finishing or destroyed." "$ROOT_DIR/$callback_liveness_doc"; then
    printf '%s\n' "$callback_liveness_doc must document callback liveness ownership." >&2
    exit 1
  fi
done

for callback_liveness_plan_contract in \
  "Status: Completed" \
  "make check" \
  "hostile mutations" \
  "late-callback injection"; do
  if ! grep -Fq "$callback_liveness_plan_contract" "$CALLBACK_LIVENESS_PLAN"; then
    printf '%s\n' "Wear callback-liveness plan must record completed verification: $callback_liveness_plan_contract" >&2
    exit 1
  fi
done

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
  "private static final long MESSAGE_OPERATION_TIMEOUT_NANOS" \
  "import java.util.concurrent.TimeUnit;" \
  "TimeUnit.SECONDS.toNanos(5L);" \
  ".await(MESSAGE_OPERATION_TIMEOUT_NANOS, TimeUnit.NANOSECONDS)" \
  "MessageSendDeadline.remainingNanos(" \
  ".await(" \
  "remainingNanos," \
  "TimeUnit.NANOSECONDS);"; do
  if ! grep -Fq "$timeout_contract" "$MOBILE_ACTIVITY"; then
    printf '%s\n' "Mobile Wear operations must keep bounded wait contract: $timeout_contract" >&2
    exit 1
  fi
done

if [ "$(grep -Fc "private static final long MESSAGE_OPERATION_TIMEOUT_NANOS" "$MOBILE_ACTIVITY" || true)" -ne 1 ] || \
   [ "$(grep -Fc "import java.util.concurrent.TimeUnit;" "$MOBILE_ACTIVITY" || true)" -ne 1 ] || \
   [ "$(grep -Ec '\.await[[:space:]]*\(' "$MOBILE_ACTIVITY" || true)" -ne 2 ] || \
   [ "$(grep -Fc "MESSAGE_OPERATION_TIMEOUT_NANOS" "$MOBILE_ACTIVITY" || true)" -ne 3 ] || \
   [ "$(grep -Fc "TimeUnit.NANOSECONDS" "$MOBILE_ACTIVITY" || true)" -ne 2 ] || \
   [ "$(grep -Fc "System.nanoTime()" "$MOBILE_ACTIVITY" || true)" -ne 2 ] || \
   grep -Fq "MESSAGE_OPERATION_TIMEOUT_SECONDS" "$MOBILE_ACTIVITY"; then
  printf '%s\n' "Mobile Wear node lookup and per-node sends must consume one shared deadline." >&2
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

for deadline_path in \
  "$MESSAGE_SEND_DEADLINE" \
  "$MESSAGE_SEND_DEADLINE_HOST_TEST" \
  "$MESSAGE_SEND_DEADLINE_HOST_RUNNER" \
  "$SHARED_SEND_DEADLINE_PLAN"; do
  if [ ! -f "$deadline_path" ]; then
    printf '%s\n' "Shared Wear send deadline artifact is missing: $deadline_path" >&2
    exit 1
  fi
done
if [ ! -x "$MESSAGE_SEND_DEADLINE_HOST_RUNNER" ]; then
  printf '%s\n' "Shared Wear send deadline host runner must remain executable." >&2
  exit 1
fi
for deadline_contract in \
  "static long remainingNanos" \
  "if (timeoutNanos <= 0L)" \
  "if (elapsedNanos >= timeoutNanos)" \
  "return timeoutNanos - elapsedNanos;"; do
  if ! grep -Fq "$deadline_contract" "$MESSAGE_SEND_DEADLINE"; then
    printf '%s\n' "Shared Wear send deadline helper changed: $deadline_contract" >&2
    exit 1
  fi
done
for deadline_test_contract in \
  "preservesFullBudgetAtStart" \
  "subtractsElapsedTimeFromSharedBudget" \
  "expiresAtAndBeyondDeadline" \
  "rejectsNonPositiveTimeouts" \
  "if (expected != actual)"; do
  if ! grep -Fq "$deadline_test_contract" "$MESSAGE_SEND_DEADLINE_HOST_TEST"; then
    printf '%s\n' "Shared Wear send deadline host coverage changed: $deadline_test_contract" >&2
    exit 1
  fi
done
if [ "$(grep -Fc '$(ROOT)scripts/test-wear-message-send-deadline.sh' "$ROOT_DIR/Makefile")" -ne 1 ]; then
  printf '%s\n' "Make test must run the shared Wear send deadline host test exactly once." >&2
  exit 1
fi
if ! grep -Fq "Status: Completed" "$SHARED_SEND_DEADLINE_PLAN" || \
   ! grep -Fq "make check" "$SHARED_SEND_DEADLINE_PLAN" || \
   ! grep -Fq "hostile mutations" "$SHARED_SEND_DEADLINE_PLAN"; then
  printf '%s\n' "Shared Wear send deadline plan must record completed verification." >&2
  exit 1
fi
for deadline_doc in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq "Wear node lookup and per-node sends consume one shared five-second deadline" "$ROOT_DIR/$deadline_doc"; then
    printf '%s\n' "$deadline_doc must document the shared Wear send deadline." >&2
    exit 1
  fi
done

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
  "byte[] payload = messageEvent.getData();" \
  "String message = WearMessage.decodeValidPayload(payload);" \
  "boolean validMessage = WearMessage.isValidMessageText(message);" \
  "if (validMessage)" \
  "deliverOnce(messageEvent, message);" \
  "else if (!validMessage)" \
  "Intent.FLAG_ACTIVITY_CLEAR_TOP" \
  "Intent.FLAG_ACTIVITY_SINGLE_TOP" \
  "intent.putExtra(WearMessage.EXTRA_MESSAGE, message)"; do
  if ! grep -Fq "$delivery_contract" "$WEAR_SERVICE"; then
    printf '%s\n' "Missing service-owned Wear message delivery contract: $delivery_contract" >&2
    exit 1
  fi
done
if [ "$(grep -Fc "messageEvent.getData()" "$WEAR_SERVICE")" -ne 1 ] || \
   [ "$(grep -Fc "WearMessage.decodeValidPayload(" "$WEAR_SERVICE")" -ne 1 ] || \
   grep -Fq "WearMessage.decode(messageEvent.getData())" "$WEAR_SERVICE" || \
   grep -Fq "WearMessage.isValidPayload(messageEvent.getData())" "$WEAR_SERVICE"; then
  printf '%s\n' "Wear listener must fetch and strictly decode each message payload exactly once." >&2
  exit 1
fi

WEAR_SERVICE_COMPACT=$(tr -d '[:space:]' < "$WEAR_SERVICE")
if ! printf '%s\n' "$WEAR_SERVICE_COMPACT" | grep -Fq \
    'byte[]payload=messageEvent.getData();Stringmessage=WearMessage.decodeValidPayload(payload);booleanvalidMessage=WearMessage.isValidMessageText(message);if(validMessage){deliverOnce(messageEvent,message);}elseif(!validMessage){super.onMessageReceived(messageEvent);}'; then
  printf '%s\n' "Wear listener must validate decoded message semantics before replay recording and activity launch." >&2
  exit 1
fi

if [ "$(grep -Fc "WearMessage.isValidMessageText(message)" "$WEAR_SERVICE")" -ne 1 ]; then
  printf '%s\n' "Wear listener must evaluate decoded message semantics exactly once." >&2
  exit 1
fi

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
  if ! grep -Fq "path != null && START_ACTIVITY.equals(path)" "$message_file"; then
    printf '%s\n' "WearMessage must require the canonical startup path." >&2
    exit 1
  fi
  if ! grep -Fq "path != null && WEAR_MESSAGE_PATH.equals(path)" "$message_file"; then
    printf '%s\n' "WearMessage must require the canonical text message path." >&2
    exit 1
  fi
  if grep -Fq "equalsIgnoreCase(path)" "$message_file"; then
    printf '%s\n' "WearMessage protocol paths must not accept case variants." >&2
    exit 1
  fi
  if ! grep -Fq "MAX_MESSAGE_BYTES = 4096" "$message_file" || \
     ! grep -Fq "static boolean isValidMessageText(String text)" "$message_file"; then
    printf '%s\n' "WearMessage must enforce the shared text payload bound." >&2
    exit 1
  fi
  for strict_utf8_contract in \
    "static boolean isValidPayload(byte[] data)" \
    "return decodeValidPayload(data) != null;" \
    "static String decodeValidPayload(byte[] data)" \
    "MESSAGE_CHARSET.newDecoder()" \
    ".onMalformedInput(CodingErrorAction.REPORT)" \
    ".onUnmappableCharacter(CodingErrorAction.REPORT)" \
    ".decode(ByteBuffer.wrap(data))" \
    ".toString();" \
    "catch (CharacterCodingException exception)"; do
    if ! grep -Fq "$strict_utf8_contract" "$message_file"; then
      printf '%s\n' "WearMessage must reject malformed UTF-8 payloads: $strict_utf8_contract" >&2
      exit 1
    fi
  done
  if ! grep -Eq '^[[:space:]]*if \(data == null \|\| data\.length == 0 \|\| data\.length > MAX_MESSAGE_BYTES\) \{[[:space:]]*$' \
      "$message_file"; then
    printf '%s\n' "WearMessage must preserve the exact nonempty 4096-byte payload bound." >&2
    exit 1
  fi
  if grep -Eq 'CodingErrorAction\.(REPLACE|IGNORE)' "$message_file"; then
    printf '%s\n' "WearMessage payload validation must report encoding errors." >&2
    exit 1
  fi
  if ! grep -Eq '^[[:space:]]*static final int MAX_HISTORY_ENTRIES = 100;[[:space:]]*$' "$message_file" || \
     ! grep -Fq "static boolean shouldRemoveOldestHistoryEntry(int currentEntryCount)" "$message_file" || \
     ! grep -Fq "return currentEntryCount >= MAX_HISTORY_ENTRIES;" "$message_file"; then
    printf '%s\n' "WearMessage must enforce the shared visible history bound." >&2
    exit 1
  fi
done

mobile_strict_payload=$(sed -n \
  '/static boolean isValidPayload(byte\[\] data)/,/static boolean shouldClearInput/p' \
  "$MOBILE_MESSAGE")
wear_strict_payload=$(sed -n \
  '/static boolean isValidPayload(byte\[\] data)/,/static boolean shouldClearInput/p' \
  "$WEAR_MESSAGE")
if [ "$mobile_strict_payload" != "$wear_strict_payload" ]; then
  printf '%s\n' "Mobile and Wear strict payload helper implementations must remain aligned." >&2
  exit 1
fi

for strict_decode_test in "$MOBILE_MESSAGE_TEST" "$WEAR_MESSAGE_TEST"; do
  for strict_decode_contract in \
    "public void decodesOnlyBoundedStrictUtf8Payloads()" \
    'assertEquals("hello", WearMessage.decodeValidPayload("hello".getBytes(UTF_8)))' \
    "new byte[WearMessage.MAX_MESSAGE_BYTES]).length()" \
    "assertNull(WearMessage.decodeValidPayload(null))" \
    "new byte[] { (byte) 0xe2, (byte) 0x82 }" \
    "new byte[WearMessage.MAX_MESSAGE_BYTES + 1]"; do
    if ! grep -Fq "$strict_decode_contract" "$strict_decode_test"; then
      printf '%s\n' "Strict payload decode regression test is missing: $strict_decode_contract" >&2
      exit 1
    fi
  done
  if ! grep -Fq 'assertFalse(WearMessage.isValidMessageText("   "))' "$strict_decode_test"; then
    printf '%s\n' "Both modules must preserve the semantically blank message regression." >&2
    exit 1
  fi
done

if [ ! -f "$LISTENER_SEMANTIC_PAYLOAD_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$LISTENER_SEMANTIC_PAYLOAD_PLAN" || \
   ! grep -Fq "make check" "$LISTENER_SEMANTIC_PAYLOAD_PLAN" || \
   ! grep -Fq "hostile mutations" "$LISTENER_SEMANTIC_PAYLOAD_PLAN"; then
  printf '%s\n' "Wear listener semantic payload plan must record completed verification." >&2
  exit 1
fi

for semantic_payload_doc in "$ROOT_DIR/AGENTS.md" "$README_FILE" "$SECURITY_FILE" \
    "$VISION_FILE" "$CHANGES_FILE"; do
  if ! grep -Fq "Wear listener rejects semantically blank payloads before replay recording or activity launch." "$semantic_payload_doc"; then
    printf '%s\n' "$semantic_payload_doc must document listener semantic payload validation." >&2
    exit 1
  fi
done

if [ ! -f "$SINGLE_PASS_PAYLOAD_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$SINGLE_PASS_PAYLOAD_PLAN" || \
   ! grep -Fq "Verification: Completed" "$SINGLE_PASS_PAYLOAD_PLAN" || \
   ! grep -Fq "Nine focused hostile mutations" "$SINGLE_PASS_PAYLOAD_PLAN" || \
   ! grep -Fq "make check" "$SINGLE_PASS_PAYLOAD_PLAN"; then
  printf '%s\n' "Single-pass Wear payload plan must record completed verification." >&2
  exit 1
fi

for single_pass_doc in "$ROOT_DIR/AGENTS.md" "$README_FILE" "$SECURITY_FILE" \
  "$VISION_FILE" "$CHANGES_FILE"; do
  if ! tr '\n' ' ' < "$single_pass_doc" | tr -s '[:space:]' ' ' | \
      grep -Fiq "single-pass strict payload decode"; then
    printf '%s\n' "$single_pass_doc must document single-pass strict payload decode." >&2
    exit 1
  fi
done

for activity_file in "$MOBILE_ACTIVITY" "$WEAR_ACTIVITY"; do
  if ! grep -Fq "while (WearMessage.shouldRemoveOldestHistoryEntry(mAdapter.getCount()))" "$activity_file" || \
     ! grep -Fq "mAdapter.remove(mAdapter.getItem(0));" "$activity_file"; then
    printf '%s\n' "Activities must evict oldest messages before appending at the history limit." >&2
    exit 1
  fi
done

if [ ! -f "$HISTORY_LIMIT_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$HISTORY_LIMIT_PLAN" || \
   ! grep -Fq "make check" "$HISTORY_LIMIT_PLAN" || \
   ! grep -Fq "external working directory" "$HISTORY_LIMIT_PLAN"; then
  printf '%s\n' "Wear message history limit plan must record completed verification." >&2
  exit 1
fi

if ! grep -Fq "visible message histories retain only the newest 100 entries" "$README_FILE" || \
   ! grep -Fq "2026-06-12-wear-message-history-limit.md" "$README_FILE"; then
  printf '%s\n' "README must document the visible message history bound and plan." >&2
  exit 1
fi

if ! grep -Fq "static boolean isValidPayload(byte[] data)" "$WEAR_MESSAGE"; then
  printf '%s\n' "WearMessage must validate incoming Wear payload bytes." >&2
  exit 1
fi

for replay_contract in \
  "static final int MAX_RECENT_MESSAGE_IDS = 100;" \
  "static final class RecentMessageIds" \
  "synchronized boolean record(String sourceNodeId, int requestId)" \
  "private final LinkedHashSet<String> identities" \
  "if (!identities.add(identity))" \
  "while (identities.size() > maxEntries)"; do
  if ! grep -Fq "$replay_contract" "$WEAR_MESSAGE"; then
    printf '%s\n' "WearMessage must keep the bounded listener replay contract: $replay_contract" >&2
    exit 1
  fi
done

for listener_replay_contract in \
  "new MessageDeliveryGate(" \
  "String sourceNodeId = messageEvent.getSourceNodeId();" \
  "int requestId = messageEvent.getRequestId();"; do
  if ! grep -Fq "$listener_replay_contract" "$WEAR_SERVICE"; then
    printf '%s\n' "Wear listener must enforce recent source/request identities." >&2
    exit 1
  fi
done

for test_file in "$MOBILE_MESSAGE_TEST" "$WEAR_MESSAGE_TEST"; do
  if ! grep -Fq "recognizesOnlyCanonicalStartActivityPath" "$test_file" || \
     ! grep -Fq 'assertFalse(WearMessage.isStartActivityPath("/START_ACTIVITY"))' "$test_file"; then
    printf '%s\n' "WearMessage tests must reject noncanonical start paths." >&2
    exit 1
  fi
  if ! grep -Fq "recognizesOnlyCanonicalWearMessagePath" "$test_file" || \
     ! grep -Fq 'assertFalse(WearMessage.isWearMessagePath("/MESSAGE"))' "$test_file"; then
    printf '%s\n' "WearMessage tests must reject noncanonical text paths." >&2
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
  if ! grep -Fq "removesOldestEntryAtHistoryLimit" "$test_file" || \
     ! grep -Fq "WearMessage.MAX_HISTORY_ENTRIES - 1" "$test_file" || \
     ! grep -Fq "WearMessage.MAX_HISTORY_ENTRIES + 1" "$test_file"; then
    printf '%s\n' "WearMessage tests must cover visible history boundaries." >&2
    exit 1
  fi
done

for path_host_contract in \
  'WearMessage.isStartActivityPath("/start_activity")' \
  'WearMessage.isStartActivityPath("/START_ACTIVITY")' \
  'WearMessage.isStartActivityPath("/start_activity/")' \
  'WearMessage.isStartActivityPath(null)' \
  'WearMessage.isWearMessagePath("/message")' \
  'WearMessage.isWearMessagePath("/MESSAGE")' \
  'WearMessage.isWearMessagePath("/message/")' \
  'WearMessage.isWearMessagePath(null)' \
  'if (cases != 8)' \
  'Canonical Wear message path tests passed:'; do
  if ! grep -Fq "$path_host_contract" "$PATH_HOST_TEST"; then
    printf '%s\n' "Portable Wear path coverage is missing: $path_host_contract" >&2
    exit 1
  fi
done
for path_runner_contract in \
  'for module in mobile wear; do' \
  '"$ROOT_DIR/$module/src/main/java/garethpaul/com/wearer/WearMessage.java"' \
  '"$ROOT_DIR/scripts/WearMessagePathHostTest.java"' \
  'if [ -d "$OUTPUT_DIR" ]; then' \
  'rm -rf -- "$OUTPUT_DIR"' \
  'trap cleanup EXIT' \
  'trap '\''cleanup; exit 1'\'' HUP INT TERM'; do
  if ! grep -Fq "$path_runner_contract" "$PATH_HOST_RUNNER"; then
    printf '%s\n' "Portable Wear path runner changed: $path_runner_contract" >&2
    exit 1
  fi
done
if [ "$(grep -Fc '$(ROOT)scripts/test-wear-message-paths.sh' "$ROOT_DIR/Makefile")" -ne 1 ]; then
  printf '%s\n' "Make test must run portable Wear path tests exactly once." >&2
  exit 1
fi
if [ "$(grep -Fc '$(ROOT)scripts/test-wear-delivery-rate-limiter.sh' "$ROOT_DIR/Makefile")" -ne 1 ]; then
  printf '%s\n' "Make test must run the Wear delivery rate limiter tests exactly once." >&2
  exit 1
fi
if [ "$(grep -Fc '$(ROOT)scripts/test-wear-delivery-gate.sh' "$ROOT_DIR/Makefile")" -ne 1 ] || \
   [ "$(grep -Fc '$(ROOT)scripts/test-wear-delivery-gate-mutations.sh' "$ROOT_DIR/Makefile")" -ne 1 ]; then
  printf '%s\n' "Make test must run the Wear delivery gate and hostile mutation tests exactly once." >&2
  exit 1
fi
if [ ! -f "$CANONICAL_PATH_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$CANONICAL_PATH_PLAN" || \
   ! grep -Fq "make check" "$CANONICAL_PATH_PLAN" || \
   ! grep -Fq "hostile mutations" "$CANONICAL_PATH_PLAN"; then
  printf '%s\n' "Canonical Wear path plan must record completed verification." >&2
  exit 1
fi
if ! tr '\n' ' ' < "$ROOT_DIR/AGENTS.md" | tr -s '[:space:]' ' ' | grep -Fq 'exact canonical `/start_activity` and `/message` identifiers' || \
   ! tr '\n' ' ' < "$README_FILE" | tr -s '[:space:]' ' ' | grep -Fq 'exact canonical identifiers in both modules' || \
   ! grep -Fq 'exact canonical transport paths' "$SECURITY_FILE" || \
   ! grep -Fq 'message path matching null-safe and exact across modules' "$VISION_FILE" || \
   ! grep -Fq 'exact canonical paths' "$CHANGES_FILE"; then
  printf '%s\n' "Canonical Wear path documentation is incomplete." >&2
  exit 1
fi

listener_launch_contract=$(tr '\n' ' ' < "$WEAR_SERVICE" | tr -s '[:space:]' ' ')
if ! grep -Fq 'import android.content.ActivityNotFoundException;' "$WEAR_SERVICE" || \
   ! printf '%s\n' "$listener_launch_contract" | grep -Fq 'try { startActivity(intent); return true; } catch (ActivityNotFoundException ignored) { return false; } catch (SecurityException ignored) { return false; }' || \
   grep -Fq 'catch (RuntimeException' "$WEAR_SERVICE"; then
  printf '%s\n' "Wear listener must isolate only documented activity-launch failures." >&2
  exit 1
fi

for rollback_contract in \
  'synchronized boolean forget(String sourceNodeId, int requestId)' \
  'return identities.remove(normalizedSourceNodeId + "\n" + requestId);' \
  'private void deliverOnce(MessageEvent messageEvent, String message)' \
  'sourceNodeId, messageEvent.getPath(), requestId, acceptedAtMillis)' \
  'if (startWearActivity(message))' \
  'deliveryGate.release(reservation);' \
  'deliverOnce(messageEvent, null);' \
  'deliverOnce(messageEvent, message);'; do
  if ! grep -Fq "$rollback_contract" "$WEAR_MESSAGE" "$WEAR_SERVICE" "$DELIVERY_GATE"; then
    printf '%s\n' "Wear listener launch failure replay rollback changed: $rollback_contract" >&2
    exit 1
  fi
done
for rollback_test in \
  'failedDeliveryReleasesOnlyMatchingMessageIdentity' \
  'failedDeliveryRejectsMissingMessageSourceNode'; do
  if ! grep -Fq "$rollback_test" "$WEAR_MESSAGE_TEST"; then
    printf '%s\n' "WearMessage tests must cover launch failure replay rollback: $rollback_test" >&2
    exit 1
  fi
done
if [ ! -f "$LAUNCH_FAILURE_REPLAY_PLAN" ] || \
   ! grep -Fq 'Status: Completed' "$LAUNCH_FAILURE_REPLAY_PLAN" || \
   ! grep -Fq 'make check' "$LAUNCH_FAILURE_REPLAY_PLAN" || \
   ! grep -Fq 'hostile mutations' "$LAUNCH_FAILURE_REPLAY_PLAN"; then
  printf '%s\n' "Wear launch failure replay plan must record completed verification." >&2
  exit 1
fi
if ! tr '\n' ' ' < "$ROOT_DIR/AGENTS.md" | tr -s '[:space:]' ' ' | grep -Fq 'release only their matching replay reservation' || \
   ! grep -Fq 'release only the matching source/request replay' "$README_FILE" || \
   ! grep -Fq 'release only the matching replay reservation' "$SECURITY_FILE" || \
   ! grep -Fq 'exact replay-state rollback' "$VISION_FILE" || \
   ! grep -Fq 'Released the matching replay reservation' "$CHANGES_FILE"; then
  printf '%s\n' "Wear launch failure replay rollback documentation is incomplete." >&2
  exit 1
fi
for rate_limiter_contract in \
  'final class MessageDeliveryRateLimiter' \
  'new LinkedHashMap<String, Long>()' \
  'maxSources <= 0 || minIntervalMillis <= 0L' \
  'nowMillis < previousDelivery.longValue()' \
  'nowMillis - previousDelivery.longValue() < minIntervalMillis' \
  'acceptedDeliveries.remove(source);' \
  'while (acceptedDeliveries.size() > maxSources)' \
  'acceptedDelivery.longValue() != acceptedAtMillis'; do
  if ! grep -Fq "$rate_limiter_contract" "$DELIVERY_RATE_LIMITER"; then
    printf '%s\n' "Wear delivery rate limiter contract changed: $rate_limiter_contract" >&2
    exit 1
  fi
done
for rate_listener_contract in \
  'MAX_RATE_LIMITED_LANES = 100' \
  'MIN_DELIVERY_INTERVAL_MILLIS = 500L' \
  'SystemClock.elapsedRealtime()' \
  'deliveryGate.commit(reservation)' \
  'deliveryGate.release(reservation)'; do
  if ! grep -Fq "$rate_listener_contract" "$WEAR_SERVICE"; then
    printf '%s\n' "Wear listener rate-limit integration changed: $rate_listener_contract" >&2
    exit 1
  fi
done
if ! tr '\n' ' ' < "$WEAR_SERVICE" | tr -s '[:space:]' ' ' | \
   grep -Fq 'deliveryGate.reserve( sourceNodeId, messageEvent.getPath(), requestId, acceptedAtMillis)'; then
  printf '%s\n' 'Wear listener must pass the canonical path into rate-limit admission.' >&2
  exit 1
fi
rate_reserve_line=$(grep -nF 'MessageDeliveryGate.Reservation reservation = deliveryGate.reserve(' "$WEAR_SERVICE" | cut -d: -f1)
rate_launch_line=$(grep -nF 'if (startWearActivity(message))' "$WEAR_SERVICE" | cut -d: -f1)
rate_commit_line=$(grep -nF 'deliveryGate.commit(reservation)' "$WEAR_SERVICE" | cut -d: -f1)
rate_release_line=$(grep -nF 'deliveryGate.release(reservation)' "$WEAR_SERVICE" | cut -d: -f1)
if [ -z "$rate_reserve_line" ] || [ -z "$rate_launch_line" ] || \
   [ -z "$rate_commit_line" ] || [ -z "$rate_release_line" ] || \
   [ "$rate_reserve_line" -ge "$rate_launch_line" ] || \
   [ "$rate_launch_line" -ge "$rate_commit_line" ] || \
   [ "$rate_commit_line" -ge "$rate_release_line" ]; then
  printf '%s\n' "Wear listener must reserve before launch and commit or release afterward." >&2
  exit 1
fi
if grep -Fq 'recentMessageIds' "$WEAR_SERVICE" || \
   grep -Fq 'deliveryRateLimiter' "$WEAR_SERVICE"; then
  printf '%s\n' "Wear listener must not mutate replay and rate-limit state outside the atomic gate." >&2
  exit 1
fi
for delivery_gate_contract in \
  'final class MessageDeliveryGate' \
  'synchronized Reservation reserve' \
  'recentMessageIds.record(sourceNodeId, requestId)' \
  'recentMessageIds.forget(sourceNodeId, requestId)' \
  'cooldownIdentity(normalizedSourceNodeId, canonicalPath)' \
  'cooldownIdentity(reservation.sourceNodeId, reservation.canonicalPath)' \
  'pendingReservations.containsKey(identity)' \
  'pendingReservations.get(identity) != reservation' \
  'synchronized boolean commit' \
  'synchronized boolean release'; do
  if ! grep -Fq "$delivery_gate_contract" "$DELIVERY_GATE"; then
    printf '%s\n' "Wear delivery gate contract changed: $delivery_gate_contract" >&2
    exit 1
  fi
done
for delivery_gate_test_contract in \
  'rateLimitedRequestRemainsRetryable' \
  'duplicateRequestDoesNotConsumeCooldown' \
  'launchFailureReleasesExactReservation' \
  'pendingRequestSurvivesReplayCacheEviction' \
  'Message delivery gate tests passed: '; do
  if ! grep -Fq "$delivery_gate_test_contract" "$DELIVERY_GATE_HOST_TEST"; then
    printf '%s\n' "Portable Wear delivery gate coverage is missing: $delivery_gate_test_contract" >&2
    exit 1
  fi
done
for delivery_gate_unit_contract in \
  'rateLimitedRequestRemainsRetryableAfterCooldown' \
  'duplicateRequestDoesNotConsumeCooldown' \
  'staleLaunchFailureCannotReleaseNewReservation' \
  'pendingRequestSurvivesReplayCacheEviction'; do
  if ! grep -Fq "$delivery_gate_unit_contract" "$DELIVERY_GATE_TEST"; then
    printf '%s\n' "Wear delivery gate unit coverage is missing: $delivery_gate_unit_contract" >&2
    exit 1
  fi
done
for delivery_gate_runner_contract in \
  'MessageDeliveryGate.java' \
  'MessageDeliveryGateHostTest.java' \
  'trap cleanup EXIT' \
  'rm -rf -- "$OUTPUT_DIR"'; do
  if ! grep -Fq "$delivery_gate_runner_contract" "$DELIVERY_GATE_HOST_RUNNER"; then
    printf '%s\n' "Portable Wear delivery gate runner changed: $delivery_gate_runner_contract" >&2
    exit 1
  fi
done
for delivery_gate_mutation_contract in \
  'replay-rollback' \
  'rate-rollback' \
  'stale-token' \
  'pending-eviction' \
  'source-only-cooldown-key' \
  'disabled-rate-limit' \
  'cross-source-cooldown' \
  'path-alias' \
  'replay-bypass' \
  'Message delivery gate hostile mutations rejected: 9 cases.'; do
  if ! grep -Fq "$delivery_gate_mutation_contract" "$DELIVERY_GATE_MUTATION_RUNNER"; then
    printf '%s\n' "Wear delivery gate mutation coverage is missing: $delivery_gate_mutation_contract" >&2
    exit 1
  fi
done
for rate_test_contract in \
  'acceptsFirstDeliveryAndCooldownBoundary' \
  'rejectedDeliveryDoesNotMoveWindow' \
  'keepsSourceWindowsIndependent' \
  'rejectsBackwardTimeWithoutCorruptingState' \
  'exactRollbackPermitsRetry' \
  'staleRollbackCannotClearNewerReservation' \
  'evictsOldestSourceAtCapacity' \
  'Wear delivery rate limiter tests passed: '; do
  if ! grep -Fq "$rate_test_contract" "$DELIVERY_RATE_HOST_TEST"; then
    printf '%s\n' "Portable Wear delivery rate coverage is missing: $rate_test_contract" >&2
    exit 1
  fi
done
for rate_runner_contract in \
  'MessageDeliveryRateLimiter.java' \
  'MessageDeliveryRateLimiterHostTest.java' \
  'trap cleanup EXIT' \
  'rm -rf -- "$OUTPUT_DIR"'; do
  if ! grep -Fq "$rate_runner_contract" "$DELIVERY_RATE_HOST_RUNNER"; then
    printf '%s\n' "Portable Wear delivery rate runner changed: $rate_runner_contract" >&2
    exit 1
  fi
done
for rate_unit_contract in \
  'enforcesPerSourceCooldownWithoutMovingRejectedWindow' \
  'rejectsInvalidAndBackwardTimeWithoutCorruptingState' \
  'exactRollbackCannotClearNewerReservation' \
  'evictsOldestSourceAtCapacity'; do
  if ! grep -Fq "$rate_unit_contract" "$DELIVERY_RATE_LIMITER_TEST"; then
    printf '%s\n' "Wear delivery rate unit coverage is missing: $rate_unit_contract" >&2
    exit 1
  fi
done
for rate_plan_contract in \
  'status: completed' \
  'SystemClock.elapsedRealtime()' \
  'make check' \
  'mutations' \
  '## Verification Results'; do
  if ! grep -Fq "$rate_plan_contract" "$DELIVERY_RATE_LIMIT_PLAN"; then
    printf '%s\n' "Wear listener rate-limit plan must record completed verification: $rate_plan_contract" >&2
    exit 1
  fi
done
for rate_doc in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  rate_doc_contract='Incoming Wear activity launches are limited per source node with a bounded monotonic in-process cooldown.'
  if [ "$rate_doc" = README.md ]; then
    rate_doc_contract='Incoming Wear activity launches use bounded monotonic in-process cooldown'
  fi
  if ! grep -Fq "$rate_doc_contract" "$ROOT_DIR/$rate_doc"; then
    printf '%s\n' "$rate_doc must document the Wear listener launch rate limit." >&2
    exit 1
  fi
done
if [ "$(grep -Fc 'startActivity(intent);' "$WEAR_SERVICE")" -ne 1 ] || \
   [ "$(grep -Fc 'catch (ActivityNotFoundException ignored)' "$WEAR_SERVICE")" -ne 1 ] || \
   [ "$(grep -Fc 'catch (SecurityException ignored)' "$WEAR_SERVICE")" -ne 1 ]; then
  printf '%s\n' "Wear listener launch failure boundary must remain singular and explicit." >&2
  exit 1
fi
if [ ! -f "$LISTENER_LAUNCH_FAILURE_PLAN" ] || \
   ! grep -Fq 'Status: Completed' "$LISTENER_LAUNCH_FAILURE_PLAN" || \
   ! grep -Fq 'make check' "$LISTENER_LAUNCH_FAILURE_PLAN" || \
   ! grep -Fq 'hostile mutations' "$LISTENER_LAUNCH_FAILURE_PLAN"; then
  printf '%s\n' "Wear listener launch failure plan must record completed verification." >&2
  exit 1
fi
if ! tr '\n' ' ' < "$ROOT_DIR/AGENTS.md" | tr -s '[:space:]' ' ' | grep -Fq 'isolate activity-not-found and security launch failures' || \
   ! grep -Fq 'isolates activity-not-found and security launch failures' "$README_FILE" || \
   ! grep -Fq 'activity launch failures are contained' "$SECURITY_FILE" || \
   ! grep -Fq 'listener launch failures isolated from message handling' "$VISION_FILE" || \
   ! grep -Fq 'Isolated documented Wear activity launch failures' "$CHANGES_FILE"; then
  printf '%s\n' "Wear listener launch failure documentation is incomplete." >&2
  exit 1
fi

for replay_test in \
  "rejectsDuplicateMessageIdentity" \
  "distinguishesRequestIdsBySourceNode" \
  "rejectsMissingMessageSourceNode" \
  "evictsOldestMessageIdentityAtLimit"; do
  if ! grep -Fq "$replay_test" "$WEAR_MESSAGE_TEST"; then
    printf '%s\n' "WearMessage tests must cover listener replay behavior: $replay_test" >&2
    exit 1
  fi
done

if ! grep -Fq "bounded 100-entry in-process cache" "$README_FILE" || \
   ! grep -Fq "2026-06-13-wear-listener-replay-guard.md" "$README_FILE"; then
  printf '%s\n' "README must document the bounded listener replay contract and plan." >&2
  exit 1
fi

if [ ! -f "$LISTENER_REPLAY_PLAN" ] || \
   ! grep -Fq "status: completed" "$LISTENER_REPLAY_PLAN" || \
   ! grep -Fq "## Status: Completed" "$LISTENER_REPLAY_PLAN" || \
   ! grep -Fq 'SDK-backed `make check` passed' "$LISTENER_REPLAY_PLAN" || \
   ! grep -Fq "Ten isolated hostile mutations were rejected" "$LISTENER_REPLAY_PLAN"; then
  printf '%s\n' "Wear listener replay plan must record completed status and verification." >&2
  exit 1
fi


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


for payload_test in "$MOBILE_MESSAGE_TEST" "$WEAR_MESSAGE_TEST"; do
  if ! grep -Fq "acceptsOnlyBoundedStrictUtf8Payloads" "$payload_test"; then
    printf '%s\n' "WearMessage tests must cover strict incoming UTF-8 payloads." >&2
    exit 1
  fi
  for payload_contract in \
    '"\u2603".getBytes(UTF_8)' \
    'new byte[] { (byte) 0xe2, (byte) 0x82 }' \
    'new byte[] { (byte) 0x80 }' \
    'new byte[WearMessage.MAX_MESSAGE_BYTES]' \
    'new byte[WearMessage.MAX_MESSAGE_BYTES + 1]'; do
    if ! grep -Fq "$payload_contract" "$payload_test"; then
      printf '%s\n' "Wear payload tests must retain strict UTF-8 assertion: $payload_contract" >&2
      exit 1
    fi
  done
done

if [ ! -f "$STRICT_UTF8_PLAN" ] || \
   ! grep -Fq "status: completed" "$STRICT_UTF8_PLAN" || \
   ! grep -Fq "## Status: Completed" "$STRICT_UTF8_PLAN" || \
   ! grep -Fq 'SDK-backed `make check` passed' "$STRICT_UTF8_PLAN" || \
   ! grep -Fq "hostile mutations were rejected" "$STRICT_UTF8_PLAN"; then
  printf '%s\n' "Strict UTF-8 payload plan must record completed verification." >&2
  exit 1
fi

for strict_utf8_doc in "$ROOT_DIR/AGENTS.md" "$README_FILE" "$SECURITY_FILE" \
  "$VISION_FILE" "$CHANGES_FILE"; do
  if ! tr '\n' ' ' < "$strict_utf8_doc" | tr -s '[:space:]' ' ' | \
      grep -Fiq "strict UTF-8 Wear payloads"; then
    printf '%s\n' "$strict_utf8_doc must document strict UTF-8 Wear payloads." >&2
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

for pairing_contract in \
  "## Paired Device and Emulator Prerequisites" \
  "garethpaul.com.wearer" \
  "same exact commit" \
  "same signing certificate" \
  "GoogleApiClient" \
  "synthetic payload"; do
  if ! grep -Fq "$pairing_contract" "$README_FILE"; then
    printf '%s\n' "README must retain paired-device prerequisite: $pairing_contract" >&2
    exit 1
  fi
done

for pairing_matrix_contract in \
  "## Pairing Prerequisites" \
  "same application ID" \
  "matching signing certificate" \
  "wearApp project(':wear')" \
  "platform-supported companion or emulator flow" \
  "Do not treat successful installation as Data Layer connection evidence."; do
  if ! grep -Fq "$pairing_matrix_contract" "$DEVICE_VERIFICATION"; then
    printf '%s\n' "Device verification must retain pairing prerequisite: $pairing_matrix_contract" >&2
    exit 1
  fi
done

for completed_priority in \
  "Pin or modernize dynamic Google Play services dependencies" \
  "Add tests or manual verification notes for message send/receive behavior" \
  "Document device or emulator pairing requirements"; do
  if grep -Fq "$completed_priority" "$VISION_FILE"; then
    printf '%s\n' "VISION next priorities must not retain completed item: $completed_priority" >&2
    exit 1
  fi
done

for roadmap_contract in \
  "Evaluate the archival boundary for Google Play services wearable 7.0.0" \
  "Execute the paired-device verification matrix"; do
  if ! grep -Fq "$roadmap_contract" "$VISION_FILE"; then
    printf '%s\n' "VISION must retain current roadmap priority: $roadmap_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "paired-device prerequisites" "$CHANGES_FILE"; then
  printf '%s\n' "CHANGES.md must record paired-device prerequisites." >&2
  exit 1
fi

pairing_plan_status=$(sed -n 's/^status: //p' "$PAIRING_PREREQUISITES_PLAN")
case "$pairing_plan_status" in
  pending_hosted_verification)
    if ! grep -Fq "Exact-head hosted checks remain pending." "$PAIRING_PREREQUISITES_PLAN"; then
      printf '%s\n' "Pending pairing plan must record pending exact-head checks." >&2
      exit 1
    fi
    ;;
  completed)
    for pairing_plan_contract in \
      "Exact-head hosted Check and CodeQL passed." \
      "isolated documentation mutations were rejected"; do
      if ! grep -Fq "$pairing_plan_contract" "$PAIRING_PREREQUISITES_PLAN"; then
        printf '%s\n' "Completed pairing plan must retain evidence: $pairing_plan_contract" >&2
        exit 1
      fi
    done
    ;;
  *)
    printf '%s\n' "Pairing plan must be pending hosted verification or completed." >&2
    exit 1
    ;;
esac

for pairing_plan_contract in \
  "play-services-wearable 7.0.0" \
  "garethpaul.com.wearer" \
  "matching signing certificate" \
  "GoogleApiClient" \
  "make check" \
  "No handset, Wear device, emulator pair, or live Data Layer connection was used"; do
  if ! grep -Fq "$pairing_plan_contract" "$PAIRING_PREREQUISITES_PLAN"; then
    printf '%s\n' "Pairing plan must retain local evidence: $pairing_plan_contract" >&2
    exit 1
  fi
done
printf '%s\n' "Android Wear Message API baseline checks passed."
