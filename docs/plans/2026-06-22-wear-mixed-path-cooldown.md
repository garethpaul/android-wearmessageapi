# Wear Mixed-Path Cooldown Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Allow one canonical `/start_activity` event and one canonical `/message` event from the same source inside the existing 500 ms window without weakening same-path cooldown or replay protection.

**Architecture:** Keep replay and pending identities keyed by normalized source plus request ID. Key the bounded cooldown limiter by normalized source plus exact canonical path, and carry that path in each reservation so rollback releases only the matching lane. Reject noncanonical paths before replay or cooldown state changes.

**Tech Stack:** Java 7-compatible Android source, portable host Java tests, POSIX shell, Python 3 repository contract checks.

---

### Task 1: Capture the regression in tests

**Files:**
- Modify: `scripts/MessageDeliveryGateHostTest.java`
- Modify: `wear/src/test/java/garethpaul/com/wearer/MessageDeliveryGateTest.java`
- Create: `scripts/test-wear-mixed-path-cooldown-contract.sh`
- Modify: `Makefile`

1. Add mixed-path forward and reverse ordering cases.
2. Add same-path abuse, replay, source isolation, rollback, bounded-cache, and canonical-path cases.
3. Assert strict UTF-8 validation still occurs before gate reservation in the listener.
4. Run the portable contract and confirm it fails against the source-only cooldown key.

### Task 2: Add canonical cooldown lanes

**Files:**
- Modify: `wear/src/main/java/garethpaul/com/wearer/MessageDeliveryGate.java`
- Modify: `wear/src/main/java/garethpaul/com/wearer/WearMessageListenerService.java`

1. Pass the accepted canonical path into `reserve`.
2. Reject noncanonical paths before replay mutation.
3. Use normalized source plus canonical path only for cooldown admission and rollback.
4. Preserve source plus request ID for replay and pending identities.
5. Run the narrow contract and all safe offline gates.

### Task 3: Add hostile mutation coverage

**Files:**
- Modify: `scripts/test-wear-delivery-gate-mutations.sh`

1. Mutate the cooldown key back to source-only.
2. Disable rate limiting.
3. Couple cooldown across sources.
4. Alias noncanonical paths.
5. Bypass replay protection.
6. Verify every mutation is rejected when a JDK is available and record the local toolchain limit otherwise.

### Task 4: Document and commit

**Files:**
- Modify: `README.md`
- Create outside checkout: `../report.md`

1. Document path-separated cooldown lanes and unchanged replay behavior.
2. Run source cleanliness and exact-parent checks.
3. Commit the focused candidate locally.
4. Record exact parent, head, tree, RED/GREEN evidence, limitations, and publication recommendation.
