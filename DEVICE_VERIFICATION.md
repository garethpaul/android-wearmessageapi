# Android Wear Message Device Verification Matrix

Use this matrix only for an exact implementation commit. Record the commit SHA and pull request
before testing so mobile, Wear, Data Layer, replay, and launch evidence cannot
be transferred to a different implementation.

## Evidence Rules

- Use a synthetic payload that contains no personal, account, health, location,
  or business-sensitive information.
- Record the Android SDK, API levels, mobile and Wear device or emulator classes,
  pairing state, Play services versions, result, and evidence identifier.
- Do not include node identifiers, device serials, payload dumps, account names,
  unrelated notifications, or raw diagnostic output.
- Store durable evidence outside git. Link only a sanitized run, screenshot, or
  short log excerpt by stable identifier.
- Record each result as `pass`, `fail`, `blocked`, or `not run`, with an owner
  and follow-up for every result other than `pass`.
- Do not convert `not run` into passing evidence.

## Pairing Prerequisites

- Build both modules from the same exact commit. Their manifests use the same application ID, `garethpaul.com.wearer`.
- Install mobile and Wear APKs produced with a matching signing certificate; the same package name with different signing identities cannot use the app-private Data Layer channel.
- The mobile module declares `wearApp project(':wear')`; confirm the matching Wear app is installed through the supported companion flow or directly on the paired emulator when that legacy packaging flow is unavailable.
- Pair the handset and Wear target through a platform-supported companion or emulator flow with compatible Google Play services Data Layer support.
- Launch both apps and confirm the mobile `GoogleApiClient` reaches its connected state before attempting a send.
- Do not treat successful installation as Data Layer connection evidence.
- Use only a synthetic payload and retain the privacy-safe evidence rules below for every run.

## Run Identity

| Field | Value |
| --- | --- |
| Commit SHA | `not run` |
| Pull request | `not run` |
| Android SDK / APIs | `not run` |
| Mobile device / emulator | `not run` |
| Wear device / emulator | `not run` |
| Play services versions | `not run` |
| Pairing / connectivity | `not run` |
| Synthetic payload | `not run` |
| Evidence location | `not run` |

## Verification Matrix

| Scenario | Expected evidence | Result | Evidence |
| --- | --- | --- | --- |
| Paired connection | Mobile and Wear clients connect through the platform APIs before controls become active. | `not run` | `not run` |
| Mobile to Wear message | A synthetic `/message` payload reaches the Wear listener and renders once. | `not run` | `not run` |
| Wear to mobile start | A canonical `/start_activity` event opens only the intended mobile activity flow. | `not run` | `not run` |
| Canonical `/message` path | Near-match, missing, and null paths do not enter Wear message delivery. | `not run` | `not run` |
| Canonical `/start_activity` path | Near-match, missing, and null paths do not trigger mobile activity launch. | `not run` | `not run` |
| Malformed UTF-8 | Invalid bytes are rejected before replay state or UI delivery. | `not run` | `not run` |
| Blank semantic payload | Empty or whitespace-only decoded text is rejected before replay recording or launch. | `not run` | `not run` |
| Duplicate replay | Repeating the same source/request event does not launch or render twice after success. | `not run` | `not run` |
| Activity-not-found launch | Missing activity handling is contained without crashing the listener. | `not run` | `not run` |
| Security-rejected launch | Security rejection is contained without broadening accepted paths or payloads. | `not run` | `not run` |
| Redelivery after launch failure | Only the matching replay reservation is released so a valid retry can deliver. | `not run` | `not run` |
| Disconnect during send | Typed text remains available and the send reports failure without false history. | `not run` | `not run` |
| Reconnect and retry | Reconnection permits a later send while preserving newer input edits. | `not run` | `not run` |
| Rapid repeated sends | One send remains in flight and history records only accepted deliveries. | `not run` | `not run` |
| Process relaunch | Mobile and Wear relaunch without stale replay, payload, history, or launch ownership. | `not run` | `not run` |

## Current Status

No mobile or Wear emulator, paired device, Wear Data Layer connection, Play
services runtime, or live UI scenario was executed for this checklist. Treat every mobile, Wear, Data Layer, and UI row as unexecuted
until evidence is attached to the exact commit.
