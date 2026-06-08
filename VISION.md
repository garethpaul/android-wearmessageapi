## Android Wear Message API Vision

Android Wear Message API is a legacy mobile-and-watch sample for sending text
messages between an Android handheld app and a Wear app through Google Play
services wearable APIs.

The repository is useful as a compact example of paired mobile/wear modules,
message paths, and wearable listener services in the Android Wear era.

The goal is to keep the sample understandable while making future wearable API
and build modernization explicit.

The current focus is:

Priority:

- Preserve the mobile-to-wear message flow and `/message` path behavior
- Keep the watch activity launch path easy to inspect
- Avoid changing Google Play services dependencies without documenting impact
- Maintain the two-module project structure

Next priorities:

- Pin or modernize dynamic Google Play services dependencies
- Add tests or manual verification notes for message send/receive behavior
- Update Gradle, SDK levels, and wearable APIs in a dedicated pass
- Document device or emulator pairing requirements

Contribution rules:

- One PR = one focused wearable, build, or documentation change.
- Verify both mobile and wear modules when changing message behavior.
- Keep message path constants and listener behavior easy to review.
- Document dependency and SDK changes clearly.

## Security And Privacy

Messages sent between devices may contain personal text. Do not add logging,
analytics, or network forwarding of message payloads without explicit
documentation and user control.

Wearable connection behavior should remain scoped to paired devices through the
platform APIs.

## What We Will Not Merge (For Now)

- Silent forwarding of wearable messages to external services
- Broad wearable API migrations without paired-device verification notes
- Dynamic dependency changes that make builds non-reproducible
- Module restructuring that hides the mobile/wear message flow

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
