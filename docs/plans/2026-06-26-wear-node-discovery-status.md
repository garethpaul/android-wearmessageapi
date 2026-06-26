# Wear Node Discovery Status Implementation Plan

**Status:** Completed

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Reject failed connected-node discovery results before the handset sender reads or iterates the node list.

**Architecture:** Keep the pinned `NodeApi` flow and add a fail-closed status guard at the discovery ownership point. Enforce its ordering with an SDK-free source contract and isolated hostile mutations.

**Tech Stack:** Java 7, legacy Google Play services Wearable API, POSIX shell, Python 3 source-contract tests, GNU Make

---

### Task 1: Add the failing discovery contract

**Files:**
- Create: `scripts/test-wear-node-discovery-status.sh`
- Modify: `Makefile`
- Modify: `scripts/check-baseline.sh`

**Step 1: Write the failing test**

Extract `sendMessage(...)` and require null, status, success, and node-list
guards before the first `nodes.getNodes()` iteration.

**Step 2: Run test to verify it fails**

Run: `scripts/test-wear-node-discovery-status.sh`

Expected: FAIL because the current sender does not validate discovery status.

### Task 2: Implement the minimal guard

**Files:**
- Modify: `mobile/src/main/java/garethpaul/com/wearer/MainActivity.java`

**Step 1: Guard discovery status**

Return when the result, status, or node list is missing, or when status is not
successful.

**Step 2: Run the focused contract**

Run: `scripts/test-wear-node-discovery-status.sh`

Expected: PASS.

### Task 3: Add mutations and guidance

**Files:**
- Create: `scripts/test-wear-node-discovery-status-mutations.sh`
- Modify: `Makefile`
- Modify: `scripts/check-baseline.sh`
- Modify: `AGENTS.md`
- Modify: `README.md`
- Modify: `SECURITY.md`
- Modify: `VISION.md`
- Modify: `CHANGES.md`

**Step 1: Add hostile mutations**

Reject removal of the status null check, success check, and ordering boundary.

**Step 2: Synchronize maintained guidance**

Document fail-closed node discovery without provider-detail logging.

### Task 4: Complete verification and delivery

**Files:**
- Modify: `docs/plans/2026-06-26-wear-node-discovery-status.md`

**Step 1: Run local gates**

Run focused tests, mutations, `make check`, external-Makefile `make check`,
shell syntax, and `git diff --check`.

**Step 2: Open and review the PR**

Push the exact head, open a PR against `master`, and invoke
`codex review --base origin/master`.

**Step 3: Merge only the green exact head**

Require hosted Android Check and CodeQL, verify policy and head SHA, then merge
with `--match-head-commit`.

## Verification Results

- The focused source contract failed before implementation because the sender
  did not validate connected-node discovery status.
- The focused contract passes after the inline guard rejects missing or
  unsuccessful status before node-list access.
- All three hostile mutations were rejected for removing the status null guard,
  accepting failure, and iterating before validation.
- Repository and external-Makefile `make check`, shell syntax, and whitespace
  checks passed.
- No local Android SDK was configured, so Gradle lint, tests, and debug assembly
  skipped pending hosted exact-head verification.
- Paired-device delivery was not exercised locally.
