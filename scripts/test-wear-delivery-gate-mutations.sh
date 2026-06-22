#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUTPUT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/wear-delivery-gate-mutations.XXXXXX")
cleanup() {
  if [ -d "$OUTPUT_DIR" ]; then
    rm -rf -- "$OUTPUT_DIR"
  fi
}
trap cleanup EXIT
trap 'cleanup; exit 1' HUP INT TERM

if ! javac -version >/dev/null 2>&1 || ! java -version >/dev/null 2>&1; then
  printf '%s\n' 'Java runtime unavailable; delivery gate Java mutations not run.' >&2
  exit 2
fi

run_mutation() {
  name=$1
  old=$2
  new=$3
  mutation_dir="$OUTPUT_DIR/$name"
  mkdir -p "$mutation_dir/src" "$mutation_dir/classes"
  cp "$ROOT_DIR/wear/src/main/java/garethpaul/com/wearer/WearMessage.java" "$mutation_dir/src/"
  cp "$ROOT_DIR/wear/src/main/java/garethpaul/com/wearer/MessageDeliveryRateLimiter.java" "$mutation_dir/src/"
  cp "$ROOT_DIR/wear/src/main/java/garethpaul/com/wearer/MessageDeliveryGate.java" "$mutation_dir/src/"
  cp "$ROOT_DIR/scripts/MessageDeliveryGateHostTest.java" "$mutation_dir/src/"

  OLD_TEXT=$old NEW_TEXT=$new python3 - "$mutation_dir/src/MessageDeliveryGate.java" <<'PY'
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

  if javac -source 1.7 -target 1.7 -Xlint:-options \
      -d "$mutation_dir/classes" "$mutation_dir/src/"*.java && \
      java -cp "$mutation_dir/classes" garethpaul.com.wearer.MessageDeliveryGateHostTest \
        >"$mutation_dir/output.log" 2>&1; then
    printf '%s\n' "Mutation survived: $name" >&2
    cat "$mutation_dir/output.log" >&2
    exit 1
  fi
}

run_mutation replay-rollback \
  '            recentMessageIds.forget(sourceNodeId, requestId);' \
  '            // mutation: replay reservation retained'
run_mutation rate-rollback \
  '        boolean releasedRateLimit = deliveryRateLimiter.forget(' \
  '        boolean releasedRateLimit = false && deliveryRateLimiter.forget('
run_mutation stale-token \
  '        if (pendingReservations.get(identity) != reservation) {' \
  '        if (pendingReservations.get(identity) == null) {'
run_mutation pending-eviction \
  '        if (pendingReservations.containsKey(identity)) {' \
  '        if (false && pendingReservations.containsKey(identity)) {'
run_mutation source-only-cooldown-key \
  'cooldownIdentity(normalizedSourceNodeId, canonicalPath)' \
  'normalizedSourceNodeId'
run_mutation disabled-rate-limit \
  '        if (!deliveryRateLimiter.allow(' \
  '        if (false && !deliveryRateLimiter.allow('
run_mutation cross-source-cooldown \
  '        return sourceNodeId + "\n" + canonicalPath;' \
  '        return canonicalPath;'
run_mutation path-alias \
  '        if (WearMessage.isWearMessagePath(messagePath)) {' \
  '        if (WearMessage.isWearMessagePath(messagePath) || "/MESSAGE".equals(messagePath)) {'
run_mutation replay-bypass \
  '        if (!recentMessageIds.record(sourceNodeId, requestId)) {' \
  '        if (false && !recentMessageIds.record(sourceNodeId, requestId)) {'

printf '%s\n' 'Message delivery gate hostile mutations rejected: 9 cases.'
