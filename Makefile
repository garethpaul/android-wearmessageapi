.PHONY: build check lint test verify

ANDROID_HOME ?=
ANDROID_SDK_ROOT ?=
override ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
ANDROID_SDK := $(if $(ANDROID_HOME),$(ANDROID_HOME),$(ANDROID_SDK_ROOT))
GRADLE ?= $(ROOT)scripts/verified-gradle.sh

lint:
	$(ROOT)scripts/check-baseline.sh
	@if [ -n "$(ANDROID_SDK)" ] && [ -d "$(ANDROID_SDK)" ]; then \
		cd $(ROOT) && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" $(GRADLE) lint --no-daemon; \
	else \
		echo "Android SDK not configured; Gradle lint skipped."; \
	fi

test:
	$(ROOT)scripts/test-wear-mixed-path-cooldown-contract.sh
	$(ROOT)scripts/test-wear-mixed-path-source-mutations.sh
	$(ROOT)scripts/test-wear-message-paths.sh
	$(ROOT)scripts/test-wear-message-send-deadline.sh
	$(ROOT)scripts/test-wear-node-discovery-status.sh
	$(ROOT)scripts/test-wear-node-discovery-status-mutations.sh
	$(ROOT)scripts/test-wear-delivery-rate-limiter.sh
	$(ROOT)scripts/test-wear-delivery-gate.sh
	$(ROOT)scripts/test-wear-delivery-gate-mutations.sh
	@if [ -n "$(ANDROID_SDK)" ] && [ -d "$(ANDROID_SDK)" ]; then \
		cd $(ROOT) && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" $(GRADLE) test --no-daemon; \
	else \
		echo "Android SDK not configured; Gradle tests skipped."; \
	fi

build:
	@if [ -n "$(ANDROID_SDK)" ] && [ -d "$(ANDROID_SDK)" ]; then \
		cd $(ROOT) && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" $(GRADLE) assembleDebug --no-daemon; \
	else \
		echo "Android SDK not configured; Gradle build skipped."; \
	fi

verify: lint test build

check: verify
