# Wear Listener Launch Failure Isolation

Status: Completed

## Problem

The exported Wear listener validates paths, payloads, and replay identity before
opening the private activity, but `startActivity` failures currently escape the
service callback. A missing activity or platform security-policy rejection can
therefore terminate message handling even though the transport event itself was
already safely validated.

## Requirements

1. Contain `ActivityNotFoundException` and `SecurityException` at the private
   activity launch boundary.
2. Keep path matching, strict payload validation, replay recording, intent
   flags, extras, and activity ownership unchanged.
3. Do not add a broad `RuntimeException` catch or suppress failures outside the
   documented Android launch outcomes.
4. Add mutation-sensitive static contracts for imports, exception order,
   singular launch ownership, documentation, and completed plan evidence.
5. Run the full repository gate from the repository root and an unrelated
   working directory.

## Implementation Units

### U1: Isolate Documented Launch Failures

**File:** `wear/src/main/java/garethpaul/com/wearer/WearMessageListenerService.java`

Wrap the existing private-activity launch with narrow handlers for the two
documented Android launch exceptions while retaining the same intent.

### U2: Protect The Boundary

**File:** `scripts/check-baseline.sh`

Require the explicit exception import and ordered narrow catches, reject broad
runtime suppression, and keep one launch call and one handler for each failure.

### U3: Document Ownership And Verification

**Files:** `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`,
this plan

Record the service failure boundary and the exact validation performed.

## Scope Boundaries

- Do not change listener export policy, message paths, replay identity,
  payload limits, strict UTF-8 behavior, activity flags, or user-visible text.
- Do not claim emulator, paired-device, or platform launch-failure injection.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification

- Root and external-directory `make check` passed the portable baseline and
  canonical path host suite; Android SDK-dependent lint, tests, and build
  truthfully retained their existing conditional skip when no SDK was
  configured.
- Six hostile mutations were rejected for a missing exception import, a broad
  runtime catch, a missing security handler, a duplicate launch call, reopened
  plan status, and removed documentation.
- Final verification covered shell syntax, the exact diff, whitespace,
  conflict markers, credential-shaped additions, and generated artifacts.
- Emulator, paired-device, transport, and platform launch-failure injection
  were not exercised.
