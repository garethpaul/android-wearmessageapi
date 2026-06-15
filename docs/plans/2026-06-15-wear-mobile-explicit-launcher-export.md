# Wear Message Mobile Explicit Launcher Export Boundary

Status: Completed

## Problem

The Wear module already declares explicit policies for its private UI, launcher,
and listener service, but the handset module's sole `.MainActivity` launcher
omits `android:exported`. Legacy Android infers reachability, leaving one side
of the paired application implicit and blocking a future Android 12 target
upgrade without a manifest correction.

## Priorities

1. Preserve handset launch behavior while explicitly declaring the existing
   mobile entry point.
2. Add a mutation-sensitive structural contract for exactly one mobile export
   on the activity block containing `MAIN` and `LAUNCHER`.
3. Preserve every Wear activity/service export policy, message path, replay
   behavior, permissions, dependencies, and build input.

## Requirements

- Set `android:exported="true"` only on mobile `.MainActivity`.
- Require exactly one mobile export declaration and bind it to the named
  launcher block with both filter entries.
- Reject missing, false, duplicate, unrelated, or filter-detached declarations.
- Add maintained guidance and completed verification evidence.
- Keep repository and external-directory checks equivalent.

## Implementation Units

### 1. Declare mobile launcher reachability

**File:** `mobile/src/main/AndroidManifest.xml`

Add the explicit true attribute to the existing handset launcher only.

### 2. Enforce the mobile boundary

**File:** `scripts/check-baseline.sh`

Count export occurrences and require exactly one named activity block containing
the true export and both launcher entries. Keep existing Wear module contracts
unchanged.

### 3. Synchronize guidance

**Files:** `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`,
and this plan.

Document the paired mobile launcher boundary and completed verification.

## Verification

- Run POSIX shell syntax and the focused baseline.
- Run repository-root and external-directory `make check` with Java 8 and the
  configured Android SDK.
- Reject isolated missing, false, unrelated, filter-detached, same-line
  duplicate, duplicate-block, guidance, and incomplete-plan mutations.
- Audit exact paths, generated artifacts, conflict markers, dependency and
  workflow drift, whitespace, and credential-shaped additions.

## Risks

- Launch regression is controlled by binding the mobile activity name, true
  export, and both launcher entries in one structural block.
- Overexposure is controlled by requiring one mobile export occurrence.
- This PR is stacked on PR #13 and must retain base-first merge ordering.

## Out Of Scope

- Wear launcher, private activity, listener service, message paths, replay
  rollback, payload handling, and activity launch behavior.
- SDK, Gradle, Android plugin, dependency, permission, and target-SDK upgrades.
- Paired emulator/device transport, cold-start delivery, and live timeout
  execution.

## Completion Evidence

- POSIX shell syntax and the focused baseline passed.
- Repository-root and external-directory `make check` passed with Java 8 and
  the configured Android SDK, including mobile/wear debug and release unit
  tests, zero-issue lint, and debug assembly.
- Eight isolated mutations were rejected across missing, false, unrelated,
  filter-detached, same-line duplicate, duplicate-block, maintained-guidance,
  and completed-plan cases.
- Exact-path diff, generated-artifact, conflict-marker, dependency/workflow
  drift, whitespace, and credential-shaped-addition audits passed.
- No paired emulator/device transport, cold-start delivery, or live timeout
  behavior was exercised.
