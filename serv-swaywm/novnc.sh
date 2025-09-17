#!/usr/bin/env bash
set -e

LIBNAME='novnc'
VERSION='v1.6.0'

curl --fail-with-body -sSL -o '1.tar.gz' \
  --url "https://salsa.debian.org/openstack-team/third-party/${LIBNAME}/-/archive/${VERSION}/${LIBNAME}-${VERSION}.tar.gz"
mkdir -p "${STAGING}/opt/novnc"; tar -xvf '1.tar.gz' -C "${STAGING}/opt/novnc" --strip-components=1 --no-same-owner
