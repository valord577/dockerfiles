#!/usr/bin/env sh
set -e

MINGW_ROOT="/opt/toolchain/llvm-mingw"; mkdir -p "${MINGW_ROOT}"

filename="llvm-mingw-${MINGW_VERSION}-${MINGW_DEFAULT}-$(uname -m)"
_DOWNLOAD_URL_="${MINGW_URL}/${MINGW_VERSION}/${filename}.tar.xz"
curl --fail-with-body -sSL -o "${filename}.tar.xz" --url "${_DOWNLOAD_URL_}"


tar -xf "${filename}.tar.xz" -C "${MINGW_ROOT}" --strip-components=1 --no-same-owner \
  --wildcards \
    "${filename}/bin/aarch64-w64-mingw32-*"     \
    "${filename}/bin/x86_64-w64-mingw32-*"      \
    "${filename}/bin/clang-target-wrapper.sh"   \
    "${filename}/bin/gendef"                    \
    "${filename}/bin/ld-wrapper.sh"             \
    "${filename}/bin/objdump-wrapper.sh"        \
  --exclude="${filename}/bin/*-widl"            \
  --exclude="${filename}/bin/*-clang-scan-deps" \
    "${filename}/generic-w64-mingw32"           \
  --exclude="${filename}/generic-w64-mingw32/include/*.idl" \
    "${filename}/aarch64-w64-mingw32/include"   \
    "${filename}/aarch64-w64-mingw32/lib"       \
    "${filename}/lib/clang/19/lib/windows/libclang_rt.builtins-aarch64.a" \
  --exclude="${filename}/aarch64-w64-mingw32/lib/libc++.modules.json"     \
    "${filename}/x86_64-w64-mingw32/include"    \
    "${filename}/x86_64-w64-mingw32/lib"        \
    "${filename}/lib/clang/19/lib/windows/libclang_rt.builtins-x86_64.a"  \
  --exclude="${filename}/x86_64-w64-mingw32/lib/libc++.modules.json"      \


# ----------------------------
rm -f -- ${filename}.tar.xz
