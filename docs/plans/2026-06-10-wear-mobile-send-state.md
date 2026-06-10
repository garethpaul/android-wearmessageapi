# Wear Mobile Send State

Status: Completed

## Goal

Make asynchronous mobile-to-watch sends truthful and race-safe so confirmed
delivery controls history and input cleanup without discarding newer edits.

## Requirements

- Allow only one mobile send in flight at a time.
- Disable the send button until the background operation completes.
- Always return success or failure to the UI, including disconnected clients,
  missing nodes, null results, and runtime failures.
- Keep connection-time `/start_activity` control sends outside user-message UI
  state.
- Show generic resource-backed feedback when no node accepts the message.
- Add outgoing history only after at least one paired node reports success.
- Clear the input only when its current normalized text still matches the sent
  message.
- Preserve all existing path, UTF-8, node, payload, and lifecycle guards.
- Cover the matching-input decision in both module test suites.

## Implementation

- Added a `messageSendInProgress` UI state and button enable/disable lifecycle.
- Routed every background exit through `completeMessageSend` with the aggregate
  send result for user messages while leaving control sends silent.
- Moved adapter updates from click time to confirmed completion.
- Added `WearMessage.shouldClearInput` to both modules with mirrored tests.
- Added generic send failure copy to mobile resources.
- Made `make check` location-independent, accepted either Android SDK variable,
  and pinned hosted verification with superseded-run cancellation.

## Verification

- `make check`
- `make -f /absolute/path/to/Makefile check` from outside the repository
- send-state, confirmed-history, matching-input, Makefile, and CI mutation checks
- `ANDROID_HOME=/path/to/android-sdk make check` (verified with API 21, zero
  mobile/wear lint issues, seven tests per module in debug and release, and
  both debug APK assemblies)
- `sh -n scripts/check-baseline.sh`
- `git diff --check`

The complete legacy build gate passes on this host. Paired-device delivery
behavior still requires a phone/watch emulator pair or physical devices using
the legacy Google Play services wearable API.
