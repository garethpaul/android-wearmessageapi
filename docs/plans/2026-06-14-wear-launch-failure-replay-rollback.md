# Wear Launch Failure Replay Rollback

Status: Completed

## Problem

The Wear listener reserves each source/request identity before opening the
private activity. If that launch throws `ActivityNotFoundException` or
`SecurityException`, the new failure isolation contains the exception but
leaves the identity reserved. A later redelivery of the same valid transport
event is then suppressed even though no activity received it.

## Requirements

1. Keep replay reservation before activity launch so concurrent duplicate
   callbacks remain suppressed.
2. Remove only the matching source/request reservation when a documented
   activity-launch failure occurs.
3. Retain successful-launch identities and all existing path, payload, replay,
   activity flag, and export-policy behavior.
4. Add focused unit and mutation-sensitive static coverage for exact rollback
   ownership and both listener delivery paths.
5. Run the full SDK-backed gate from the repository root and an unrelated
   working directory.

## Scope Boundaries

- Do not broaden caught exceptions or accepted transport inputs.
- Do not change cache capacity, eviction order, payload limits, paths, flags,
  manifests, dependencies, or user-visible text.
- Do not claim paired-device or injected platform-failure runtime coverage.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification

- Focused Wear debug and release JVM suites passed with exact reservation
  rollback and unrelated-identity retention coverage.
- Eight hostile mutations were rejected for missing or broad identity removal,
  inverted launch handling, omitted rollback, startup-path bypass, removed test
  or documentation coverage, and reopened plan status.
- SDK-backed `make check` passed from the repository root and an unrelated
  working directory, including zero-issue mobile/Wear lint, both modules'
  debug/release JVM suites, the portable canonical-path tests, and both debug
  APK assemblies.
- Paired-device delivery and injected platform launch failures were not
  exercised.
