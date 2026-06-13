---
title: Wear Strict UTF-8 Payload Validation
type: security
status: planned
date: 2026-06-13
---

# Wear Strict UTF-8 Payload Validation

## Status: Planned

## Priority

The Wear listener checks only whether incoming payload bytes are nonempty and
at most 4096 bytes. `new String(bytes, UTF-8)` replaces malformed byte
sequences, so corrupted or non-UTF-8 transport input can be transformed into a
different visible message and treated as valid. Strict validation belongs
before replay-state mutation and activity launch.

## Requirements

- **R1:** Require incoming payloads to be nonempty, at most 4096 bytes, and
  strictly decodable as UTF-8 without replacement.
- **R2:** Keep the duplicated mobile and Wear `WearMessage` helpers identical
  for payload validation and preserve current null decoding behavior.
- **R3:** Preserve recognized paths, replay suppression, activity delivery,
  visible-history limits, and outgoing message behavior.
- **R4:** Add JVM regression tests for valid multibyte UTF-8, truncated
  multibyte input, and stray continuation bytes in both modules.
- **R5:** Add fail-closed checker, documentation, hostile mutation, and
  truthful local and hosted verification evidence.

## Implementation Units

### U1: Decode Incoming Bytes Strictly

**Files:**

- `mobile/src/main/java/garethpaul/com/wearer/WearMessage.java`
- `wear/src/main/java/garethpaul/com/wearer/WearMessage.java`

Use a fresh UTF-8 decoder configured to report malformed and unmappable input.
Keep the existing length boundary as an early rejection and return false when
decoding raises a character-coding exception. Do not change the public/sample
API or make the decoder shared across threads.

### U2: Cover Encoding Boundaries

**Files:**

- `mobile/src/test/java/garethpaul/com/wearer/WearMessageTest.java`
- `wear/src/test/java/garethpaul/com/wearer/WearMessageTest.java`

Prove ordinary UTF-8 and a valid multibyte character remain accepted. Prove a
truncated multibyte sequence and a standalone continuation byte are rejected.
Retain exact empty, maximum-size, and oversized payload assertions.

### U3: Protect The Contract

**File:** `scripts/check-baseline.sh`

Require strict decoder configuration in both helper copies, require the new
tests by name and byte pattern, reject replacement or ignore actions, and
require completed plan evidence.

### U4: Document The Boundary

**Files:**

- `AGENTS.md`
- `README.md`
- `SECURITY.md`
- `VISION.md`
- `CHANGES.md`
- `docs/plans/2026-06-13-wear-strict-utf8-payload.md`

Document that incoming Wear payloads must be strict UTF-8 before replay state
or UI delivery, and record exact verification evidence.

## Test Scenarios

- A nonempty ASCII payload remains valid.
- A valid multibyte UTF-8 payload remains valid.
- A truncated multibyte sequence is rejected.
- A standalone continuation byte is rejected.
- Empty and oversized payloads remain rejected.
- Null decoding remains an empty string for existing callers.
- Replacing `REPORT` with `REPLACE` or `IGNORE`, removing either decoder action,
  removing either module's tests, changing payload bounds, or reverting plan
  completion fails the repository gate.

## Scope Boundaries

- Do not migrate Google Play services, Android, Gradle, Java, or the Wearable
  transport API.
- Do not change paths, payload size, replay cache identity, activity flags,
  manifests, visible-history behavior, or sender timeouts.
- Do not claim cryptographic source authentication; this validates encoding
  integrity inside the existing application/transport trust boundary.

## Verification

Pending implementation and execution.

## Sources

- Java SE 8 `CodingErrorAction`:
  https://docs.oracle.com/javase/8/docs/api/java/nio/charset/CodingErrorAction.html
- Java SE 8 `Charset` decoding guidance:
  https://docs.oracle.com/javase/8/docs/api/java/nio/charset/Charset.html
