#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUTPUT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/wear-mixed-path-source-mutations.XXXXXX")
cleanup() {
  if [ -d "$OUTPUT_DIR" ]; then
    rm -rf -- "$OUTPUT_DIR"
  fi
}
trap cleanup EXIT
trap 'cleanup; exit 1' HUP INT TERM

run_mutation() {
  name=$1
  old=$2
  new=$3
  mutation_dir="$OUTPUT_DIR/$name"
  mkdir -p "$mutation_dir/wear/src/main/java/garethpaul/com/wearer" "$mutation_dir/scripts"
  cp "$ROOT_DIR/wear/src/main/java/garethpaul/com/wearer/MessageDeliveryGate.java" \
    "$mutation_dir/wear/src/main/java/garethpaul/com/wearer/"
  cp "$ROOT_DIR/wear/src/main/java/garethpaul/com/wearer/WearMessageListenerService.java" \
    "$mutation_dir/wear/src/main/java/garethpaul/com/wearer/"
  cp "$ROOT_DIR/scripts/MessageDeliveryGateHostTest.java" "$mutation_dir/scripts/"
  cp "$ROOT_DIR/scripts/test-wear-mixed-path-cooldown-contract.sh" "$mutation_dir/scripts/"

  OLD_TEXT=$old NEW_TEXT=$new python3 - \
    "$mutation_dir/wear/src/main/java/garethpaul/com/wearer/MessageDeliveryGate.java" <<'PY'
import os
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
source = path.read_text()
old = os.environ["OLD_TEXT"]
new = os.environ["NEW_TEXT"]
if source.count(old) != 1:
    raise SystemExit("mutation target must occur exactly once")
path.write_text(source.replace(old, new))
PY

  if "$mutation_dir/scripts/test-wear-mixed-path-cooldown-contract.sh" \
      >"$mutation_dir/output.log" 2>&1; then
    printf '%s\n' "Source mutation survived: $name" >&2
    cat "$mutation_dir/output.log" >&2
    exit 1
  fi
}

run_mutation source-only-cooldown-key \
  'cooldownIdentity(normalizedSourceNodeId, canonicalPath)' \
  'normalizedSourceNodeId'
run_mutation disabled-rate-limit \
  '        if (!deliveryRateLimiter.allow(' \
  '        if (false && !deliveryRateLimiter.allow('
run_mutation cross-source-coupling \
  '        return sourceNodeId + "\n" + canonicalPath;' \
  '        return canonicalPath;'
run_mutation path-aliasing \
  '        if (WearMessage.isWearMessagePath(messagePath)) {' \
  '        if (WearMessage.isWearMessagePath(messagePath) || "/MESSAGE".equals(messagePath)) {'
run_mutation replay-bypass \
  '        if (!recentMessageIds.record(sourceNodeId, requestId)) {' \
  '        if (false && !recentMessageIds.record(sourceNodeId, requestId)) {'

printf '%s\n' 'Wear mixed-path source mutations rejected: 5 cases.'
