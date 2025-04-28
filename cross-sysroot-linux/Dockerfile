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


ENV LLVM_TOOL_VERSION="16"
ENV LLVM_TOOL_DIR="/usr/lib/llvm-${LLVM_TOOL_VERSION}"
ENV PATH="${PATH}:${LLVM_TOOL_DIR}/bin"
ENV CC="clang" CXX="clang++"
RUN ln -sf /usr/bin/pkgconf /usr/local/bin/pkg-config
RUN apt update -qq \
  && apt install -qqy curl ccache pkgconf-bin \
    clang-${LLVM_TOOL_VERSION} llvm-${LLVM_TOOL_VERSION} lld-${LLVM_TOOL_VERSION} \
  && apt clean all -qqy


ARG SYSROOT_LINUX_HEADER_UAPI="310"
ARG SYSROOT_LIBSTDCXX_GCC_VER="4"
ENV CROSS_TOOLCHAIN_ROOT="/crosstool"
WORKDIR "${CROSS_TOOLCHAIN_ROOT}"
ADD crosstool-linux${SYSROOT_LINUX_HEADER_UAPI}-gcc${SYSROOT_LIBSTDCXX_GCC_VER}-target-ct-amd64-glibc.tar.gz /
ADD crosstool-linux${SYSROOT_LINUX_HEADER_UAPI}-gcc${SYSROOT_LIBSTDCXX_GCC_VER}-target-ct-arm64-glibc.tar.gz /
ADD crosstool-linux${SYSROOT_LINUX_HEADER_UAPI}-gcc${SYSROOT_LIBSTDCXX_GCC_VER}-target-ct-armhf-glibc.tar.gz /
ADD crosstool-linux${SYSROOT_LINUX_HEADER_UAPI}-gcc${SYSROOT_LIBSTDCXX_GCC_VER}-target-ct-amd64-musl.tar.gz  /
ADD crosstool-linux${SYSROOT_LINUX_HEADER_UAPI}-gcc${SYSROOT_LIBSTDCXX_GCC_VER}-target-ct-arm64-musl.tar.gz  /


ENV CROSS_TOOLCHAIN_PKGCONF_PREFIX="${CROSS_TOOLCHAIN_ROOT}/pkgconf-wrapper"
RUN <<EOT
#!/usr/bin/env bash
set -e

PKGCONF_WRPPER=$(cat <<- 'EOF'
#! /bin/sh
set -e

basename="${0##*/}"
triplet="${basename##pkgconf-wrapper\.}"

PKG_CONFIG_LIBDIR="${PKG_CONFIG_LIBDIR}:${CROSS_TOOLCHAIN_ROOT}/${triplet}/usr/lib"
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
ln -sfn "$(basename ${CROSS_TOOLCHAIN_PKGCONF_PREFIX})" "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.aarch64-unknown-linux-gnu"
ln -sfn "$(basename ${CROSS_TOOLCHAIN_PKGCONF_PREFIX})" "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.aarch64-unknown-linux-musl"
ln -sfn "$(basename ${CROSS_TOOLCHAIN_PKGCONF_PREFIX})" "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.x86_64-pc-linux-gnu"
ln -sfn "$(basename ${CROSS_TOOLCHAIN_PKGCONF_PREFIX})" "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.x86_64-pc-linux-musl"
ln -sfn "$(basename ${CROSS_TOOLCHAIN_PKGCONF_PREFIX})" "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.arm-unknown-linux-gnueabihf"
EOT

ENV CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE="${CROSS_TOOLCHAIN_ROOT}/toolchain-cmake-template"
RUN <<EOT
#!/usr/bin/env bash
set -e

TOOLCHAIN_FILE_CMAKE=$(cat <<- 'EOF'
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR "__TARGET_ARCH__")
set(CMAKE_CROSSCOMPILING TRUE)

set(CROSS_TARGET_TRIPLE "__TARGET_TRIPLE__")
set(CROSS_ROOT "$ENV{CROSS_TOOLCHAIN_ROOT}")
set(CMAKE_SYSROOT "${CROSS_ROOT}/${CROSS_TARGET_TRIPLE}")

set(CMAKE_C_COMPILER   "clang"   "--target=${CROSS_TARGET_TRIPLE}" "--gcc-toolchain=${CMAKE_SYSROOT}/usr" "__EXTRA_FLAGS__")
set(CMAKE_CXX_COMPILER "clang++" "--target=${CROSS_TARGET_TRIPLE}" "--gcc-toolchain=${CMAKE_SYSROOT}/usr" "__EXTRA_FLAGS__")
set(CMAKE_LINKER_TYPE  "LLD")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(PKG_CONFIG_EXECUTABLE "${CMAKE_CURRENT_LIST_DIR}/pkgconf-wrapper.${CROSS_TARGET_TRIPLE}" CACHE FILEPATH "pkgconf executable")

EOF
)

