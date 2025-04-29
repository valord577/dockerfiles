FROM debian:12
SHELL ["/bin/bash", "-c"]
ENV TZ=UTC \
    DEBIAN_FRONTEND=noninteractive
ENV XZ_OPT='--threads=0'
ENV CCACHE_DIR="/ccache"
RUN rm -f -- /etc/apt/apt.conf.d/70debconf
RUN echo 'Acquire::http::Pipeline-Depth "0";' > /etc/apt/apt.conf.d/99nopipelining
RUN echo 'APT::Install-Recommends 0;\nAPT::Install-Suggests 0;' > /etc/apt/apt.conf.d/99norecommends
RUN sed -i s@/deb.debian.org/@/mirrors.bfsu.edu.cn/@g /etc/apt/sources.list.d/**
RUN apt update -qq \
  && apt install -qqy tzdata ca-certificates \
  && apt clean all -qqy
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime


RUN ln -sf /usr/bin/pkgconf /usr/local/bin/pkg-config
RUN apt update -qq \
  && apt install -qqy \
    curl pkgconf-bin xz-utils \
  && apt clean all -qqy


ARG MINGW_URL="https://github.com/mstorsjo/llvm-mingw/releases/download"
ARG MINGW_VERSION="20250114"
ARG MINGW_DEFAULT="ucrt-ubuntu-20.04"
ENV MINGW_ROOT="/opt/llvm-mingw"
ENV PATH="${MINGW_ROOT}/bin:${PATH}"
RUN <<EOT
#!/usr/bin/env bash
set -e

MINGW_LLVM_DOWNLOAD_URL="${MINGW_URL}/${MINGW_VERSION}/llvm-mingw-${MINGW_VERSION}-${MINGW_DEFAULT}-$(uname -m).tar.xz"
curl --fail-with-body -sSL -o "1.tar.xz" --url "${MINGW_LLVM_DOWNLOAD_URL}"
trap 'rm -f -- "1.tar.xz"' EXIT INT TERM
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
rm -rf -- ${MINGW_ROOT}/lib/liblldb.so*
EOT


ENV CROSS_TOOLCHAIN_ROOT="${MINGW_ROOT}"
WORKDIR "${CROSS_TOOLCHAIN_ROOT}"

ENV CROSS_TOOLCHAIN_PKGCONF_PREFIX="${CROSS_TOOLCHAIN_ROOT}/pkgconf-wrapper"
RUN <<EOT
#!/usr/bin/env bash
set -e

PKGCONF_WRPPER=$(cat <<- 'EOF'
#! /bin/sh
set -e

basename="${0##*/}"
triplet="${basename##pkgconf-wrapper\.}"
triplet="${triplet}-w64-mingw32"

PKG_CONFIG_LIBDIR="${PKG_CONFIG_LIBDIR}:${CROSS_TOOLCHAIN_ROOT}/${triplet}/lib"
export PKG_CONFIG_LIBDIR

if command -v pkgconf >/dev/null 2>&1 ; then
  exec pkgconf "$@"
else
  exec pkg-config "$@"
fi

EOF
)
echo -e "${PKGCONF_WRPPER}" > "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}"; chmod +x "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}"
ln -sfn "$(basename ${CROSS_TOOLCHAIN_PKGCONF_PREFIX})" "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.x86_64"
ln -sfn "$(basename ${CROSS_TOOLCHAIN_PKGCONF_PREFIX})" "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.aarch64"
EOT

ENV CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE="${CROSS_TOOLCHAIN_ROOT}/toolchain-cmake-template"
RUN <<EOT
#!/usr/bin/env bash
set -e

TOOLCHAIN_FILE_CMAKE=$(cat <<- 'EOF'
set(MinGW TRUE)
set(WIN32 TRUE)
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR "__TARGET_ARCH__")
set(CMAKE_CROSSCOMPILING TRUE)

set(CROSS_TARGET_TRIPLE "__TARGET_ARCH__-w64-mingw32")
set(CROSS_ROOT "$ENV{CROSS_TOOLCHAIN_ROOT}")
set(CMAKE_SYSROOT "${CROSS_ROOT}/${CROSS_TARGET_TRIPLE}")

