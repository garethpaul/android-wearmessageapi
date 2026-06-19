#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUTPUT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/wear-delivery-gate.XXXXXX")
cleanup() {
  if [ -d "$OUTPUT_DIR" ]; then
    rm -rf -- "$OUTPUT_DIR"
  fi
}
trap cleanup EXIT
trap 'cleanup; exit 1' HUP INT TERM

javac -source 1.7 -target 1.7 -Xlint:-options \
  -d "$OUTPUT_DIR" \
  "$ROOT_DIR/wear/src/main/java/garethpaul/com/wearer/WearMessage.java" \
  "$ROOT_DIR/wear/src/main/java/garethpaul/com/wearer/MessageDeliveryRateLimiter.java" \
  "$ROOT_DIR/wear/src/main/java/garethpaul/com/wearer/MessageDeliveryGate.java" \
  "$ROOT_DIR/scripts/MessageDeliveryGateHostTest.java"
java -cp "$OUTPUT_DIR" garethpaul.com.wearer.MessageDeliveryGateHostTest
