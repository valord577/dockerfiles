#!/usr/bin/env bash
set -e

LIBNAME='pcre2'
VERSION='10.46'
LIBTEAM='debian'

curl --fail-with-body -sSL -o '1.tar.gz' \
  --url "https://salsa.debian.org/${LIBTEAM}/${LIBNAME}/-/archive/${VERSION}/${LIBNAME}-${VERSION}.tar.gz"
mkdir -p "/opt/src/${LIBNAME}"; tar -xvf "1.tar.gz" -C "/opt/src/${LIBNAME}" --strip-components=1 --no-same-owner

cmake_args=$(cat <<- EOF
                                  \
  -D PCRE2_STATIC_PIC:BOOL=1      \
  -D PCRE2_BUILD_TESTS:BOOL=0     \
  -D PCRE2_BUILD_PCRE2GREP:BOOL=0 \
  -D PCRE2_STATIC_RUNTIME:BOOL=1  \

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
