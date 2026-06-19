# Security Policy

## Supported Versions

The supported security scope for `android-wearmessageapi` is the current default branch, `master`. Older commits, tags, branches, forks, demos, and generated artifacts are not actively supported unless the repository explicitly marks them as maintained.

Project summary: Android Wear Message API Sample

## Reporting a Vulnerability

Please report suspected vulnerabilities through GitHub's private vulnerability reporting or by opening a draft GitHub Security Advisory for `garethpaul/android-wearmessageapi` when that option is available. If GitHub does not show a private reporting option for this repository, contact the repository owner through GitHub and avoid posting exploit details publicly until the issue can be assessed.

Do not open a public issue that includes exploit code, secrets, personal data, or detailed reproduction steps for an unpatched vulnerability.

## What to Include

Helpful reports include:

- the affected file, endpoint, permission, dependency, or workflow
- a concise impact statement explaining what an attacker could do
- reproduction steps using test data and accounts you control
- the branch, commit SHA, platform version, device, runtime, or dependency versions used
- logs, screenshots, or proof-of-concept snippets that demonstrate impact without exposing private data

## Project Security Posture

- This repository appears to be an Android mobile application or sample. The active security scope is the code and documentation on the default branch.
- Review found network clients, sockets, web APIs, or service endpoints; changes in those areas should receive security-focused review before merge.
- Review found mobile permission or privacy-sensitive data handling; changes in those areas should receive security-focused review before merge.
- Review found file, document, data, or media parsing flows; changes in those areas should receive security-focused review before merge.
- Dependency manifests detected: build.gradle, gradle.properties. Dependency updates should preserve lockfiles when present and avoid introducing packages without a clear maintenance reason.
- Pinned, read-only GitHub Actions runs the guarded `make check` baseline;
  review workflow, Gradle, and checker changes as part of the supply-chain
  surface.
- Wear message payloads are bounded to 4096 bytes, and the listener service
  owns delivery so messages do not depend on activity registration timing.
- Strict UTF-8 Wear payloads are required before replay-state mutation or
  activity launch; malformed transport bytes are not replacement-decoded.
- A single-pass strict payload decode binds validation and delivered text to
  one captured payload array before replay tracking or activity launch.
- Wear listener rejects semantically blank payloads before replay recording or activity launch.
- The mobile explicit launcher export boundary is limited to .MainActivity and preserves its MAIN/LAUNCHER entry point.
- Wear listener dispatch requires exact canonical transport paths; case
  variants and suffix variants are rejected before activity launch.
- Documented activity launch failures are contained at the Wear listener
  boundary instead of terminating service message handling.
- Contained launch failures release only the matching replay reservation so
  redelivery can retry without clearing unrelated duplicate protection.
- Incoming Wear activity launches are limited per source node with a bounded monotonic in-process cooldown.
- Replay and rate-limit state are reserved atomically. Rejected rate admission
  cannot mark an undelivered request as replayed, and only the current pending
  launch token can roll its reservation back.
- Hosted checkout credentials are not persisted. Repository-wide CODEOWNERS
  and focused baseline checks cover CI, Gradle, wrapper, and module boundaries;
  repository rules should require owner approval and `Check / check`.
- Alternate manifests, packaged binaries, symlinks, hidden Gradle inputs, and
  `buildSrc` are rejected without freezing ordinary source and test edits.
- Hosted CI provisions pinned Java 8 and Android API 21 tooling and requires
  Gradle lint, unit tests, and debug assembly instead of accepting SDK skips.
- The handset releases both Google API connection callback registrations before disconnecting during activity teardown.
- The handset ignores queued Google API connection callbacks once its activity is finishing or destroyed.
- The Make targets download Gradle 2.2.1 from the official service and verify
  its published SHA-256 checksum before running any build logic.
- The exported Wear launcher strips external extras before opening the private
  message activity, which validates the bounded service payload again.
- The Wear listener service is explicitly exported for the single legacy
  Google Play services `BIND_LISTENER` action required for background data-layer
  delivery; manifest contracts reject additional listener actions.

## Mobile Privacy Notes

If this project requests device permissions such as location, camera, microphone, contacts, Bluetooth, health data, or local storage access, reports should describe the permission involved and whether sensitive data can be accessed, persisted, or transmitted unexpectedly. Please avoid testing against real third-party user data or accounts you do not control.

## Dependency and Supply Chain Security

The generated Gradle 8.14.5 bootstrap retains the legacy Gradle 2.2.1 runtime
required by Android Gradle Plugin 1.1.0. Review all four wrapper files together;
the SDK-free baseline rejects drift from Gradle's published wrapper JAR and
distribution SHA-256 values. Root Make targets remain independently routed
through `scripts/verified-gradle.sh`, which verifies the same official archive.
Both paths require Gradle HTTPS access when their caches are empty.

Both application modules disable PNG crunching and AGP 1.1.0's unstable queued
implementation. Resource packaging remains part of lint and debug assembly,
while avoiding hosted-build null failures on pinned Play Services
nine-patches.

Dependency updates should come from trusted package managers and should keep lockfiles in sync when lockfiles exist. Do not commit credentials, private keys, tokens, generated secrets, or machine-local configuration. If a vulnerability depends on a compromised package, typosquatting risk, insecure transitive dependency, or unsafe build step, include the package name, affected version, and the path through which it is used.

## Safe Research Guidelines

Good-faith research is welcome when it stays within these boundaries:

- use only accounts, devices, data, and infrastructure that you own or have explicit permission to test
- avoid destructive actions, persistence, spam, phishing, social engineering, or denial-of-service testing
- minimize access to personal data and stop testing immediately if private data is exposed
- do not exfiltrate secrets or third-party data; report the minimum evidence needed to verify impact
- keep vulnerability details confidential until the maintainer has assessed the report

## Maintainer Response

The maintainer will review complete reports as availability allows, prioritize issues by exploitability and impact, and coordinate a fix or mitigation when the affected code is still maintained. For sample, archived, or educational repositories, the likely remediation may be documentation, dependency updates, or clearly marking unsupported code rather than a production-style patch release.
