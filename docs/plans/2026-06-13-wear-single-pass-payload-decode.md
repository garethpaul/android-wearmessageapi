# Decode Wear Payloads Once

Status: Completed

## Context

The Wear listener strictly validates `messageEvent.getData()`, then calls
`getData()` again and decodes through a permissive helper. That separates the
bytes that passed validation from the bytes delivered to the activity and
performs duplicate UTF-8 work. A receiver should make one bounded, strict
decode decision over one captured payload.

## Requirements

- R1. Capture the message payload byte array exactly once per `/message` event.
- R2. Bound and strictly decode that captured array in one helper call, returning
  no text for null, empty, oversized, malformed, or unmappable payloads.
- R3. Deliver only the exact text returned by the strict decoder; do not decode
  or fetch payload bytes again after validation.
- R4. Preserve message-path checks, source/request replay suppression, activity
  flags, 4096-byte limits, UTF-8 encoding, and start-activity behavior.
- R5. Keep mobile and Wear message helper contracts aligned and retain Java
  8/API 22 compatibility.

## Implementation Units

### 1. Strict decode result

Files:
- `mobile/src/main/java/garethpaul/com/wearer/WearMessage.java`
- `wear/src/main/java/garethpaul/com/wearer/WearMessage.java`
- `mobile/src/test/java/garethpaul/com/wearer/WearMessageTest.java`
- `wear/src/test/java/garethpaul/com/wearer/WearMessageTest.java`

Return decoded text from the existing strict decoder and use `null` as the
invalid-payload result. Keep `isValidPayload` as a compatibility predicate that
delegates to the same strict operation. Add valid, malformed, empty, null,
oversized, and exact-limit tests in both modules.

### 2. Single-pass listener delivery

Files:
- `wear/src/main/java/garethpaul/com/wearer/WearMessageListenerService.java`

Capture `messageEvent.getData()` once, decode once, and route only a non-null
result through the existing replay guard and activity launch path.

### 3. Durable contracts and guidance

Files:
- `scripts/check-baseline.sh`
- `AGENTS.md`
- `README.md`
- `SECURITY.md`
- `VISION.md`
- `CHANGES.md`

Protect single-fetch/single-decode ordering, strict helper parity, tests,
documentation, and completed verification evidence.

## Verification

Verification: Completed

- Focused SDK-backed mobile and Wear debug/release JVM tests pass.
- Canonical and external-working-directory SDK-backed `make check` pass both
  modules' lint, JVM tests, debug APK assembly, and baseline contracts.
- Nine focused hostile mutations cover duplicate payload fetch, permissive
  decode delivery, predicate-only validation, invalid-result delivery, helper
  drift between modules, strict-decode test removal, exact-limit test removal,
  stale plan status, and missing mutation evidence. Every mutation is rejected.
- Shell syntax, `git diff --check`, generated-artifact inspection, and
  credential-shaped added-line scanning are part of the pre-push audit.
- Exact-head hosted checks and code-scanning state are recorded after push.

## Work Completed

- Added a strict decode-result helper in both modules and retained the existing
  validity predicate as a delegate to the same operation.
- Captured Wear event payload bytes once and delivered only the text returned
  from that strict bounded decode.
- Preserved invalid-event fallback, replay suppression, paths, limits, flags,
  and activity delivery behavior.
- Added matching null, empty, malformed, oversized, valid, and exact-limit
  decode-result tests to both modules.

## Scope Boundaries

- Do not change message paths, limits, replay identity, activity flags, or UI.
- Do not modernize Google Play services, Gradle, SDK levels, or transport APIs.
- Do not claim paired-device or physical Wear delivery coverage.
