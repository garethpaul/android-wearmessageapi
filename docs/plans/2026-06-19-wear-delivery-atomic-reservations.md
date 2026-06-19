# Wear Delivery Atomic Reservations

Status: Implemented

## Problem

The listener recorded a source/request identity before consulting its per-source
launch cooldown. When cooldown admission rejected a distinct request, that
request remained in the replay cache despite never reaching the activity. A
later legitimate redelivery was therefore suppressed as a duplicate.

The replay cache is also bounded. Under concurrent delivery, eviction could
remove an identity while its activity launch was still pending, allowing the
same source/request pair to reserve and launch a second time.

## Root Cause and Provenance

PR #15 commit `34872e20` added per-source rate limiting after the replay cache
mutation introduced by PR #3 commit `59bc5964`. Each helper was internally
synchronized, but the listener mutated them as separate operations with no
shared transaction or pending-launch identity.

## Design

`MessageDeliveryGate` owns replay admission, cooldown admission, pending launch
tokens, commit, and exact rollback. A rejected cooldown removes the replay
reservation before returning. Successful launches commit only the current
pending token. Failed launches release replay and cooldown state only when the
token still owns that source/request identity. Pending identities are checked
before the bounded completed-request cache so eviction cannot reopen an active
launch.

## Verification

- Red-first host tests reproduced both the throttled-redelivery loss and the
  pending-identity eviction race.
- Pure-Java host tests cover cooldown retry, duplicate cooldown isolation,
  exact stale-token rollback, and pending identity pinning.
- Four hostile mutations remove replay rollback, rate rollback, stale-token
  rejection, and pending-identity pinning; all are rejected by the host suite.
- `scripts/check-baseline.sh` enforces atomic gate ownership and listener
  reserve/launch/commit-or-release ordering.
- `make check` passes without an Android SDK; hosted Android and CodeQL results
  are recorded on the aggregate pull request.

## Residual Risk

The host and Android unit contracts do not exercise a paired physical watch,
Google Play services Data Layer scheduling, process death, or real activity
launch timing. Those remain device-verification requirements.
