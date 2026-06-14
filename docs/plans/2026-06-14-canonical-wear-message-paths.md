# Canonical Wear Message Paths

Status: In Progress

## Problem

The phone emits fixed `/start_activity` and `/message` transport paths, but
both shared helpers accept case variants through `equalsIgnoreCase`. Wear
message paths are protocol identifiers, so accepting noncanonical spellings
unnecessarily broadens which events can trigger activity launch or message
delivery.

## Requirements

1. Accept only the exact canonical start-activity and message paths in both
   mobile and Wear helper implementations.
2. Keep null and unrelated paths rejected.
3. Preserve sender paths, payload validation, replay suppression, activity
   launch behavior, timeouts, message history, and public application APIs.
4. Update both Android/JUnit suites to accept canonical paths and reject case
   variants.
5. Add a portable host test that compiles each production helper separately and
   verifies aligned path behavior without an Android SDK.
6. Use isolated, existence-checked temporary output cleanup and add
   mutation-sensitive contracts for both modules, tests, invocation,
   documentation, and completed plan evidence.

## Implementation Units

### U1: Require Exact Protocol Paths

**Files:** `mobile/src/main/java/garethpaul/com/wearer/WearMessage.java`,
`wear/src/main/java/garethpaul/com/wearer/WearMessage.java`

Replace case-insensitive path matching with null-safe exact equality in both
copies of the shared transport helper.

### U2: Align Android And Portable Tests

**Files:** `mobile/src/test/java/garethpaul/com/wearer/WearMessageTest.java`,
`wear/src/test/java/garethpaul/com/wearer/WearMessageTest.java`,
`scripts/WearMessagePathHostTest.java`, `scripts/test-wear-message-paths.sh`,
`Makefile`

Update the mirrored JUnit contracts and compile each production helper with a
dependency-free host runner before optional Gradle tests.

### U3: Protect And Document

**Files:** `scripts/check-baseline.sh`, `AGENTS.md`, `README.md`, `SECURITY.md`,
`VISION.md`, `CHANGES.md`, this plan

Require exact matching, symmetric tests, portable execution, cleanup, and
truthful verification while replacing obsolete case-insensitive guidance.

## Scope Boundaries

- Do not change path constants, payload formats or limits, replay identity,
  listener export policy, activity flags, dependencies, Gradle, SDK levels, or
  user-visible strings.
- Do not claim paired-device, emulator, transport, or activity-launch runtime
  verification.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification

- Pending implementation and bounded validation.
