# Android Wear Message Device Verification Checklist

Status: Completed

## Problem

Portable contracts cover canonical paths, strict and single-pass payload
decoding, semantic validation, replay suppression, launch-failure isolation,
and rollback, but no checklist defines repeatable paired-device or emulator
evidence for the exact implementation commit.

## Requirements

1. Add an exact-commit matrix for mobile-to-Wear delivery, Wear-to-mobile
   delivery, canonical paths, payload failures, replay, launch failures,
   lifecycle, disconnects, and relaunch.
2. Require synthetic payloads and sanitized toolchain, device pair, result,
   and evidence fields.
3. Keep repository checks separate from unexecuted Android, Wear Data Layer,
   paired-device, and UI scenarios.
4. Add mutation-sensitive contracts for the checklist and completion evidence.

## Scope Boundaries

- Do not change message paths, payload semantics, replay ownership, Android
  SDK, Gradle plugin, dependencies, or launch behavior.
- Do not add real messages, account data, node identifiers, device serials,
  payload dumps, screenshots, logs, APKs, or local configuration.
- Do not claim emulator, paired-device, Data Layer, or live UI execution from
  portable or build-time checks.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification

- `sh -n scripts/check-baseline.sh` and the focused baseline checker passed.
- `make check` passed from the repository and from an external working
  directory with the available Android API 22 toolchain.
- Twelve hostile mutations were rejected by the checklist's static contracts.
- The Android SDK was used only for build-time lint, tests, and assembly.
- No mobile or Wear emulator, paired device, Wear Data Layer connection, Play services runtime, or live UI scenario was executed;
  every runtime matrix row remains `not run`.
