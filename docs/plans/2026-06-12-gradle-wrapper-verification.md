---
title: Gradle Wrapper Verification
date: 2026-06-12
status: completed
execution: code
---

# Gradle Wrapper Verification

## Summary

Regenerate and authenticate the checked-in Gradle wrapper while preserving the
existing checksum-verified `scripts/verified-gradle.sh` Make path, Gradle
2.2.1, Java 8, API 21, both mobile/Wear modules, and message behavior.

## Requirements

- Preserve the existing verified distribution script and Make integration.
- Retain Gradle 2.2.1, Android Gradle Plugin 1.1.0, API 21, build-tools 24.0.3,
  Google Play services 7.0.0, module layout, payload, timeout, and UI behavior.
- Regenerate wrapper artifacts with official Gradle 8.14.5 tooling, pin the
  official Gradle 2.2.1 all-distribution checksum, and verify exact artifacts.
- Add SDK-free contracts and document that both Make and direct wrapper paths
  authenticate the distribution but remain dependent on Gradle HTTPS when
  their caches are empty.
- Pass complete local and final exact-head hosted Android and CodeQL gates.

## Scope And Verification

This unit changes only the four wrapper files, static contracts, repository
guidance, and evidence. It does not remove or replace `verified-gradle.sh` and
does not change app, manifest, Gradle build files, workflow, or behavior.

Verification includes a fresh Java 8 wrapper bootstrap, incorrect-checksum
rejection, repository/external-cwd `make check`, focused hostile mutations,
and exact-head hosted checks.

## Sources

- [Gradle Wrapper documentation](https://docs.gradle.org/current/userguide/gradle_wrapper.html)
- [Gradle 2.2.1 checksum](https://services.gradle.org/distributions/gradle-2.2.1-all.zip.sha256)
- [Gradle 8.14.5 wrapper JAR checksum](https://services.gradle.org/distributions/gradle-8.14.5-wrapper.jar.sha256)

## Work Completed

- Regenerated all four direct wrapper files with official Gradle 8.14.5 tooling
  while retaining the Gradle 2.2.1 all distribution and Android runtime.
- Added the official distribution checksum and exact SDK-free contracts for
  the generated wrapper JAR, launchers, properties, documentation, and plan.
- Preserved the Makefile's independent `scripts/verified-gradle.sh` route and
  its existing official archive checksum contract.

## Verification Completed

- A fresh temporary Gradle user home downloaded and authenticated the official
  Gradle 2.2.1 distribution under Java 8.
- A disposable wrapper with an incorrect checksum was rejected before Gradle
  execution.
- SDK-backed `make check` passed for both mobile and Wear modules from the
  repository and an external working directory.
- Focused hostile mutations rejected wrapper properties, JAR, launcher,
  documentation, plan, and verified-launcher contract drift.
- `sh -n scripts/check-baseline.sh` and `git diff --check` passed.

## Hosted Verification

- Implementation head `4455ad63488c2b85188e668c8658ac16d9cb98cb` is pushed
  to PR #2, which is open and mergeable.
- A bounded exact-head query found pull-request `Check` run `27441664749` and
  CodeQL run `27441663521` queued on that implementation head.
- Tracker reconciliation remains pending until both canonical hosted events
  are terminal green on the same final head; no unbounded wait was started.
