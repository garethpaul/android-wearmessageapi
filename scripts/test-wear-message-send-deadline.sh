#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUTPUT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/wear-send-deadline.XXXXXX")
cleanup() {
  if [ -d "$OUTPUT_DIR" ]; then
    rm -rf -- "$OUTPUT_DIR"
  fi
}
trap cleanup EXIT
trap 'cleanup; exit 1' HUP INT TERM

javac -source 1.7 -target 1.7 -Xlint:-options \
  -d "$OUTPUT_DIR" \
  "$ROOT_DIR/mobile/src/main/java/garethpaul/com/wearer/MessageSendDeadline.java" \
  "$ROOT_DIR/scripts/MessageSendDeadlineHostTest.java"
java -cp "$OUTPUT_DIR" garethpaul.com.wearer.MessageSendDeadlineHostTest
