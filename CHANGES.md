# Android Wear Message API Changes

## 2026-06-08

- Added null text and null payload handling to both mobile and wear
  `WearMessage` contracts, with matching unit coverage in each module.
- Added `make check` as the SDK-free verification wrapper.
- Cleaned the mobile and wear lint gates by removing starter resources, moving wear background ownership into a theme, and adding resource-backed mobile input labels.
- Added narrow lint configurations for the legacy SDK, pinned Play Services, and API-database warnings.
- Documented and enforced the lint, unit test, and debug assemble verification path.
