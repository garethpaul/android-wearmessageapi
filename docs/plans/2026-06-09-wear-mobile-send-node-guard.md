# Wear Mobile Send Node Guard

status: completed

## Context

The mobile sender already preserved message input unless at least one Wear
message send reported success. The background send loop still assumed the
connected-node result, node collection, node IDs, send result, and send status
were all present.

## Objectives

- Preserve the existing start-activity and text-message path contracts.
- Keep clearing the mobile input only after a successful send.
- Ignore missing connected-node data instead of crashing the send thread.
- Keep the behavior covered by the SDK-free baseline checker.

## Work Completed

- Guarded null connected-node results and node collections.
- Skipped null nodes or nodes without IDs before calling `sendMessage`.
- Guarded null send results and statuses before checking success.
- Extended `scripts/check-baseline.sh`.
- Updated README, VISION, and CHANGES notes.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
