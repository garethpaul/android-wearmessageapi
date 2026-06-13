# AGENTS.md

## Repository purpose

`garethpaul/android-wearmessageapi` is an Android application or sample. Android Wear Message API Sample

## Project structure

- `Makefile` - repository verification targets
- `scripts` - baseline checks and helper scripts
- `docs` - plans, notes, and generated README assets
- `build.gradle` - Gradle build configuration
- `scripts/verified-gradle.sh` - checksum-verifying Gradle launcher used by Make
- `gradlew`, `gradle` - legacy wrapper artifacts retained for project history
- `mobile` - handset application that sends messages and packages `:wear`
- `wear` - wearable application and listener service that receives messages

## Development commands

- Install dependencies: no repository-specific install command is documented.
- Repository gate: `make check` (SDK-free when neither Android SDK variable is configured)
- Combined verification: `make verify`
- Lint/static checks: `make lint`
- Tests: `make test`
- Build: `make build`
- Android unit tests when the SDK is configured: `make test`
- Android debug build when the SDK is configured: `make build`
- If a command above skips because a platform toolchain is missing, verify on a machine with that SDK before claiming platform behavior is tested.

## Coding conventions

- Use the Make targets so builds run through `scripts/verified-gradle.sh`.

## Testing guidance

- JVM unit tests: `mobile/src/test/`, `wear/src/test/`
- Device/emulator instrumentation smoke test: `mobile/src/androidTest/`
- Start with the narrowest relevant test or Make target, then run `make check` before handing off if the change is not documentation-only.
- Keep README verification notes in sync when commands, fixtures, or supported toolchains change.

## PR / change guidance

- Keep diffs focused on the requested repository and avoid unrelated modernization or formatting churn.
- Preserve public APIs, sample behavior, file formats, and documented environment variables unless the task explicitly changes them.
- Update tests, README notes, or docs/plans when behavior, security posture, or validation commands change.
- Call out skipped platform validation, legacy toolchain assumptions, and any risky files touched in the final summary.

## Safety and gotchas

- No required secret or credential file was identified in the repository scan. If you add integrations later, keep secrets out of git.
- This looks like a legacy Android project or sample. Expect Android SDK, Gradle, and support-library versions to matter.
- Message path, payload, connection-state, and lifecycle contracts are documented in `README.md` and enforced by `scripts/check-baseline.sh`.
- The Wear listener service owns `/message` delivery and routes bounded payloads to a single activity instance; do not restore activity-listener timing dependence.
- Validate strict UTF-8 Wear payloads before replay-state mutation or activity
  delivery; malformed bytes must not be replacement-decoded and displayed.
- Preserve the listener's single-pass strict payload decode over one captured
  byte array before replay tracking or activity delivery.
- Keep connected-node lookup and every per-node message send bounded by the shared five-second timeout; do not restore unbounded `PendingResult.await()` calls.

## Agent workflow

1. Inspect the README, Makefile, manifests, and the files directly related to the request.
2. Make the smallest source or docs change that satisfies the task; avoid generated, vendored, or local-environment files unless required.
3. Run the narrowest useful validation first, then `make check` or the documented package/platform gate when available.
4. If a required SDK, service credential, or external runtime is unavailable, record the skipped command and why.
5. Summarize changed files, commands run, and remaining risks or follow-up validation.
