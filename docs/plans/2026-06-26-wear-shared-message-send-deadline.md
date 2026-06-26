# Wear Shared Message Send Deadline

Status: Completed

## Problem

Connected-node lookup was bounded, and each per-node send was bounded, but every
node received a fresh five-second wait. Total sender-thread lifetime could
therefore scale with the number of connected nodes.

## Decision

Start one monotonic five-second deadline before node lookup. The lookup may use
that full budget; every per-node send receives only the remaining nanoseconds.
Stop attempting additional nodes when the shared budget expires.

## Verification

- The portable host test failed first because the deadline helper was absent.
- `scripts/test-wear-message-send-deadline.sh`
- `make check`
- External-directory `make check`
- Shared-budget source and host-test hostile mutations.
- Android device and paired-Wear execution remain unverified locally.
- Repository and external-directory `make check`, shell syntax, and diff checks passed.
- Two isolated hostile mutations failed for the intended reason.
- Exact-head Check run `28251310730` passed the SDK-backed gate; CodeQL run
  `28251308824` passed Actions and Java/Kotlin analysis.
- Codex review failed before analysis with OpenAI API HTTP 401; immutable
  exact-head manual review found no actionable findings.
