# syntax=docker/dockerfile:1
ARG TARGETOS
ARG TARGETARCH

FROM debian:12.7 AS base
SHELL ["/bin/bash", "-c"]
ENV TZ=UTC \
    DEBIAN_FRONTEND=noninteractive
ENV XZ_OPT='--threads=0'
ENV CCACHE_DIR="/ccache"
RUN rm -f -- /etc/apt/apt.conf.d/70debconf
RUN echo 'Acquire::http::Pipeline-Depth "0";' > /etc/apt/apt.conf.d/99nopipelining
RUN echo 'APT::Install-Recommends 0;\nAPT::Install-Suggests 0;' > /etc/apt/apt.conf.d/99norecommends
RUN sed -i s@/deb.debian.org/@/mirrors.bfsu.edu.cn/@g /etc/apt/sources.list.d/**
RUN apt-get update -qq \
  && apt-get install -qqy tzdata ca-certificates \
  && apt-get clean all -qqy
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime
ENV CT_REPO="/crosstool"
ENV CT_PREFIX="${CT_REPO}/release"


FROM base AS crosstool-base
RUN apt-get update -qq \
  && apt-get install -qqy \
  curl unzip xz-utils git pkgconf-bin autoconf automake \
  gcc g++ flex texinfo bzip2 help2man file patch gawk \
  make libtool-bin python3 bison libncurses-dev ccache \
  && apt-get clean all -qqy

ENV CT_TAG_NAME="crosstool-ng-1.26.0"
ENV CT_LOCAL_TARBALLS_DIR="${CT_REPO}/src"
WORKDIR "${CT_REPO}"
RUN <<EOT
#!/usr/bin/env bash
set -e

git clone --no-checkout --single-branch --depth=1 https://github.com/crosstool-ng/crosstool-ng.git .
git fetch --tags --prune --prune-tags --no-recurse-submodules --depth=1; git checkout ${CT_TAG_NAME}

export CC='ccache gcc'
export CXX='ccache g++'
export PKG_CONFIG=$(command -v pkgconf)
./bootstrap
./configure --disable-rpath --disable-nls --enable-local
make -j
EOT



ARG LINUX_UAPI_VERSION="310"

FROM crosstool-base AS ct-amd64-glibc
COPY ".config.linux${LINUX_UAPI_VERSION}.glibc217.amd64" ".config"
RUN ./ct-ng show-config; ./ct-ng source; ./ct-ng build
ENV CROSS_TRIPLE="x86_64-pc-linux-gnu"
RUN cd ${CT_PREFIX}; mkdir lib; mv ${CROSS_TRIPLE} tmp; \
  mv tmp/lib/gcc ./lib; mv tmp/${CROSS_TRIPLE} .; rm -rf tmp; \
  rm -rf ${CROSS_TRIPLE}/debug-root; \
  rm -rf ${CROSS_TRIPLE}/{etc,sbin,var};

FROM crosstool-base AS ct-arm64-glibc
COPY ".config.linux${LINUX_UAPI_VERSION}.glibc217.arm64" ".config"
RUN ./ct-ng show-config; ./ct-ng source; ./ct-ng build
ENV CROSS_TRIPLE="aarch64-unknown-linux-gnu"
RUN cd ${CT_PREFIX}; mkdir lib; mv ${CROSS_TRIPLE} tmp; \
  mv tmp/lib/gcc ./lib; mv tmp/${CROSS_TRIPLE} .; rm -rf tmp; \
  rm -rf ${CROSS_TRIPLE}/debug-root; \
  rm -rf ${CROSS_TRIPLE}/{etc,sbin,var};

FROM crosstool-base AS ct-amd64-musl
COPY ".config.linux${LINUX_UAPI_VERSION}.musl.amd64" ".config"
RUN ./ct-ng show-config; ./ct-ng source; ./ct-ng build
ENV CROSS_TRIPLE="x86_64-pc-linux-musl"
RUN cd ${CT_PREFIX}; mkdir lib; mv ${CROSS_TRIPLE} tmp; \
  mv tmp/lib/gcc ./lib; mv tmp/${CROSS_TRIPLE} .; rm -rf tmp; \
  rm -rf ${CROSS_TRIPLE}/debug-root; \
  rm -rf ${CROSS_TRIPLE}/{etc,sbin,var};

FROM crosstool-base AS ct-arm64-musl
COPY ".config.linux${LINUX_UAPI_VERSION}.musl.arm64" ".config"
RUN ./ct-ng show-config; ./ct-ng source; ./ct-ng build
ENV CROSS_TRIPLE="aarch64-unknown-linux-musl"
RUN cd ${CT_PREFIX}; mkdir lib; mv ${CROSS_TRIPLE} tmp; \
  mv tmp/lib/gcc ./lib; mv tmp/${CROSS_TRIPLE} .; rm -rf tmp; \
  rm -rf ${CROSS_TRIPLE}/debug-root; \
  rm -rf ${CROSS_TRIPLE}/{etc,sbin,var};



FROM base AS toolchain
ENV CC="clang" CXX="clang++"
RUN apt-get update -qq \
  && apt-get install -qqy clang llvm lld \
  && apt-get clean all -qqy

ENV CROSS_TOOLCHAIN_ROOT="${CT_REPO}"
WORKDIR "${CT_REPO}"
COPY --from=ct-amd64-glibc ${CT_PREFIX} .
COPY --from=ct-arm64-glibc ${CT_PREFIX} .
COPY --from=ct-amd64-musl  ${CT_PREFIX} .
COPY --from=ct-arm64-musl  ${CT_PREFIX} .

ENV CROSS_TOOLCHAIN_PKGCONF_PREFIX="${CROSS_TOOLCHAIN_ROOT}/pkgconf-wrapper"
RUN <<EOT
#!/usr/bin/env bash
set -e

PKG_CONFIG_WRPPER=$(cat <<- 'EOF'
#! /bin/sh
set -e

basename="${0##*/}"
triplet="${basename##pkgconf-wrapper\.}"

