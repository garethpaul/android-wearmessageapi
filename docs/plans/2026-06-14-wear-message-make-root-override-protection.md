# Wear Message Make Root Override Protection

Status: Completed

## Problem

GNU Make command-line variables can override the ordinary repository-root
assignment and redirect baseline and verified-Gradle commands away from the
reviewed checkout.

## Requirements

1. Protect the Makefile-derived root with GNU Make's `override` directive.
2. Preserve SDK overrides, the verified Gradle launcher override, every target,
   skip condition, and existing task.
3. Require exact protected-root/tool semantics and complete rooted baseline,
   lint, test, and build commands.
4. Pass local, external-directory, and hostile-root `make check` gates.
5. Reject root, tool, path, environment, task, and completed-plan mutations.

## Verification

- Run shell syntax and the dependency-free checker.
- Run local, external-directory, and hostile-root full gates.
- Run focused mutations and structured-file, artifact, whitespace, conflict,
  exact-diff, and credential audits.

## Scope Boundaries

- Do not change Wear payload decoding, UTF-8 validation, replay handling,
  listener semantics, dependencies, workflows, sources, or resources.
- Do not weaken the verified Gradle launcher or wrapper contracts.
- Do not claim SDK/device verification when unavailable.
- Do not merge or close pull requests without owner authorization.

## Work Completed

- Protected the derived root while preserving SDK and verified-Gradle
  configurability, all targets, tasks, and skip conditions.
- Added exact protected variable, baseline, Gradle command, and plan contracts.

## Verification Results

- Focused checker and shell syntax passed.
- Local, external-directory, and hostile-root `make check` passed while
  remaining anchored to this checkout; SDK-backed tasks truthfully skipped.
- All twelve root, tool, path, environment, task, launcher, and plan mutations
  were rejected.
- Structured-file, artifact, conflict-marker, whitespace, exact-diff, and
  credential audits passed across only the three intended files.
