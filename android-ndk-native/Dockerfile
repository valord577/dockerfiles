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
RUN apt-get update -qq \
  && apt-get install -qqy tzdata ca-certificates \
  && apt-get clean all -qqy
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime
WORKDIR '/opt'

RUN ln -sf /usr/bin/pkgconf /usr/local/bin/pkg-config
RUN apt-get update -qq \
  && apt-get install -qqy \
    curl pkgconf-bin unzip \
  && apt-get clean all -qqy


# Install NDK
ARG NDK_URL="https://dl.google.com/android/repository"
ARG NDK_VERSION="r27d"
ARG NDK_EXTRACT_SUFFIX=""
ENV NDK_ROOT="/opt/ndk"
COPY "extract_ndk_${NDK_VERSION}.sh" "extract_ndk.sh"
RUN ./extract_ndk.sh

# Install Cmake
ARG CMAKE_URL="https://cmake.org/files"
ENV CMAKE_X="3"
ENV CMAKE_Y="30"
ENV CMAKE_Z="9"
ENV CMAKE_ROOT="/opt/cmake"
COPY "extract_cmake.sh" "extract_cmake.sh"
RUN ./extract_cmake.sh
ENV PATH="${CMAKE_ROOT}/bin:${PATH}"


RUN apt-get update -qq    \
  && apt-get install -qqy \
    file tree patchelf curl   \
    zip unzip xz-utils ccache \
    git nasm make python3 python3-venv    \
    autoconf automake libtool libltdl-dev \
  && apt-get clean all -qqy

# required for host tools
RUN apt-get update -qq \
  && apt-get install -qqy \
    libc6-dev binutils \
    libgcc-12-dev \
    libstdc++-12-dev \
  && apt-get clean all -qqy




ENV CROSS_TOOLCHAIN_ROOT="${NDK_ROOT}"
WORKDIR "${CROSS_TOOLCHAIN_ROOT}"

ENV CROSS_TOOLCHAIN_PKGCONF_PREFIX="${CROSS_TOOLCHAIN_ROOT}/pkgconf-wrapper"
COPY ".toolchain/pkgconf-wrapper" "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}"
RUN ln -sfn "$(basename ${CROSS_TOOLCHAIN_PKGCONF_PREFIX})" "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.aarch64-linux-android"
RUN ln -sfn "$(basename ${CROSS_TOOLCHAIN_PKGCONF_PREFIX})" "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.armv7a-linux-androideabi"
RUN ln -sfn "$(basename ${CROSS_TOOLCHAIN_PKGCONF_PREFIX})" "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.i686-linux-android"
RUN ln -sfn "$(basename ${CROSS_TOOLCHAIN_PKGCONF_PREFIX})" "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.x86_64-linux-android"
RUN ln -sfn "$(basename ${CROSS_TOOLCHAIN_PKGCONF_PREFIX})" "${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.riscv64-linux-android"

ENV CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE="${CROSS_TOOLCHAIN_ROOT}/toolchain-cmake-template"
COPY ".toolchain/toolchain-cmake-template.16k.amd64" "${CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE}.16k.amd64"
COPY ".toolchain/toolchain-cmake-template.16k.arm64" "${CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE}.16k.arm64"
COPY ".toolchain/toolchain-cmake-template.16k.armv7" "${CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE}.16k.armv7"
COPY ".toolchain/toolchain-cmake-template.amd64"     "${CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE}.amd64"
COPY ".toolchain/toolchain-cmake-template.arm64"     "${CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE}.arm64"
COPY ".toolchain/toolchain-cmake-template.armv7"     "${CROSS_TOOLCHAIN_FILE_PREFIX_CMAKE}.armv7"

ENV CROSS_TOOLCHAIN_FILE_PREFIX_MESON="${CROSS_TOOLCHAIN_ROOT}/toolchain-meson-template"
COPY ".toolchain/toolchain-meson-template.16k.amd64.tmpl" "${CROSS_TOOLCHAIN_FILE_PREFIX_MESON}.16k.amd64.tmpl"
COPY ".toolchain/toolchain-meson-template.16k.arm64.tmpl" "${CROSS_TOOLCHAIN_FILE_PREFIX_MESON}.16k.arm64.tmpl"
COPY ".toolchain/toolchain-meson-template.16k.armv7.tmpl" "${CROSS_TOOLCHAIN_FILE_PREFIX_MESON}.16k.armv7.tmpl"
COPY ".toolchain/toolchain-meson-template.amd64.tmpl"     "${CROSS_TOOLCHAIN_FILE_PREFIX_MESON}.amd64.tmpl"
COPY ".toolchain/toolchain-meson-template.arm64.tmpl"     "${CROSS_TOOLCHAIN_FILE_PREFIX_MESON}.arm64.tmpl"
COPY ".toolchain/toolchain-meson-template.armv7.tmpl"     "${CROSS_TOOLCHAIN_FILE_PREFIX_MESON}.armv7.tmpl"
