# Wear Listener Semantic Payload Validation

Status: Planned

## Context

The exported Wear listener fetches payload bytes once, enforces the 4096-byte
strict UTF-8 boundary, and suppresses replayed source/request identities.
However, any nonempty valid UTF-8 payload can currently launch the private Wear
activity before that activity rejects semantically blank text. Whitespace-only
messages should be rejected at the listener boundary without waking the UI or
consuming replay history.

## Scope

- Reuse the aligned mobile/Wear `isValidMessageText` helper after the listener's
  single strict payload decode.
- Record replay identity and launch the activity only for semantically valid
  decoded messages.
- Delegate malformed, oversized, empty, or semantically blank payloads to the
  superclass path without launching the private activity.
- Protect ordering with existing symmetric helper tests and new static
  listener integration contracts.

## Out Of Scope

- Cryptographic source authentication, transport changes, paired-device tests,
  UI redesign, or Google Play services modernization.
- Additional payload normalization or changes to the 4096-byte limit.

## Implementation

### U1: Validate Before Replay And Launch

**File:** `wear/src/main/java/garethpaul/com/wearer/WearMessageListenerService.java`

Compute semantic validity from the single decoded string, then require it
before replay recording and private activity launch.

### U2: Protect The Listener Boundary

**File:** `scripts/check-baseline.sh`

Require decode, semantic validation, replay recording, and launch in that order.
Retain the existing symmetric whitespace tests and reject predicate bypasses.

### U3: Document And Verify

**Files:** `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`,
this plan

Document listener-side rejection of semantically blank payloads. Run focused
module tests, canonical and external-working-directory `make check`, hostile
mutations, and exact artifact/secret/diff inspection before hosted validation.

## Verification

- Pending implementation.
