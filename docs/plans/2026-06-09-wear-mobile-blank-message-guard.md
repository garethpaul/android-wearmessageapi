# Wear Mobile Blank Message Guard

status: completed

## Context

The mobile send button checked `TextUtils.isEmpty` after converting the input
editable to a string. That still allowed whitespace-only messages through and
assumed the editable value was always present before the empty-message guard.

## Plan

- Add a shared `WearMessage.normalizeText` helper in both mobile and wear
  modules so message input normalization stays consistent.
- Route mobile send-button input through the helper before the empty-message
  check.
- Cover null, blank, and trimmed text normalization in both module test suites.
- Extend the SDK-free baseline and README so the blank-message contract remains
  visible.

## Verification

- `scripts/check-baseline.sh`
- `git diff --check`
- `make check`
