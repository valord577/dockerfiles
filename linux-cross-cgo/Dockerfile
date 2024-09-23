# syntax=docker/dockerfile:1
ARG CONTAINER_REGISTRY_PREFIX
ARG LINUX_UAPI_VERSION="310"
ARG TOOLCHAIN_IMAGE_VERSION="0d9a4d6b6442bd2cd0554e5a517415b0750626e2"

FROM ${CONTAINER_REGISTRY_PREFIX}valord577/ct-linux${LINUX_UAPI_VERSION}:${TOOLCHAIN_IMAGE_VERSION}
RUN ln -sf /usr/bin/pkgconf /usr/local/bin/pkg-config
RUN apt-get update -qq \
  && apt-get install -qqy \
  tree patchelf curl zip unzip xz-utils git file pkgconf-bin \
  && apt-get clean all -qqy

ARG TARGETOS
ARG TARGETARCH

ENV GOLANG_SDK="1.23.1"
ENV GOLANG_SDK_ROOT="/opt/go"
ENV PATH="${GOLANG_SDK_ROOT}/bin:${PATH}"
RUN <<EOT
#!/usr/bin/env bash
set -e

_GOLANG_SDK_URL_="https://dl.google.com/go/go${GOLANG_SDK}.linux-${TARGETARCH}.tar.gz"
curl --fail-with-body -sSL -o "gosdk.tar.gz" --url "${_GOLANG_SDK_URL_}"
trap 'rm -rf "gosdk.tar.gz"' EXIT INT TERM
mkdir -p "${GOLANG_SDK_ROOT}" && tar xvf "gosdk.tar.gz" -C "${GOLANG_SDK_ROOT}" --strip-components=1 --no-same-owner

# https://telemetry.go.dev/
go telemetry off
EOT

ENV CROSS_TOOLCHAIN_CGOTOOL_PREFIX="${CROSS_TOOLCHAIN_ROOT}/cgotool-wrapper"
RUN <<EOT
#!/usr/bin/env bash
set -e

CGOTOOL_WRPPER=$(cat <<- 'EOF'
#! /bin/sh
set -e

basename="${0##*/}"
triplet="${basename##cgotool-wrapper\.}"

if [ false ]; then
  :
elif [[ "${triplet}" =~ ^x86_64.*$ ]]; then
  export GOARCH=amd64; export GOAMD64=v3
elif [[ "${triplet}" =~ ^aarch64.*$ ]]; then
  export GOARCH=arm64
fi

export CGO_ENABLED=1
export GOTOOLCHAIN=local
export AR="/usr/bin/llvm-ar"
export CGO_LDFLAGS="$(go env CGO_LDFLAGS) -fuse-ld=/usr/bin/ld.lld"
export CC="clang --target=${triplet} --gcc-toolchain=${CROSS_TOOLCHAIN_ROOT} --sysroot=${CROSS_TOOLCHAIN_ROOT}/${triplet}/sysroot"
export CXX="clang++ --target=${triplet} --gcc-toolchain=${CROSS_TOOLCHAIN_ROOT} --sysroot=${CROSS_TOOLCHAIN_ROOT}/${triplet}/sysroot"

exec go "$@"

EOF
)
echo -e "${CGOTOOL_WRPPER}" > "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}"; chmod +x "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}"
ln -sfn "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}" "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}.aarch64-unknown-linux-gnu"
ln -sfn "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}" "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}.aarch64-unknown-linux-musl"
ln -sfn "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}" "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}.x86_64-pc-linux-gnu"
ln -sfn "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}" "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}.x86_64-pc-linux-musl"
EOT
