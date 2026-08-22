#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

DIST=stable
REPO=hyperotter
GPG_KEY_UID="HyperOtter Packages"
export APTLY_CONFIG="aptly/aptly.conf"

aptly repo create -distribution="$DIST" -component=main "$REPO" 2>/dev/null || true

shopt -s nullglob
for deb in incoming/apt/*.deb; do
  aptly repo add "$REPO" "$deb"
done
shopt -u nullglob

aptly publish drop "$DIST" 2>/dev/null || true
aptly publish repo -gpg-key="$GPG_KEY_UID" -batch=true "$REPO" "$DIST"
