# syntax=docker/dockerfile:1
FROM debian:12.4

ENV TZ=UTC \
    DEBIAN_FRONTEND=noninteractive
RUN <<EOT
#!/usr/bin/env bash
set -e

rm -rf -- "/etc/apt/sources.list.d"
cat > "/etc/apt/sources.list" <<- EOF
deb http://mirrors.bfsu.edu.cn/debian/ bookworm main
deb http://mirrors.bfsu.edu.cn/debian/ bookworm-updates main
deb http://mirrors.bfsu.edu.cn/debian-security bookworm-security main
EOF

apt-get update -qq
apt-get install -qqy --no-install-recommends \
  tzdata ca-certificates xz-utils wget
apt-get clean all -qqy

ln -sf /usr/share/zoneinfo/UTC /etc/localtime
EOT

ARG OPENWRT_TOOLCHAIN_DL="https://mirrors.bfsu.edu.cn/openwrt"
ENV OPENWRT_RELEASE_VERSION="23.05.2"
ENV OPENWRT_TOOLCHAIN_GCC="12.3.0"

ENV OPENWRT_TOOLCHAIN_URL="${OPENWRT_TOOLCHAIN_DL}/releases/${OPENWRT_RELEASE_VERSION}/targets/mediatek/mt7622/openwrt-toolchain-${OPENWRT_RELEASE_VERSION}-mediatek-mt7622_gcc-${OPENWRT_TOOLCHAIN_GCC}_musl.Linux-x86_64.tar.xz"
ENV OPENWRT_TOOLCHAIN_SYSROOT="toolchain-aarch64_cortex-a53_gcc-${OPENWRT_TOOLCHAIN_GCC}_musl"
ENV OPENWRT_TOOLCHAIN_ROOT="/opt/openwrt"
ENV PATH="${OPENWRT_TOOLCHAIN_ROOT}/bin:${PATH}"
RUN <<EOT
#!/usr/bin/env bash
set -e

wget -q -O "toolchain.tar.xz" "${OPENWRT_TOOLCHAIN_URL}"
mkdir -p "toolchain" && tar xf "toolchain.tar.xz" -C "toolchain" --strip-components=1
mv "toolchain/${OPENWRT_TOOLCHAIN_SYSROOT}" "${OPENWRT_TOOLCHAIN_ROOT}"
rm -rf "toolchain" "toolchain.tar.xz"
EOT
ENV STAGING_DIR="${OPENWRT_TOOLCHAIN_ROOT}"
ENV CC="${OPENWRT_TOOLCHAIN_ROOT}/bin/aarch64-openwrt-linux-gcc"
ENV CXX="${OPENWRT_TOOLCHAIN_ROOT}/bin/aarch64-openwrt-linux-g++"
ENV AR="${OPENWRT_TOOLCHAIN_ROOT}/bin/aarch64-openwrt-linux-ar"

ENV GOLANG_SDK_URL="https://dl.google.com/go/go1.21.5.linux-amd64.tar.gz"
ENV GOLANG_SDK_ROOT="/opt/go"
ENV PATH="${GOLANG_SDK_ROOT}/bin:${PATH}"
RUN <<EOT
#!/usr/bin/env bash
set -e

wget -q -O "gosdk.tar.gz" "${GOLANG_SDK_URL}"
mkdir -p "${GOLANG_SDK_ROOT}" && tar xf "gosdk.tar.gz" -C "${GOLANG_SDK_ROOT}" --strip-components=1
rm -f "gosdk.tar.gz"

go env -w GOPROXY=https://goproxy.cn,direct
go env -w GOSUMDB=sum.golang.google.cn
EOT
ENV GOARCH=arm64
ENV CGO_ENABLED=1
ENV GOTOOLCHAIN=local
