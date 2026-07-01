#!/usr/bin/env sh
set -e

MINGW_ROOT="/opt/toolchain/llvm-mingw"; mkdir -p "${MINGW_ROOT}"

filename="llvm-mingw-${MINGW_VERSION}-${MINGW_DEFAULT}-$(uname -m)"
_DOWNLOAD_URL_="${MINGW_URL}/${MINGW_VERSION}/${filename}.tar.xz"
curl --fail-with-body -sSL -o "${filename}.tar.xz" --url "${_DOWNLOAD_URL_}"


extractor="tar -xvf '${filename}.tar.xz' -C '${MINGW_ROOT}' --strip-components=1 --no-same-owner '${filename}'"
eval "${extractor}/'generic-w64-mingw32/'"
eval "${extractor}/'aarch64-w64-mingw32/include'"
eval "${extractor}/'aarch64-w64-mingw32/lib/'"
rm -rf -- ${MINGW_ROOT}/aarch64-w64-mingw32/lib/libc++.modules.json
eval "${extractor}/'x86_64-w64-mingw32/include'"
eval "${extractor}/'x86_64-w64-mingw32/lib/'"
rm -rf -- ${MINGW_ROOT}/x86_64-w64-mingw32/lib/libc++.modules.json
#eval "${extractor}/'lib/clang/19/include/'"
eval "${extractor}/'lib/clang/19/lib/windows/libclang_rt.builtins-aarch64.a'"
eval "${extractor}/'lib/clang/19/lib/windows/libclang_rt.builtins-x86_64.a'"
eval "${extractor}/'bin/'"

# remove unused files...
rm -rf -- ${MINGW_ROOT}/generic-w64-mingw32/include/**/*.idl
rm -rf -- ${MINGW_ROOT}/bin/*-widl

rm -rf -- ${MINGW_ROOT}/bin/i686-w64-mingw32*
rm -rf -- ${MINGW_ROOT}/bin/i686-w64-windows-gnu.cfg
rm -rf -- ${MINGW_ROOT}/bin/armv7-w64-mingw32*
rm -rf -- ${MINGW_ROOT}/bin/armv7-w64-windows-gnu.cfg
rm -rf -- ${MINGW_ROOT}/bin/*-w64-mingw32uwp*
rm -rf -- ${MINGW_ROOT}/bin/analyze-build
rm -rf -- ${MINGW_ROOT}/bin/clangd
rm -rf -- ${MINGW_ROOT}/bin/clang-format
rm -rf -- ${MINGW_ROOT}/bin/clang-tidy
rm -rf -- ${MINGW_ROOT}/bin/git-clang-format
rm -rf -- ${MINGW_ROOT}/bin/intercept-build
rm -rf -- ${MINGW_ROOT}/bin/lldb*
rm -rf -- ${MINGW_ROOT}/bin/run-clang-tidy
rm -rf -- ${MINGW_ROOT}/bin/scan-build-py
rm -rf -- ${MINGW_ROOT}/bin/*clang-scan-deps
rm -rf -- ${MINGW_ROOT}/bin/clang-scan-deps-wrapper
rm -rf -- ${MINGW_ROOT}/bin/clang-target-wrapper


rm -rf -- ${MINGW_ROOT}/bin/clang
rm -rf -- ${MINGW_ROOT}/bin/clang++
rm -rf -- ${MINGW_ROOT}/bin/clang-19
rm -rf -- ${MINGW_ROOT}/bin/clang-cpp
rm -rf -- ${MINGW_ROOT}/bin/ld.lld
rm -rf -- ${MINGW_ROOT}/bin/lld
rm -rf -- ${MINGW_ROOT}/bin/lld-link
rm -rf -- ${MINGW_ROOT}/bin/llvm-addr2line
rm -rf -- ${MINGW_ROOT}/bin/llvm-ar
rm -rf -- ${MINGW_ROOT}/bin/llvm-dlltool
rm -rf -- ${MINGW_ROOT}/bin/llvm-cov
rm -rf -- ${MINGW_ROOT}/bin/llvm-cvtres
rm -rf -- ${MINGW_ROOT}/bin/llvm-cxxfilt
rm -rf -- ${MINGW_ROOT}/bin/llvm-ml
rm -rf -- ${MINGW_ROOT}/bin/llvm-ml
rm -rf -- ${MINGW_ROOT}/bin/llvm-nm
rm -rf -- ${MINGW_ROOT}/bin/llvm-objcopy
rm -rf -- ${MINGW_ROOT}/bin/llvm-objdump
rm -rf -- ${MINGW_ROOT}/bin/llvm-ranlib
rm -rf -- ${MINGW_ROOT}/bin/llvm-pdbutil
rm -rf -- ${MINGW_ROOT}/bin/llvm-profdata
rm -rf -- ${MINGW_ROOT}/bin/llvm-rc
rm -rf -- ${MINGW_ROOT}/bin/llvm-readelf
rm -rf -- ${MINGW_ROOT}/bin/llvm-readobj
rm -rf -- ${MINGW_ROOT}/bin/llvm-size
rm -rf -- ${MINGW_ROOT}/bin/llvm-strings
rm -rf -- ${MINGW_ROOT}/bin/llvm-strip
rm -rf -- ${MINGW_ROOT}/bin/llvm-symbolizer
rm -rf -- ${MINGW_ROOT}/bin/llvm-windres
rm -rf -- ${MINGW_ROOT}/bin/llvm-wrapper


# ----------------------------
rm -f -- ${filename}.tar.xz
