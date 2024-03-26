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
    xz-utils wget \
  && apt-get clean all -qqy


ENV OPENWRT_TOOLCHAIN_DL="https://downloads.openwrt.org"
ENV OPENWRT_RELEASE_VERSION="23.05.3"
ENV OPENWRT_TOOLCHAIN_GCC="12.3.0"

ENV OPENWRT_TOOLCHAIN_URL="${OPENWRT_TOOLCHAIN_DL}/releases/${OPENWRT_RELEASE_VERSION}/targets/mediatek/mt7622/openwrt-toolchain-${OPENWRT_RELEASE_VERSION}-mediatek-mt7622_gcc-${OPENWRT_TOOLCHAIN_GCC}_musl.Linux-x86_64.tar.xz"
ENV OPENWRT_TOOLCHAIN_SYSROOT="toolchain-aarch64_cortex-a53_gcc-${OPENWRT_TOOLCHAIN_GCC}_musl"
ENV OPENWRT_TOOLCHAIN_ROOT="/opt/openwrt"
ENV PATH="${OPENWRT_TOOLCHAIN_ROOT}/bin:${PATH}"
RUN <<EOT
#!/usr/bin/env bash
set -e

wget --no-check-certificate -q -O "toolchain.tar.xz" "${OPENWRT_TOOLCHAIN_URL}"
trap 'rm -rf "toolchain" "toolchain.tar.xz"' EXIT INT TERM

mkdir -p "toolchain" && XZ_OPT='--threads=0' tar -xvf "toolchain.tar.xz" -C "toolchain" --strip-components=1 --no-same-owner
mv "toolchain/${OPENWRT_TOOLCHAIN_SYSROOT}" "${OPENWRT_TOOLCHAIN_ROOT}"
EOT
ENV STAGING_DIR="${OPENWRT_TOOLCHAIN_ROOT}"
ENV CC="${OPENWRT_TOOLCHAIN_ROOT}/bin/aarch64-openwrt-linux-gcc"
ENV CXX="${OPENWRT_TOOLCHAIN_ROOT}/bin/aarch64-openwrt-linux-g++"
ENV AR="${OPENWRT_TOOLCHAIN_ROOT}/bin/aarch64-openwrt-linux-ar"


ENV GOLANG_SDK="1.22.1"
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
ENV GOARCH=arm64
ENV CGO_ENABLED=1
ENV GOTOOLCHAIN=local


# extra libraries
RUN apt-get update -qq \
  && apt-get install -qqy \
    git ca-certificates \
  && apt-get clean all -qqy
