#!/usr/bin/env sh
set -e

mkdir -p "${CMAKE_ROOT}"

filename="cmake-${CMAKE_X}.${CMAKE_Y}.${CMAKE_Z}-linux-$(uname -m)"
_DOWNLOAD_URL_="${CMAKE_URL}/v${CMAKE_X}.${CMAKE_Y}/${filename}.tar.gz"
curl --fail-with-body -sSL -o "${filename}.tar.gz" --url "${_DOWNLOAD_URL_}"


tar -xf "${filename}.tar.gz" -C "${CMAKE_ROOT}" --strip-components=1 --no-same-owner \
  --wildcards \
    "${filename}/bin/cmake"     \
    "${filename}/bin/cpack"     \
    "${filename}/bin/ctest"     \
    "${filename}/share/cmake-${CMAKE_X}.${CMAKE_Y}" \


# ----------------------------
rm -rf ${filename}.tar.gz
