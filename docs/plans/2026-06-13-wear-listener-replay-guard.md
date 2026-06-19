---
title: Wear Listener Replay Guard
type: security
status: completed
date: 2026-06-13
---

# Wear Listener Replay Guard

## Status: Completed

## Problem Frame

`WearMessageListenerService` launches the watch activity for every recognized
message event. The legacy `MessageEvent` contract supplies a source node ID and
request ID, but the service does not validate the source identifier or remember
recently handled identities. A duplicate callback can therefore relaunch the
activity or append the same message repeatedly during the service process
lifetime.

## Scope Boundaries

- Preserve the `/start_activity` and `/message` path contracts.
- Preserve UTF-8 payload validation and the 4 KiB message limit.
- Do not migrate the deprecated Wearable API, change manifests, or claim node
  authentication beyond the application identity enforced by Wear transport.
- Keep replay state bounded and in memory; cross-process persistence is outside
  this pass.

## Implementation Units

### U1: Add A Bounded Message Identity Cache

Files:

- Modify `wear/src/main/java/garethpaul/com/wearer/WearMessage.java`

Approach:

- Add a fixed maximum for recently accepted message identities.
- Add a pure Java helper that keys identities by source node ID and request ID.
- Reject null or blank source node IDs.
- Reject duplicate identities, distinguish the same request ID from different
  source nodes, and evict the oldest identity when the bound is reached.
- Synchronize cache mutation because listener callback threading is controlled
  by Play Services.

### U2: Guard Listener Dispatch

Files:

- Modify
  `wear/src/main/java/garethpaul/com/wearer/WearMessageListenerService.java`

Approach:

- Keep one service-lifetime recent-identity cache.
- Record identities only after path and payload validation succeeds.
- Ignore malformed-source and duplicate recognized events without launching the
  activity or delegating them as unknown paths.

### U3: Add JVM Regression Coverage

Files:

- Modify `wear/src/test/java/garethpaul/com/wearer/WearMessageTest.java`

Approach:

- Cover first acceptance and duplicate rejection.
- Cover source-node separation for equal request IDs.
- Cover null and blank source rejection.
- Cover oldest-entry eviction at the configured bound.

### U4: Extend Static And Documentation Contracts

Files:

- Modify `scripts/check-baseline.sh`
- Modify `README.md`
- Modify `CHANGES.md`
- Modify `VISION.md`

Approach:

- Require the bounded cache, source/request identity use, listener guard, named
  tests, and completed plan evidence.
- Record the exact in-process replay protection and its persistence boundary.

## Verification

- `scripts/check-baseline.sh` passed.
- SDK-backed `:wear:test` passed with 14 debug and 14 release tests.
- SDK-backed `make check` passed from the repository and from `/tmp`, with zero
  mobile or Wear lint issues, 9 mobile tests and 14 Wear tests per variant, and
  both debug APK assemblies.
- Ten isolated hostile mutations were rejected across cache bounds,
  synchronization, duplicate detection, eviction, listener identity wiring,
  named tests, and README evidence.
- `sh -n scripts/check-baseline.sh` and `git diff --check` passed.
