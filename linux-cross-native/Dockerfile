ARG CONTAINER_REGISTRY_PREFIX
ARG SYSROOT_LINUX_HEADER_UAPI="310"
ARG SYSROOT_LIBSTDCXX_GCC_VER="7"
ARG TOOLCHAIN_IMAGE_VERSION="20251013T124553Z-8eb6b90"
FROM ${CONTAINER_REGISTRY_PREFIX}valord577/cross-sysroot-linux${SYSROOT_LINUX_HEADER_UAPI}-gcc${SYSROOT_LIBSTDCXX_GCC_VER}:${TOOLCHAIN_IMAGE_VERSION}

# Install Cmake
ARG CMAKE_URL="https://cmake.org/files"
ENV CMAKE_X="3"
ENV CMAKE_Y="30"
ENV CMAKE_Z="9"
ENV CMAKE_ROOT="/opt/cmake"
RUN <<EOT
#!/usr/bin/env bash
set -e

_CMAKE_URL_="${CMAKE_URL}/v${CMAKE_X}.${CMAKE_Y}/cmake-${CMAKE_X}.${CMAKE_Y}.${CMAKE_Z}-linux-$(uname -m).tar.gz"
curl --fail-with-body -sSL -o "1.tar.gz" --url "${_CMAKE_URL_}"
trap 'rm -rf "1.tar.gz"' EXIT INT TERM
mkdir -p "${CMAKE_ROOT}"; tar xf "1.tar.gz" -C "${CMAKE_ROOT}" --strip-components=1 --no-same-owner

# remove unused files...
rm -f "${CMAKE_ROOT}/bin/ccmake"
rm -f "${CMAKE_ROOT}/bin/cmake-gui"

rm -rf "${CMAKE_ROOT}/man"
rm -rf "${CMAKE_ROOT}/doc"

rm -rf "${CMAKE_ROOT}/share/aclocal"
rm -rf "${CMAKE_ROOT}/share/applications"
rm -rf "${CMAKE_ROOT}/share/bash-completion"
rm -rf "${CMAKE_ROOT}/share/emacs"
rm -rf "${CMAKE_ROOT}/share/icons"
rm -rf "${CMAKE_ROOT}/share/mime"
rm -rf "${CMAKE_ROOT}/share/vim"
EOT
ENV PATH="${CMAKE_ROOT}/bin:${PATH}"


RUN apt update -qq    \
  && apt install -qqy \
    file tree patchelf curl   \
    zip unzip xz-utils ccache \
    git nasm make python3 python3-venv    \
    autoconf automake libtool libltdl-dev \
  && apt clean all -qqy
