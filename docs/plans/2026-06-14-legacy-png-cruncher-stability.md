# Legacy PNG Cruncher Stability

Status: Completed

## Problem

The exact pull-request head passes the SDK-free baseline and then fails in
AGP 1.1.0's `QueuedCruncher` while processing a pinned Google Play Services
nine-patch resource. The failure is a null dereference inside the legacy
parallel cruncher rather than a source, replay, or resource-validation error.

## Requirements

1. Disable only the unstable legacy PNG cruncher in both Android application
   modules through the AGP 1.1.0 `aaptOptions` DSL.
2. Keep AAPT resource packaging, lint, JVM tests, and debug APK assembly in the
   full gate.
3. Add a static contract that rejects either module re-enabling or omitting the
   setting.
4. Verify the full SDK-backed gate from the repository root and an unrelated
   external working directory.
5. Reject focused hostile mutations of the two-module setting, checker, plan,
   and documentation contract.

## Scope Boundaries

- Do not change the pinned Android plugin, Gradle, SDK, build-tools, or Google
  Play Services versions.
- Do not skip resource processing, lint, tests, or assembly.
- Do not alter application behavior, dependencies, manifests, or resources.
- Do not merge or close the stacked pull request without explicit
  authorization.

## Verification

- AGP 1.1.0's installed DSL bytecode was inspected and confirmed that
  `cruncherEnabled` is a native boolean option that defaults to enabled.
- SDK-backed make check passed from the repository root and an external
  working directory, including zero-issue lint, both modules' debug/release
  JVM suites, AAPT resource processing, and both debug APK assemblies.
- The first focused SDK-backed lint run executed the previously failing
  `wear:mergeReleaseResources` path successfully with the cruncher disabled.
- Six hostile mutations were rejected for removing or re-enabling either
  module setting, weakening the checker, reopening the plan, and removing the
  documented build contract.
- Paired-device application behavior was not exercised because this change is
  limited to the build-time resource pipeline.
