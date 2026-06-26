#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SOURCE="$ROOT_DIR/mobile/src/main/java/garethpaul/com/wearer/MainActivity.java"
CONTRACT="$ROOT_DIR/scripts/test-wear-node-discovery-status.sh"
TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/wear-node-discovery-mutations.XXXXXX")
trap 'rm -rf "$TEMP_DIR"' EXIT HUP INT TERM

reject_mutation() {
  name=$1
  source=$2
  if MOBILE_ACTIVITY_SOURCE="$source" "$CONTRACT" >/dev/null 2>&1; then
    printf '%s\n' "Mutation survived: $name" >&2
    exit 1
  fi
  printf '%s\n' "Mutation rejected: $name"
}

cp "$SOURCE" "$TEMP_DIR/missing-status-null.java"
perl -0pi -e 's/nodes\.getStatus\(\) == null\s*\|\|\s*//' "$TEMP_DIR/missing-status-null.java"
reject_mutation "removed discovery status null guard" "$TEMP_DIR/missing-status-null.java"

cp "$SOURCE" "$TEMP_DIR/accepts-failed-status.java"
perl -0pi -e 's/!nodes\.getStatus\(\)\.isSuccess\(\)/nodes.getStatus().isSuccess()/' "$TEMP_DIR/accepts-failed-status.java"
reject_mutation "accepted failed discovery status" "$TEMP_DIR/accepts-failed-status.java"

python3 - "$SOURCE" "$TEMP_DIR/iteration-before-status.java" <<'PY'
from pathlib import Path
import sys

source = Path(sys.argv[1]).read_text(encoding="utf-8")
guard = "                    if (nodes == null || nodes.getStatus() == null"
source = source.replace(
    guard,
    "                    for (Node node : nodes.getNodes()) {}\n" + guard,
    1,
)
Path(sys.argv[2]).write_text(source, encoding="utf-8")
PY
reject_mutation "iterated nodes before status validation" "$TEMP_DIR/iteration-before-status.java"

printf '%s\n' "All Wear node discovery status mutations were rejected"