set(CMAKE_C_COMPILER   "${CROSS_ROOT}/bin/${CROSS_TARGET_TRIPLE}-clang")
set(CMAKE_CXX_COMPILER "${CROSS_ROOT}/bin/${CROSS_TARGET_TRIPLE}-clang++")
set(CMAKE_RC_COMPILER  "${CROSS_ROOT}/bin/${CROSS_TARGET_TRIPLE}-windres")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(PKG_CONFIG_EXECUTABLE "${CMAKE_CURRENT_LIST_DIR}/pkgconf-wrapper.__TARGET_ARCH__" CACHE FILEPATH "pkgconf executable")

EOF
)
TOOLCHAIN_FILE_CMAKE_X86_64=$(echo -e "${TOOLCHAIN_FILE_CMAKE}" | sed "s#__TARGET_ARCH__#x86_64#g")
TOOLCHAIN_FILE_CMAKE_ARM_64=$(echo -e "${TOOLCHAIN_FILE_CMAKE}" | sed "s#__TARGET_ARCH__#aarch64#g")

echo -e "${TOOLCHAIN_FILE_CMAKE_X86_64}" > "${CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE}.x86_64"
ln -sfn "$(basename ${CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE}.x86_64)"  "${CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE}.amd64"
echo -e "${TOOLCHAIN_FILE_CMAKE_ARM_64}" > "${CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE}.aarch64"
ln -sfn "$(basename ${CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE}.aarch64)" "${CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE}.arm64"
EOT

ENV CROSS_TOOLCHAIN_FILE_PREFIX_MESON="${CROSS_TOOLCHAIN_ROOT}/toolchain-meson-template"
RUN <<EOT
#!/usr/bin/env bash
set -e

TOOLCHAIN_FILE_MESON=$(cat <<- 'EOF'
[constants]
prefix = '@DIRNAME@' / 'bin'
triple = '__TARGET_ARCH__-w64-mingw32'

[host_machine]
system = 'windows'
kernel = 'nt'
cpu_family = '__TARGET_ARCH__'
cpu = '__TARGET_ARCH__'
endian = 'little'

[properties]
needs_exe_wrapper = false

[binaries]
c = ['ccache', prefix / triple + '-clang']
cpp = ['ccache', prefix / triple + '-clang++']
ar = prefix / triple + '-ar'
as = prefix / triple + '-as'
nm = prefix / triple + '-nm'
ld = prefix / triple + '-ld'
objcopy = prefix / triple + '-objcopy'
strip =   prefix / triple + '-strip'
ranlib =  prefix / triple + '-ranlib'
pkg-config = '@DIRNAME@/pkgconf-wrapper.__TARGET_ARCH__'
cmake = 'cmake'

EOF
)

TOOLCHAIN_FILE_MESON_X86_64=$(echo -e "${TOOLCHAIN_FILE_MESON}" | sed "s#__TARGET_ARCH__#x86_64#g")
TOOLCHAIN_FILE_MESON_ARM_64=$(echo -e "${TOOLCHAIN_FILE_MESON}" | sed "s#__TARGET_ARCH__#aarch64#g")

echo -e "${TOOLCHAIN_FILE_MESON_X86_64}" > "${CROSS_TOOLCHAIN_FILE_PREFIX_MESON}.x86_64"
ln -sfn "$(basename ${CROSS_TOOLCHAIN_FILE_PREFIX_MESON}.x86_64)"  "${CROSS_TOOLCHAIN_FILE_PREFIX_MESON}.amd64"
echo -e "${TOOLCHAIN_FILE_MESON_ARM_64}" > "${CROSS_TOOLCHAIN_FILE_PREFIX_MESON}.aarch64"
ln -sfn "$(basename ${CROSS_TOOLCHAIN_FILE_PREFIX_MESON}.aarch64)" "${CROSS_TOOLCHAIN_FILE_PREFIX_MESON}.arm64"
EOT
