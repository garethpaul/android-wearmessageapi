#!/usr/bin/env sh
set -eu

GRADLE_VERSION=2.2.1
GRADLE_DISTRIBUTION_URL="https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip"
GRADLE_DISTRIBUTION_SHA256="1d7c28b3731906fd1b2955946c1d052303881585fc14baedd675e4cf2bc1ecab"
GRADLE_CACHE_ROOT="${GRADLE_USER_HOME:-${HOME:?}/.gradle}/verified-distributions"
GRADLE_ARCHIVE="$GRADLE_CACHE_ROOT/gradle-${GRADLE_VERSION}-all.zip"
GRADLE_INSTALLATION="$GRADLE_CACHE_ROOT/gradle-${GRADLE_VERSION}"

mkdir -p "$GRADLE_CACHE_ROOT"

if [ ! -x "$GRADLE_INSTALLATION/bin/gradle" ]; then
  if [ ! -f "$GRADLE_ARCHIVE" ] ||
     [ "$(sha256sum "$GRADLE_ARCHIVE" | awk '{print $1}')" != "$GRADLE_DISTRIBUTION_SHA256" ]; then
    download="$GRADLE_ARCHIVE.download.$$"
    trap 'rm -f "$download"' EXIT HUP INT TERM
    curl --fail --location --silent --show-error "$GRADLE_DISTRIBUTION_URL" --output "$download"
    if [ "$(sha256sum "$download" | awk '{print $1}')" != "$GRADLE_DISTRIBUTION_SHA256" ]; then
      printf '%s\n' "Gradle distribution checksum verification failed." >&2
      exit 1
    fi
    mv "$download" "$GRADLE_ARCHIVE"
    trap - EXIT HUP INT TERM
  fi

  rm -rf "$GRADLE_INSTALLATION"
  unzip -q "$GRADLE_ARCHIVE" -d "$GRADLE_CACHE_ROOT"
fi

exec "$GRADLE_INSTALLATION/bin/gradle" "$@"
