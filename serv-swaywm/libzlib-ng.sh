#!/usr/bin/env bash
set -e

LIBNAME='zlib-ng'
VERSION='2.2.5'

curl --fail-with-body -sSL -o '1.tar.gz' \
  --url "https://github.com/zlib-ng/${LIBNAME}/archive/refs/tags/${VERSION}.tar.gz"
mkdir -p "/opt/src/${LIBNAME}"; tar -xvf "1.tar.gz" -C "/opt/src/${LIBNAME}" --strip-components=1 --no-same-owner

cmake_args=$(cat <<- EOF
                                \
  -D WITH_OPTIM:BOOL=1          \
  -D ZLIB_COMPAT:BOOL=1         \
  -D WITH_GTEST:BOOL=0          \
  -D WITH_GZFILEOP:BOOL=0       \
  -D ZLIB_ENABLE_TESTS:BOOL=0   \
  -D ZLIBNG_ENABLE_TESTS:BOOL=0 \

EOF
)
cmake -G Ninja \
  -D CMAKE_INSTALL_PREFIX='/usr/local' \
  -D CMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON \
  -D CMAKE_INSTALL_LIBDIR:PATH=lib \
  -D BUILD_SHARED_LIBS:BOOL=0      \
  -D BUILD_STATIC_LIBS:BOOL=1      \
  -D CMAKE_BUILD_TYPE=Release      \
  ${cmake_args} -B "/opt/tmp/${LIBNAME}" -S "/opt/src/${LIBNAME}"
cmake --build   "/opt/tmp/${LIBNAME}" -j $(nproc)
cmake --install "/opt/tmp/${LIBNAME}" --strip
