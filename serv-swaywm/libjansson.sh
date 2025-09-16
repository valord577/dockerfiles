#!/usr/bin/env bash
set -e

LIBNAME='jansson'
VERSION='2.14'
LIBTEAM='debian'

curl --fail-with-body -sSL -o '1.tar.gz' \
  --url "https://salsa.debian.org/${LIBTEAM}/${LIBNAME}/-/archive/upstream/${VERSION}/${LIBNAME}-upstream-${VERSION}.tar.gz"
mkdir -p "/opt/src/${LIBNAME}"; tar -xvf "1.tar.gz" -C "/opt/src/${LIBNAME}" --strip-components=1 --no-same-owner


cmake_args=$(cat <<- EOF
                                  \
  -D JANSSON_WITHOUT_TESTS:BOOL=1 \
  -D JANSSON_BUILD_DOCS:BOOL=0    \
  -D JANSSON_EXAMPLES:BOOL=0      \
  -D JANSSON_STATIC_CRT:BOOL=1    \

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
