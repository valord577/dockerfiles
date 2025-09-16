#!/usr/bin/env bash
set -e

LIBNAME='libffi'
VERSION='3.5.2'

curl --fail-with-body -sSL -o '1.tar.gz' \
  --url "https://mirrors.bfsu.edu.cn/debian/pool/main/libf/${LIBNAME}/${LIBNAME}_${VERSION}.orig.tar.gz"
mkdir -p "/opt/src/${LIBNAME}"; tar -xvf "1.tar.gz" -C "/opt/src/${LIBNAME}" --strip-components=1 --no-same-owner

cd "/opt/src/${LIBNAME}"

./autogen.sh
./configure \
  --prefix='/usr/local' \
  --disable-docs        \
  --with-pic=yes        \
  --enable-shared=no    \
  --disable-dependency-tracking
make -j $(nproc); make install
