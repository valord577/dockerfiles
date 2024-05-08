# syntax=docker/dockerfile:1
FROM --platform=${TARGETPLATFORM} debian:12.5

ARG TARGETOS
ARG TARGETARCH

ENV TZ=UTC \
    DEBIAN_FRONTEND=noninteractive
RUN rm -f -- /etc/apt/apt.conf.d/70debconf
RUN echo 'Acquire::http::Pipeline-Depth "0";' > /etc/apt/apt.conf.d/99nopipelining
RUN echo 'APT::Install-Recommends 0;\nAPT::Install-Suggests 0;' > /etc/apt/apt.conf.d/99norecommends
RUN sed -i s@/deb.debian.org/@/mirrors.bfsu.edu.cn/@g /etc/apt/sources.list.d/**
RUN apt-get update -qq \
  && apt-get install -qqy tzdata \
  && apt-get clean all -qqy
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime


RUN apt-get update -qq \
  && apt-get install -qqy \
    xz-utils wget pkgconf-bin \
  && apt-get clean all -qqy
  ENV XZ_OPT='--threads=0'

ARG MINGW_URL="https://github.com/mstorsjo/llvm-mingw/releases/download"
ENV MINGW_VERSION="20240417"
ENV MINGW_DEFAULT="ucrt-ubuntu-20.04"
ENV MINGW_ROOT="/opt/llvm-mingw"
ENV PATH="${MINGW_ROOT}/bin:${PATH}"
RUN <<EOT
#!/usr/bin/env bash
set -e

MINGW_LLVM_DOWNLOAD_URL="${MINGW_URL}/${MINGW_VERSION}/llvm-mingw-${MINGW_VERSION}-${MINGW_DEFAULT}-$(uname -m).tar.xz"
wget --no-check-certificate -q -O "llvm-mingw.tar.xz" "${MINGW_LLVM_DOWNLOAD_URL}"
trap 'rm -f -- "llvm-mingw.tar.xz"' EXIT INT TERM
mkdir -p "${MINGW_ROOT}" && tar -xvf "llvm-mingw.tar.xz" -C "${MINGW_ROOT}" --strip-components=1 --no-same-owner

PKG_CONFIG_WRPPER=$(cat <<- 'EOF'
#! /bin/sh

if [ x"${PKG_CONFIG_LIBDIR+set}" = x ]; then
  basename="${0##*/}"
  triplet="${basename%-pkg-config}"

  PKG_CONFIG_LIBDIR="@MINGW_ROOT@/${triplet}/lib"
  PKG_CONFIG_LIBDIR="$PKG_CONFIG_LIBDIR:@MINGW_ROOT@/lib"

  export PKG_CONFIG_LIBDIR
fi

exec pkgconf "$@"

EOF
)
PKG_CONFIG_WRPPER=$(echo -e "${PKG_CONFIG_WRPPER}" | sed "s#@MINGW_ROOT@#${MINGW_ROOT}#g")
echo -e "${PKG_CONFIG_WRPPER}" > "${MINGW_ROOT}/bin/pkg-config-crosswrapper" && chmod +x "${MINGW_ROOT}/bin/pkg-config-crosswrapper"
ln -s "${MINGW_ROOT}/bin/pkg-config-crosswrapper" "${MINGW_ROOT}/bin/i686-w64-mingw32-pkg-config"
ln -s "${MINGW_ROOT}/bin/pkg-config-crosswrapper" "${MINGW_ROOT}/bin/x86_64-w64-mingw32-pkg-config"
ln -s "${MINGW_ROOT}/bin/pkg-config-crosswrapper" "${MINGW_ROOT}/bin/armv7-w64-mingw32-pkg-config"
ln -s "${MINGW_ROOT}/bin/pkg-config-crosswrapper" "${MINGW_ROOT}/bin/aarch64-w64-mingw32-pkg-config"
EOT


ENV GOLANG_SDK="1.22.3"
ENV GOLANG_SDK_URL="https://dl.google.com/go/go${GOLANG_SDK}.linux-${TARGETARCH}.tar.gz"
ENV GOLANG_SDK_ROOT="/opt/go"
ENV PATH="${GOLANG_SDK_ROOT}/bin:${PATH}"
RUN <<EOT
#!/usr/bin/env bash
set -e

wget --no-check-certificate -q -O "gosdk.tar.gz" "${GOLANG_SDK_URL}"
trap 'rm -rf "gosdk.tar.gz"' EXIT INT TERM
mkdir -p "${GOLANG_SDK_ROOT}" && tar xvf "gosdk.tar.gz" -C "${GOLANG_SDK_ROOT}" --strip-components=1 --no-same-owner
EOT
ENV GOOS=windows
ENV CGO_ENABLED=1
ENV GOTOOLCHAIN=local


# extra libraries
RUN apt-get update -qq \
  && apt-get install -qqy \
    git ca-certificates \
  && apt-get clean all -qqy
