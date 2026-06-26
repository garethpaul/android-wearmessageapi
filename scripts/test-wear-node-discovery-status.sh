#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SOURCE=${MOBILE_ACTIVITY_SOURCE:-"$ROOT_DIR/mobile/src/main/java/garethpaul/com/wearer/MainActivity.java"}

python3 - "$SOURCE" <<'PY'
from pathlib import Path
import re
import sys

source = Path(sys.argv[1]).read_text(encoding="utf-8")
signature = "private void sendMessage("
method_start = source.find(signature)
if method_start < 0:
    raise SystemExit("Wear node discovery status contract failed: sendMessage is missing")

body_start = source.find("{", method_start)
if body_start < 0:
    raise SystemExit("Wear node discovery status contract failed: sendMessage body is missing")

depth = 0
body_end = None
for index in range(body_start, len(source)):
    if source[index] == "{":
        depth += 1
    elif source[index] == "}":
        depth -= 1
        if depth == 0:
            body_end = index
            break

if body_end is None:
    raise SystemExit("Wear node discovery status contract failed: sendMessage body is unbalanced")

method = source[body_start + 1:body_end]
compact = re.sub(r"\s+", "", method)
guard = (
    "if(nodes==null||nodes.getStatus()==null||"
    "!nodes.getStatus().isSuccess()||nodes.getNodes()==null){return;}"
)
guard_index = compact.find(guard)
iteration_index = compact.find("for(Nodenode:nodes.getNodes())")

if guard_index < 0:
    raise SystemExit(
        "Wear node discovery status contract failed: discovery must fail closed on missing or unsuccessful status"
    )
if iteration_index < 0 or guard_index >= iteration_index:
    raise SystemExit(
        "Wear node discovery status contract failed: discovery status must be validated before node iteration"
    )

print("Wear node discovery status contract passed")
PY
