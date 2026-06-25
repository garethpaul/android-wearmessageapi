#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

python3 - "$ROOT_DIR" <<'PY'
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
gate = (root / "wear/src/main/java/garethpaul/com/wearer/MessageDeliveryGate.java").read_text()
listener = (root / "wear/src/main/java/garethpaul/com/wearer/WearMessageListenerService.java").read_text()
host_test = (root / "scripts/MessageDeliveryGateHostTest.java").read_text()

required_gate_contracts = (
    "canonicalPath(messagePath)",
    "cooldownIdentity(normalizedSourceNodeId, canonicalPath)",
    "reservation.canonicalPath",
    "if (!recentMessageIds.record(sourceNodeId, requestId))",
    "if (!deliveryRateLimiter.allow(",
    'return sourceNodeId + "\\n" + canonicalPath;',
)
gate_compact = " ".join(gate.split()).replace("( ", "(")
reserve_contract = (
    "reserve(String sourceNodeId, String messagePath, int requestId, long acceptedAtMillis)"
)
if reserve_contract not in gate_compact:
    raise SystemExit("Missing mixed-path gate contract: " + reserve_contract)
for contract in required_gate_contracts:
    if contract not in gate:
        raise SystemExit("Missing mixed-path gate contract: " + contract)

if '"/MESSAGE".equals(messagePath)' in gate:
    raise SystemExit("Cooldown admission must not alias noncanonical message paths")

listener_reservation = (
    "deliveryGate.reserve(sourceNodeId, messageEvent.getPath(), requestId, acceptedAtMillis)"
)
listener_compact = " ".join(listener.split()).replace("( ", "(")
if listener_reservation not in listener_compact:
    raise SystemExit("Listener must pass the accepted canonical path into the delivery gate")

decode_position = listener.find("WearMessage.decodeValidPayload(payload)")
reserve_position = listener.find("deliveryGate.reserve(")
if decode_position < 0 or reserve_position < 0 or decode_position > reserve_position:
    raise SystemExit("Strict UTF-8 decode must remain before delivery-gate reservation")

required_cases = (
    "startThenMessageUsesSeparateCooldownLanes",
    "messageThenStartUsesSeparateCooldownLanes",
    "repeatedStartActivityIsRateLimited",
    "repeatedMessageIsRateLimited",
    "replayIdentitySpansCanonicalPaths",
    "cooldownLanesRemainSourceIsolated",
    "releaseDoesNotClearOtherPathLane",
    "cooldownCacheRemainsBoundedAcrossPathLanes",
    "nonCanonicalPathsDoNotMutateAdmissionState",
)
for case in required_cases:
    if case not in host_test:
        raise SystemExit("Missing host regression case: " + case)

print("Wear mixed-path cooldown source contract passed.")
PY
