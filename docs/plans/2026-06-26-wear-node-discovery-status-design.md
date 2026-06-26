# Wear Node Discovery Status Design

## Evidence

- The handset sender waits for `NodeApi.GetConnectedNodesResult`, then reads
  `getNodes()` after checking only the result and list for null.
- Google documents `GetConnectedNodesResult` as a `Result` exposing
  `getStatus()`: <https://developers.google.com/android/reference/com/google/android/gms/wearable/NodeApi.GetConnectedNodesResult>.
- Google documents `Status.isSuccess()` as the operation success boundary:
  <https://developers.google.com/android/reference/com/google/android/gms/common/api/Status>.
- The same sender already validates each message-send result status before
  reporting success.

## Approaches

### 1. Inline discovery status guard

Reject a missing result, missing status, unsuccessful status, or missing node
list before iteration. This is the smallest correction and matches the existing
send-result policy.

### 2. Shared result validation helper

Extract a helper around `GetConnectedNodesResult`. This reduces one condition
but introduces a legacy Play Services type abstraction used at only one call
site.

### 3. Migrate to `NodeClient`

Replace the deprecated API with the current asynchronous client. This is a
larger dependency and lifecycle migration outside the focused correctness fix.

## Decision

Use the inline fail-closed guard. Keep the current API, shared deadline, user
result behavior, node filtering, and per-node send loop unchanged.

## Validation

- Add an SDK-free source contract that requires the status guard before the
  first node-list access.
- Observe the contract fail against the current sender.
- Add the minimal guard and rerun the contract.
- Add hostile mutations for removed, inverted, and reordered status checks.
- Run repository, external Makefile, hosted Android, and CodeQL gates.

## Boundaries

- Do not log provider status details or device identity.
- Do not change message paths, payloads, timeouts, UI, or connection lifecycle.
- Paired-device delivery remains a manual verification boundary.
