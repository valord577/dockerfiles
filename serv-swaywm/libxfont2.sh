#!/usr/bin/env bash
set -e

LIBNAME='libxfont'
VERSION='libXfont2-2.0.7'

curl --fail-with-body -sSL -o '1.tar.gz' \
  --url "https://gitlab.freedesktop.org/xorg/lib/${LIBNAME}/-/archive/${VERSION}/${LIBNAME}-${VERSION}.tar.gz"
mkdir -p "/opt/src/${LIBNAME}"; tar -xvf "1.tar.gz" -C "/opt/src/${LIBNAME}" --strip-components=1 --no-same-owner

cd "/opt/src/${LIBNAME}"

NOCONFIGURE=1 ./autogen.sh
./configure \
  --prefix="${STAGING}" \
  --enable-pic=yes      \
  --enable-static=no    \
  --enable-year2038     \
  --disable-dependency-tracking
make -j $(nproc); make install
