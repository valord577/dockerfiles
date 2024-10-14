# syntax=docker/dockerfile:1
ARG CONTAINER_REGISTRY_PREFIX
ARG TOOLCHAIN_IMAGE_VERSION="7566c58c81be08eccef6e69a5f6e48fbf2c87b88"
FROM ${CONTAINER_REGISTRY_PREFIX}valord577/cross-sysroot-mingw:${TOOLCHAIN_IMAGE_VERSION}

RUN apt-get update -qq \
  && apt-get install -qqy \
  tree patchelf curl zip unzip xz-utils git file \
  && apt-get clean all -qqy

ARG TARGETOS
ARG TARGETARCH

ENV GOLANG_SDK="1.23.2"
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
# remove unused files...
rm -rf -- ${GOLANG_SDK_ROOT}/test
EOT
ENV GOOS=windows

ENV CROSS_TOOLCHAIN_CGOTOOL_PREFIX="${CROSS_TOOLCHAIN_ROOT}/bin/cgotool-wrapper"
RUN <<EOT
#!/usr/bin/env bash
set -e

CGOTOOL_WRPPER=$(cat <<- 'EOF'
#!/usr/bin/env bash
set -e

basename="${0##*/}"
triplet="${basename##cgotool-wrapper\.}"

if [[ "${triplet}" =~ ^x86_64.*$ ]]; then
  export GOARCH=amd64; export GOAMD64=v3
elif [[ "${triplet}" =~ ^aarch64.*$ ]]; then
  export GOARCH=arm64
elif [[ "${triplet}" =~ ^i686.*$ ]]; then
  export GOARCH=386
elif [[ "${triplet}" =~ ^armv7.*$ ]]; then
  export GOARCH=arm
fi

export CGO_ENABLED=1
export GOTOOLCHAIN=local
export AR="${CROSS_TOOLCHAIN_ROOT}/bin/${triplet}-ar"
export CC="${CROSS_TOOLCHAIN_ROOT}/bin/${triplet}-clang"
export CXX="${CROSS_TOOLCHAIN_ROOT}/bin/${triplet}-clang++"
export PKG_CONFIG="${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.${triplet}"

exec go "$@"

EOF
)
echo -e "${CGOTOOL_WRPPER}" > "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}"; chmod +x "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}"
ln -sfn "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}" "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}.i686-w64-mingw32"
ln -sfn "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}" "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}.x86_64-w64-mingw32"
ln -sfn "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}" "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}.armv7-w64-mingw32"
ln -sfn "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}" "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}.aarch64-w64-mingw32"
EOT
