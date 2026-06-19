#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUTPUT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/wear-message-paths.XXXXXX")
cleanup() {
  if [ -d "$OUTPUT_DIR" ]; then
    rm -rf -- "$OUTPUT_DIR"
  fi
}
trap cleanup EXIT
trap 'cleanup; exit 1' HUP INT TERM

for module in mobile wear; do
  MODULE_OUTPUT="$OUTPUT_DIR/$module"
  mkdir -p "$MODULE_OUTPUT"
  javac -source 1.7 -target 1.7 -Xlint:-options \
    -d "$MODULE_OUTPUT" \
    "$ROOT_DIR/$module/src/main/java/garethpaul/com/wearer/WearMessage.java" \
    "$ROOT_DIR/scripts/WearMessagePathHostTest.java"
  java -cp "$MODULE_OUTPUT" garethpaul.com.wearer.WearMessagePathHostTest
done