TOOLCHAIN_FILE_CMAKE_ARM64_GNU=$(
  echo -e "${TOOLCHAIN_FILE_CMAKE}" | \
  sed "s@__TARGET_ARCH__@aarch64@g" | sed "s@__TARGET_TRIPLE__@aarch64-unknown-linux-gnu@g" | \
  sed "s@__EXTRA_FLAGS__@@g"
)
TOOLCHAIN_FILE_CMAKE_ARM64_MUSL=$(
  echo -e "${TOOLCHAIN_FILE_CMAKE}" | \
  sed "s@__TARGET_ARCH__@aarch64@g" | sed "s@__TARGET_TRIPLE__@aarch64-unknown-linux-musl@g" | \
  sed "s@__EXTRA_FLAGS__@@g"
)
TOOLCHAIN_FILE_CMAKE_AMD64_GNU=$(
  echo -e "${TOOLCHAIN_FILE_CMAKE}" | \
  sed "s@__TARGET_ARCH__@x86_64@g"  | sed "s@__TARGET_TRIPLE__@x86_64-pc-linux-gnu@g" | \
  sed "s@__EXTRA_FLAGS__@@g"
)
TOOLCHAIN_FILE_CMAKE_AMD64_MUSL=$(
  echo -e "${TOOLCHAIN_FILE_CMAKE}" | \
  sed "s@__TARGET_ARCH__@x86_64@g"  | sed "s@__TARGET_TRIPLE__@x86_64-pc-linux-musl@g" | \
  sed "s@__EXTRA_FLAGS__@@g"
)
TOOLCHAIN_FILE_CMAKE_ARMHF_GNU=$(
  echo -e "${TOOLCHAIN_FILE_CMAKE}" | \
  sed "s@__TARGET_ARCH__@arm@g"     | sed "s@__TARGET_TRIPLE__@arm-unknown-linux-gnueabihf@g" | \
  sed "s@__EXTRA_FLAGS__@-march=armv7-a;-mfpu=neon-vfpv4@g"
)

echo -e "${TOOLCHAIN_FILE_CMAKE_ARM64_GNU}"  > "${CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE}.aarch64-unknown-linux-gnu"
echo -e "${TOOLCHAIN_FILE_CMAKE_ARM64_MUSL}" > "${CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE}.aarch64-unknown-linux-musl"
echo -e "${TOOLCHAIN_FILE_CMAKE_AMD64_GNU}"  > "${CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE}.x86_64-pc-linux-gnu"
echo -e "${TOOLCHAIN_FILE_CMAKE_AMD64_MUSL}" > "${CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE}.x86_64-pc-linux-musl"
echo -e "${TOOLCHAIN_FILE_CMAKE_ARMHF_GNU}"  > "${CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE}.arm-unknown-linux-gnueabihf"
EOT

ENV CROSS_TOOLCHAIN_FILE_PREFIX_MESON="${CROSS_TOOLCHAIN_ROOT}/toolchain-meson-template"
RUN <<EOT
#!/usr/bin/env bash
set -e