PKG_CONFIG_LIBDIR="${PKG_CONFIG_LIBDIR}:${CROSS_TOOLCHAIN_ROOT}/${triplet}/lib64"
PKG_CONFIG_LIBDIR="${PKG_CONFIG_LIBDIR}:${CROSS_TOOLCHAIN_ROOT}/${triplet}/sysroot/lib64"
PKG_CONFIG_LIBDIR="${PKG_CONFIG_LIBDIR}:${CROSS_TOOLCHAIN_ROOT}/${triplet}/sysroot/usr/lib64"
PKG_CONFIG_LIBDIR="${PKG_CONFIG_LIBDIR}:${CROSS_TOOLCHAIN_ROOT}/${triplet}/lib"
PKG_CONFIG_LIBDIR="${PKG_CONFIG_LIBDIR}:${CROSS_TOOLCHAIN_ROOT}/${triplet}/sysroot/lib"
PKG_CONFIG_LIBDIR="${PKG_CONFIG_LIBDIR}:${CROSS_TOOLCHAIN_ROOT}/${triplet}/sysroot/usr/lib"
export PKG_CONFIG_LIBDIR

if command -v pkgconf >/dev/null 2>&1 ; then
  exec pkgconf "$@"
else
  exec pkg-config "$@"
fi

EOF
)
echo -e "${PKG_CONFIG_WRPPER}" > "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}"; chmod +x "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}"
ln -sfn "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}" "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.aarch64-unknown-linux-gnu"
ln -sfn "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}" "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.aarch64-unknown-linux-musl"
ln -sfn "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}" "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.x86_64-pc-linux-gnu"
ln -sfn "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}" "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.x86_64-pc-linux-musl"
EOT

ENV CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE="${CROSS_TOOLCHAIN_ROOT}/toolchain-cmake-template"
RUN <<EOT
#!/usr/bin/env bash
set -e

TOOLCHAIN_FILE_CMAKE=$(cat <<- 'EOF'
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR "__TARGET_ARCH__")
set(CMAKE_CROSSCOMPILING TRUE)

set(CROSS_ROOT "$ENV{CROSS_TOOLCHAIN_ROOT}")
set(CROSS_TARGET_TRIPLE "__TARGET_TRIPLE__")
set(CMAKE_C_COMPILER   "/usr/bin/clang"   "--target=${CROSS_TARGET_TRIPLE}" "--gcc-toolchain=${CROSS_ROOT}")
set(CMAKE_CXX_COMPILER "/usr/bin/clang++" "--target=${CROSS_TARGET_TRIPLE}" "--gcc-toolchain=${CROSS_ROOT}")

set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=/usr/bin/ld.lld")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "-fuse-ld=/usr/bin/ld.lld")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=/usr/bin/ld.lld")
#set(CMAKE_STATIC_LINKER_FLAGS_INIT "-fuse-ld=/usr/bin/ld.lld")

set(CMAKE_SYSROOT "${CROSS_ROOT}/${CROSS_TARGET_TRIPLE}/sysroot")
set(CMAKE_FIND_ROOT_PATH "${CMAKE_SYSROOT}" )
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(PKG_CONFIG_EXECUTABLE "${CROSS_ROOT}/pkgconf-wrapper.${CROSS_TARGET_TRIPLE}" CACHE FILEPATH "pkgconf executable")

EOF
)
TOOLCHAIN_FILE_CMAKE_ARM64_GNU=$(echo -e "${TOOLCHAIN_FILE_CMAKE}" | sed "s@__TARGET_ARCH__@aarch64@g" | sed "s@__TARGET_TRIPLE__@aarch64-unknown-linux-gnu@g")
TOOLCHAIN_FILE_CMAKE_ARM64_MUSL=$(echo -e "${TOOLCHAIN_FILE_CMAKE}" | sed "s@__TARGET_ARCH__@aarch64@g" | sed "s@__TARGET_TRIPLE__@aarch64-unknown-linux-musl@g")
TOOLCHAIN_FILE_CMAKE_AMD64_GNU=$(echo -e "${TOOLCHAIN_FILE_CMAKE}" | sed "s@__TARGET_ARCH__@x86_64@g" | sed "s@__TARGET_TRIPLE__@x86_64-pc-linux-gnu@g")
TOOLCHAIN_FILE_CMAKE_AMD64_MUSL=$(echo -e "${TOOLCHAIN_FILE_CMAKE}" | sed "s@__TARGET_ARCH__@x86_64@g" | sed "s@__TARGET_TRIPLE__@x86_64-pc-linux-musl@g")

echo -e "${TOOLCHAIN_FILE_CMAKE_ARM64_GNU}"  > "${CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE}.aarch64-unknown-linux-gnu"
echo -e "${TOOLCHAIN_FILE_CMAKE_ARM64_MUSL}" > "${CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE}.aarch64-unknown-linux-musl"
echo -e "${TOOLCHAIN_FILE_CMAKE_AMD64_GNU}"  > "${CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE}.x86_64-pc-linux-gnu"
echo -e "${TOOLCHAIN_FILE_CMAKE_AMD64_MUSL}" > "${CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE}.x86_64-pc-linux-musl"
EOT

FROM toolchain
RUN apt-get update -qq \
  && apt-get install -qqy \
  tree patchelf curl zip unzip xz-utils git file \
  make ccache python3 python3-venv cmake pkgconf-bin \
  && apt-get clean all -qqy
