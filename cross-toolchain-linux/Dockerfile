# syntax=docker/dockerfile:1
ARG CONTAINER_REGISTRY_PREFIX
ARG LINUX_UAPI_VERSION="310"
ARG TOOLCHAIN_BASE_IMAGE_VERSION="807cf8443f3e8d9a6ea6f2e1cdcbdf2224325c99"
FROM ${CONTAINER_REGISTRY_PREFIX}valord577/ct-linux${LINUX_UAPI_VERSION}-amd64-gnu:${TOOLCHAIN_BASE_IMAGE_VERSION}  AS ct-amd64-glibc
FROM ${CONTAINER_REGISTRY_PREFIX}valord577/ct-linux${LINUX_UAPI_VERSION}-arm64-gnu:${TOOLCHAIN_BASE_IMAGE_VERSION}  AS ct-arm64-glibc
FROM ${CONTAINER_REGISTRY_PREFIX}valord577/ct-linux${LINUX_UAPI_VERSION}-amd64-musl:${TOOLCHAIN_BASE_IMAGE_VERSION} AS ct-amd64-musl
FROM ${CONTAINER_REGISTRY_PREFIX}valord577/ct-linux${LINUX_UAPI_VERSION}-arm64-musl:${TOOLCHAIN_BASE_IMAGE_VERSION} AS ct-arm64-musl


FROM debian:12.7
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

ENV CC="clang" CXX="clang++"
RUN ln -sf /usr/bin/pkgconf /usr/local/bin/pkg-config
RUN apt-get update -qq \
  && apt-get install -qqy clang llvm lld pkgconf-bin \
  && apt-get clean all -qqy

ENV CROSS_TOOLCHAIN_ROOT="/crosstool"
WORKDIR "${CROSS_TOOLCHAIN_ROOT}"
COPY --from=ct-amd64-glibc ${CROSS_TOOLCHAIN_ROOT} .
COPY --from=ct-arm64-glibc ${CROSS_TOOLCHAIN_ROOT} .
COPY --from=ct-amd64-musl  ${CROSS_TOOLCHAIN_ROOT} .
COPY --from=ct-arm64-musl  ${CROSS_TOOLCHAIN_ROOT} .

ENV CROSS_TOOLCHAIN_PKGCONF_PREFIX="${CROSS_TOOLCHAIN_ROOT}/pkgconf-wrapper"
RUN <<EOT
#!/usr/bin/env bash
set -e

PKGCONF_WRPPER=$(cat <<- 'EOF'
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
echo -e "${PKGCONF_WRPPER}" > "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}"; chmod +x "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}"
ln -sfn "$(basename ${CROSS_TOOLCHAIN_PKGCONF_PREFIX})" "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.aarch64-unknown-linux-gnu"
ln -sfn "$(basename ${CROSS_TOOLCHAIN_PKGCONF_PREFIX})" "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.aarch64-unknown-linux-musl"
ln -sfn "$(basename ${CROSS_TOOLCHAIN_PKGCONF_PREFIX})" "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.x86_64-pc-linux-gnu"
ln -sfn "$(basename ${CROSS_TOOLCHAIN_PKGCONF_PREFIX})" "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.x86_64-pc-linux-musl"
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

set(PKG_CONFIG_EXECUTABLE "${CMAKE_CURRENT_LIST_DIR}/pkgconf-wrapper.${CROSS_TARGET_TRIPLE}" CACHE FILEPATH "pkgconf executable")

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
