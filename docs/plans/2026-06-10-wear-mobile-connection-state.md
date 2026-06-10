# Wear Mobile Connection State

Status: Completed

## Context

The mobile send button was enabled before the legacy `GoogleApiClient`
connected. Send completion also enabled it unconditionally, even when the Wear
connection suspended while a background send was running. Users could therefore
start requests that were guaranteed to fail against a disconnected client.

## Changes

- Register a `GoogleApiClient.OnConnectionFailedListener` alongside connection
  callbacks.
- Track callback-confirmed connection state explicitly instead of depending on
  client-state timing inside suspension callbacks.
- Keep one connection-aware button-state helper as the only enablement path.
- Require an active Wear connection before accepting a send click.
- Refresh button state after initialization, connection, suspension, failure,
  and user-send completion.
- Ignore a late connection callback after activity teardown.
- Extend the SDK-free baseline and project documentation with the connection
  lifecycle contract.

## Verification

- `make check`
- Static mutations for unconditional button enablement, missing connection
  failure registration, and a missing `onConnected` readiness transition
- `sh -n scripts/check-baseline.sh`
- `git diff --check`

The Android SDK is unavailable on this host, so paired-device connection state
still requires verification with a phone/watch emulator pair or physical
devices using the pinned legacy Google Play services API.
