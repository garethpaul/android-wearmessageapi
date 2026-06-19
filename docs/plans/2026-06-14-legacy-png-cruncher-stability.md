# Legacy PNG Cruncher Stability

Status: Completed

## Problem

The exact pull-request head passes the SDK-free baseline and then fails in
AGP 1.1.0's `QueuedCruncher` while processing a pinned Google Play Services
nine-patch resource. The failure is a null dereference inside the legacy
parallel cruncher rather than a source, replay, or resource-validation error.

## Requirements

1. Disable PNG crunching and the unstable queued implementation in both
   Android application modules through the AGP 1.1.0 `aaptOptions` DSL.
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

- The initial `cruncherEnabled = false` implementation passed local SDK-backed
  checks but exact-head hosted run `27495615389` still failed in
  `QueuedCruncher` while preprocessing a dependency nine-patch.
- AGP 1.1.0 bytecode inspection confirmed that dependency preprocessing also
  selects the queued implementation through the separate `useNewCruncher`
  option, which defaults to enabled.
- A fresh Gradle user home downloaded the pinned plugin and dependency graph,
  then rebuilt the previously failing `wear:mergeReleaseResources` path with
  both settings disabled; mobile and Wear debug/release lint reported zero
  issues.
- SDK-backed make check passed from the repository root and an external
  working directory, including both modules' debug/release JVM suites, the
  portable path tests, AAPT resource processing, and both debug APK assemblies.
- Eight hostile mutations were rejected across both modules' two settings,
  checker enforcement, completed plan evidence, and the README contract.
- Paired-device application behavior was not exercised because this change is
  limited to the build-time resource pipeline.
