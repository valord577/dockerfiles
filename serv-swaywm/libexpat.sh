#!/usr/bin/env bash
set -e

LIBNAME='libexpat'
VERSION='R_2_7_3'

curl --fail-with-body -sSL -o '1.tar.gz' \
  --url "https://github.com/libexpat/${LIBNAME}/archive/refs/tags/${VERSION}.tar.gz"
mkdir -p "/opt/src/${LIBNAME}"; tar -xvf "1.tar.gz" -C "/opt/src/${LIBNAME}" --strip-components=1 --no-same-owner

cmake_args=$(cat <<- EOF
                                     \
  -D EXPAT_SHARED_LIBS:BOOL=0        \
  -D EXPAT_WARNINGS_AS_ERRORS:BOOL=1 \
  -D EXPAT_MSVC_STATIC_CRT:BOOL=1    \
  -D EXPAT_BUILD_TOOLS:BOOL=0        \
  -D EXPAT_BUILD_EXAMPLES:BOOL=0     \
  -D EXPAT_BUILD_TESTS:BOOL=0        \
  -D EXPAT_BUILD_DOCS:BOOL=0         \
  -D EXPAT_BUILD_FUZZERS:BOOL=0      \
  -D EXPAT_OSSFUZZ_BUILD:BOOL=0      \
  -D EXPAT_WITH_LIBBSD:BOOL=0        \

EOF
)
cmake -G Ninja \
  -D CMAKE_INSTALL_PREFIX='/usr/local' \
  -D CMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON \
  -D CMAKE_INSTALL_LIBDIR:PATH=lib \
  -D BUILD_SHARED_LIBS:BOOL=0      \
  -D BUILD_STATIC_LIBS:BOOL=1      \
  -D CMAKE_BUILD_TYPE=Release      \
  ${cmake_args} -B "/opt/tmp/${LIBNAME}" -S "/opt/src/${LIBNAME}/expat"
cmake --build   "/opt/tmp/${LIBNAME}" -j $(nproc)
cmake --install "/opt/tmp/${LIBNAME}" --strip
