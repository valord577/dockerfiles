ARG CONTAINER_REGISTRY_PREFIX
ARG TOOLCHAIN_IMAGE_VERSION="8eb6b9007778dbf3cf244b08b0a8814f0b281314"
FROM ${CONTAINER_REGISTRY_PREFIX}valord577/cross-sysroot-mingw:${TOOLCHAIN_IMAGE_VERSION}

RUN apt update -qq \
  && apt install -qqy \
    tree patchelf curl zip unzip xz-utils git file python3 \
  && apt clean all -qqy

ARG TARGETOS
ARG TARGETARCH

ENV GOLANG_SDK="1.25.2"
ENV GOLANG_SDK_ROOT="/opt/go"
RUN <<EOT
#!/usr/bin/env bash
set -e

_GOLANG_SDK_URL_="https://dl.google.com/go/go${GOLANG_SDK}.linux-${TARGETARCH}.tar.gz"
curl --fail-with-body -sSL -o "gosdk.tar.gz" --url "${_GOLANG_SDK_URL_}"
trap 'rm -rf "gosdk.tar.gz"' EXIT INT TERM
mkdir -p "${GOLANG_SDK_ROOT}" && tar xf "gosdk.tar.gz" -C "${GOLANG_SDK_ROOT}" --strip-components=1 --no-same-owner

# https://telemetry.go.dev/
${GOLANG_SDK_ROOT}/bin/go telemetry off
# remove unused files...
rm -rf -- ${GOLANG_SDK_ROOT}/test
EOT
ENV GOOS=windows


ENV CROSS_TOOLCHAIN_CGOTOOL_PREFIX="${CROSS_TOOLCHAIN_ROOT}/cgotool-wrapper"
RUN <<EOT
#!/usr/bin/env bash
set -e

CGOTOOL_WRPPER=$(cat <<- 'EOF'
#!/usr/bin/env bash
set -e

_go_exec_="${GOLANG_SDK_ROOT}/bin/go"
# { command -v go >/dev/null 2>&1; } && \
#   { _go_exec_="$(command -v go)"; }


basename="${0##*/}"
triplet_arch="${basename##cgotool-wrapper\.}"
triplet="${triplet_arch}-w64-mingw32"

if [[ "${triplet}" =~ ^x86_64.*$ ]]; then
  export GOARCH=amd64; export GOAMD64=v3
elif [[ "${triplet}" =~ ^aarch64.*$ ]]; then
  export GOARCH=arm64
fi

export CGO_ENABLED=1
export GOTOOLCHAIN=local
export AR="${CROSS_TOOLCHAIN_ROOT}/bin/${triplet}-ar"
export CGO_LDFLAGS="$(${_go_exec_} env CGO_LDFLAGS) -fuse-ld=${CROSS_TOOLCHAIN_ROOT}/bin/${triplet}-ld"
export CC="${CROSS_TOOLCHAIN_ROOT}/bin/${triplet}-clang"
export CXX="${CROSS_TOOLCHAIN_ROOT}/bin/${triplet}-clang++"
export PKG_CONFIG="${CROSS_TOOLCHAIN_PKGCONF_PREFIX}.${triplet_arch}"

exec "${_go_exec_}" "$@"

EOF
)
echo -e "${CGOTOOL_WRPPER}" > "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}"; chmod +x "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}"
ln -sfn "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}" "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}.x86_64"
ln -sfn "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}" "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}.aarch64"
EOT



RUN <<EOT
#!/usr/bin/env bash
set -e

CROSSGO_WRPPER=$(cat <<- 'EOF'
#!/usr/bin/env bash
set -e

_go_exec_="${GOLANG_SDK_ROOT}/bin/go"
# { command -v go >/dev/null 2>&1; } && \
#   { _go_exec_="$(command -v go)"; }


PKG_ARCH=${PKG_ARCH:-${CPU_ARCH:-"$(${_go_exec_} env GOARCH)"}}

case ${PKG_ARCH} in
  "amd64")
    TARGET_TRIPLE="x86_64"
    ;;
  "arm64")
    TARGET_TRIPLE="aarch64"
    ;;
  *)
    printf "\e[1m\e[31m%s\e[0m\n" "Unsupported PKG_ARCH: '${PKG_ARCH}'."
    exit 1
    ;;
esac

exec "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}.${TARGET_TRIPLE}" "$@"

EOF
)
echo -e "${CROSSGO_WRPPER}" > "/usr/local/bin/go"; chmod +x "/usr/local/bin/go"
EOT