TOOLCHAIN_FILE_MESON=$(cat <<- 'EOF'
[constants]
prefix = ''
triple = '__TARGET_TRIPLE__'
sys_root = '@DIRNAME@' / triple
gcc_root = '@DIRNAME@' / triple / 'usr'
c_args = ['--target=' + triple, '--gcc-toolchain=' + gcc_root, '--sysroot=' + sys_root, __EXTRA_FLAGS__]
cpp_args = c_args + []

[host_machine]
system = 'linux'
kernel = 'linux'
cpu_family = '__TARGET_ARCH__'
cpu = '__TARGET_ARCH__'
endian = 'little'

[properties]
needs_exe_wrapper = false

[binaries]
c = ['ccache', prefix / 'clang'] + c_args
cpp = ['ccache', prefix / 'clang++'] + cpp_args
ar = prefix / 'llvm-ar'
as = prefix / 'llvm-as'
nm = prefix / 'llvm-nm'
ld = prefix / 'ld.lld'
objcopy = prefix / 'llvm-objcopy'
strip = prefix / 'llvm-strip'
ranlib = prefix / 'llvm-ranlib'
pkg-config = '@DIRNAME@/pkgconf-wrapper.' + triple
cmake = 'cmake'

[built-in options]
c_link_args = ['-fuse-ld=lld', '--sysroot=' + sys_root]
cpp_link_args = c_link_args + []

EOF
)

TOOLCHAIN_FILE_MESON_ARM64_GNU=$(
  echo -e "${TOOLCHAIN_FILE_MESON}" | \
  sed "s@__TARGET_ARCH__@aarch64@g" | sed "s@__TARGET_TRIPLE__@aarch64-unknown-linux-gnu@g" | \
  sed "s@__EXTRA_FLAGS__@''@g"
)
TOOLCHAIN_FILE_MESON_ARM64_MUSL=$(
  echo -e "${TOOLCHAIN_FILE_MESON}" | \
  sed "s@__TARGET_ARCH__@aarch64@g" | sed "s@__TARGET_TRIPLE__@aarch64-unknown-linux-musl@g" | \
  sed "s@__EXTRA_FLAGS__@''@g"
)
TOOLCHAIN_FILE_MESON_AMD64_GNU=$(
  echo -e "${TOOLCHAIN_FILE_MESON}" | \
  sed "s@__TARGET_ARCH__@x86_64@g"  | sed "s@__TARGET_TRIPLE__@x86_64-pc-linux-gnu@g" | \
  sed "s@__EXTRA_FLAGS__@''@g"
)
TOOLCHAIN_FILE_MESON_AMD64_MUSL=$(
  echo -e "${TOOLCHAIN_FILE_MESON}" | \
  sed "s@__TARGET_ARCH__@x86_64@g"  | sed "s@__TARGET_TRIPLE__@x86_64-pc-linux-musl@g" | \
  sed "s@__EXTRA_FLAGS__@''@g"
)
TOOLCHAIN_FILE_MESON_ARMHF_GNU=$(
  echo -e "${TOOLCHAIN_FILE_MESON}" | \
  sed "s@__TARGET_ARCH__@arm@g"     | sed "s@__TARGET_TRIPLE__@arm-unknown-linux-gnueabihf@g" | \
  sed "s@__EXTRA_FLAGS__@'-march=armv7-a', '-mfpu=neon-vfpv4'@g"
)

echo -e "${TOOLCHAIN_FILE_MESON_ARM64_GNU}"  > "${CROSS_TOOLCHAIN_FILE_PREFIX_MESON}.aarch64-unknown-linux-gnu"
echo -e "${TOOLCHAIN_FILE_MESON_ARM64_MUSL}" > "${CROSS_TOOLCHAIN_FILE_PREFIX_MESON}.aarch64-unknown-linux-musl"
echo -e "${TOOLCHAIN_FILE_MESON_AMD64_GNU}"  > "${CROSS_TOOLCHAIN_FILE_PREFIX_MESON}.x86_64-pc-linux-gnu"
echo -e "${TOOLCHAIN_FILE_MESON_AMD64_MUSL}" > "${CROSS_TOOLCHAIN_FILE_PREFIX_MESON}.x86_64-pc-linux-musl"
echo -e "${TOOLCHAIN_FILE_MESON_ARMHF_GNU}"  > "${CROSS_TOOLCHAIN_FILE_PREFIX_MESON}.arm-unknown-linux-gnueabihf"
EOT
