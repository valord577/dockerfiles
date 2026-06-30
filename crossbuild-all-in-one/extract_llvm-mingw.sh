#!/usr/bin/env sh
set -e

MINGW_ROOT="/opt/toolchain/llvm-mingw"

_DOWNLOAD_URL_="${MINGW_URL}/${MINGW_VERSION}/llvm-mingw-${MINGW_VERSION}-${MINGW_DEFAULT}-$(uname -m).tar.xz"
curl --fail-with-body -sSL -o "1.tar.xz" --url "${_DOWNLOAD_URL_}"
mkdir -p "${MINGW_ROOT}" && tar -xvf "1.tar.xz" -C "${MINGW_ROOT}" --strip-components=1 --no-same-owner

# remove unused files...
rm -rf -- ${MINGW_ROOT}/i686-w64-mingw32
rm -rf -- ${MINGW_ROOT}/armv7-w64-mingw32

rm -rf -- ${MINGW_ROOT}/share
rm -rf -- ${MINGW_ROOT}/**/share

rm -rf -- ${MINGW_ROOT}/generic-w64-mingw32/include/**/*.idl

rm -rf -- ${MINGW_ROOT}/bin/i686-w64-mingw32*
rm -rf -- ${MINGW_ROOT}/bin/i686-w64-windows-gnu.cfg
rm -rf -- ${MINGW_ROOT}/bin/armv7-w64-mingw32*
rm -rf -- ${MINGW_ROOT}/bin/armv7-w64-windows-gnu.cfg
rm -rf -- ${MINGW_ROOT}/bin/x86_64-w64-mingw32uwp*
rm -rf -- ${MINGW_ROOT}/bin/aarch64-w64-mingw32uwp*
rm -rf -- ${MINGW_ROOT}/bin/analyze-build
rm -rf -- ${MINGW_ROOT}/bin/clangd
rm -rf -- ${MINGW_ROOT}/bin/clang-format
rm -rf -- ${MINGW_ROOT}/bin/clang-tidy
rm -rf -- ${MINGW_ROOT}/bin/git-clang-format
rm -rf -- ${MINGW_ROOT}/bin/intercept-build
rm -rf -- ${MINGW_ROOT}/bin/lldb*
rm -rf -- ${MINGW_ROOT}/bin/run-clang-tidy
rm -rf -- ${MINGW_ROOT}/bin/scan-build-py
rm -rf -- ${MINGW_ROOT}/bin/*-widl
rm -rf -- ${MINGW_ROOT}/bin/*clang-scan-deps
rm -rf -- ${MINGW_ROOT}/bin/clang-scan-deps-wrapper
rm -rf -- ${MINGW_ROOT}/bin/clang-target-wrapper

rm -rf -- ${MINGW_ROOT}/lib/libear
rm -rf -- ${MINGW_ROOT}/lib/libscanbuild
rm -rf -- ${MINGW_ROOT}/lib/liblldbIntelFeatures.so*



rm -rf -- ${MINGW_ROOT}/aarch64-w64-mingw32/bin
rm -rf -- ${MINGW_ROOT}/aarch64-w64-mingw32/lib/libc++.modules.json
rm -rf -- ${MINGW_ROOT}/x86_64-w64-mingw32/bin
rm -rf -- ${MINGW_ROOT}/x86_64-w64-mingw32/lib/libc++.modules.json

rm -rf -- ${MINGW_ROOT}/bin/clang-19
rm -rf -- ${MINGW_ROOT}/bin/ld.lld
rm -rf -- ${MINGW_ROOT}/bin/lld
rm -rf -- ${MINGW_ROOT}/bin/lld-link
rm -rf -- ${MINGW_ROOT}/bin/llvm-addr2line
rm -rf -- ${MINGW_ROOT}/bin/llvm-ar
rm -rf -- ${MINGW_ROOT}/bin/llvm-cov
rm -rf -- ${MINGW_ROOT}/bin/llvm-cvtres
rm -rf -- ${MINGW_ROOT}/bin/llvm-cxxfilt
rm -rf -- ${MINGW_ROOT}/bin/llvm-ml
rm -rf -- ${MINGW_ROOT}/bin/llvm-ml
rm -rf -- ${MINGW_ROOT}/bin/llvm-nm
rm -rf -- ${MINGW_ROOT}/bin/llvm-objcopy
rm -rf -- ${MINGW_ROOT}/bin/llvm-objdump
rm -rf -- ${MINGW_ROOT}/bin/llvm-pdbutil
rm -rf -- ${MINGW_ROOT}/bin/llvm-profdata
rm -rf -- ${MINGW_ROOT}/bin/llvm-rc
rm -rf -- ${MINGW_ROOT}/bin/llvm-readelf
rm -rf -- ${MINGW_ROOT}/bin/llvm-readobj
rm -rf -- ${MINGW_ROOT}/bin/llvm-size
rm -rf -- ${MINGW_ROOT}/bin/llvm-strings
rm -rf -- ${MINGW_ROOT}/bin/llvm-symbolizer
rm -rf -- ${MINGW_ROOT}/bin/llvm-windres
rm -rf -- ${MINGW_ROOT}/bin/llvm-wrapper

rm -rf -- ${MINGW_ROOT}/lib/libLLVM*
rm -rf -- ${MINGW_ROOT}/libclang-cpp*

rm -rf -- ${MINGW_ROOT}/lib/clang/*/lib/windows/libclang_rt.asan*
rm -rf -- ${MINGW_ROOT}/lib/clang/*/lib/windows/libclang_rt.fuzzer*
rm -rf -- ${MINGW_ROOT}/lib/clang/*/lib/windows/libclang_rt.profile*
rm -rf -- ${MINGW_ROOT}/lib/clang/*/lib/windows/libclang_rt.stats*
rm -rf -- ${MINGW_ROOT}/lib/clang/*/lib/windows/libclang_rt.ubsan_standalone*
rm -rf -- ${MINGW_ROOT}/lib/clang/*/lib/windows/liborc_rt*


# ----------------------------
rm -f -- 1.tar.xz
