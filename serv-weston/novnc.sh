#!/usr/bin/env bash
set -e

LIBNAME='noVNC'
VERSION='v1.7.0'

curl --fail-with-body -sSL -o '1.tar.gz' \
  --url "${GITHUB_PROXY}https://github.com/novnc/${LIBNAME}/archive/refs/tags/${VERSION}.tar.gz"
mkdir -p "${STAGING}/opt/novnc"; tar -xvf '1.tar.gz' -C "${STAGING}/opt/novnc" --strip-components=1 --no-same-owner



LIBNAME='websockify'
VERSION='v0.13.0'

curl --fail-with-body -sSL -o '1.tar.gz' \
  --url "${GITHUB_PROXY}https://github.com/novnc/${LIBNAME}/archive/refs/tags/${VERSION}.tar.gz"
mkdir -p "${STAGING}/opt/websockify"; tar -xvf '1.tar.gz' -C "${STAGING}/opt/websockify" --strip-components=1 --no-same-owner
