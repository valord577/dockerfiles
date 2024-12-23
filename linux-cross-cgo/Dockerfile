ARG CONTAINER_REGISTRY_PREFIX
ARG SYSROOT_LINUX_HEADER_UAPI="310"
ARG SYSROOT_LIBSTDCXX_GCC_VER="4"
ARG TOOLCHAIN_IMAGE_VERSION="20241223T061436Z-02a231a"
FROM ${CONTAINER_REGISTRY_PREFIX}valord577/cross-sysroot-linux${SYSROOT_LINUX_HEADER_UAPI}-gcc${SYSROOT_LIBSTDCXX_GCC_VER}:${TOOLCHAIN_IMAGE_VERSION}

RUN apt-get update -qq \
  && apt-get install -qqy \
    tree patchelf curl zip unzip xz-utils git file \
  && apt-get clean all -qqy

ARG TARGETOS
ARG TARGETARCH

ENV GOLANG_SDK="1.23.4"
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
triplet="${basename##cgotool-wrapper\.}"

if [[ "${triplet}" =~ ^x86_64.*$ ]]; then
  export GOARCH=amd64; export GOAMD64=v3
elif [[ "${triplet}" =~ ^aarch64.*$ ]]; then
  export GOARCH=arm64
elif [[ "${triplet}" =~ ^arm.*$ ]]; then
  export GOARCH=arm; export GOARM='7,hardfloat'
  __EXTRA_FLAGS__='-march=armv7-a -mfpu=neon-vfpv4'
fi

export CGO_ENABLED=1
export GOTOOLCHAIN=local
export AR="llvm-ar"
export CGO_LDFLAGS="$(${_go_exec_} env CGO_LDFLAGS) -fuse-ld=lld --sysroot=${CROSS_TOOLCHAIN_ROOT}/${triplet}"
export CC="clang --target=${triplet} --gcc-toolchain=${CROSS_TOOLCHAIN_ROOT}/${triplet}/usr --sysroot=${CROSS_TOOLCHAIN_ROOT}/${triplet} ${__EXTRA_FLAGS__}"
export CXX="clang++ --target=${triplet} --gcc-toolchain=${CROSS_TOOLCHAIN_ROOT}/${triplet}/usr --sysroot=${CROSS_TOOLCHAIN_ROOT}/${triplet} ${__EXTRA_FLAGS__}"
export PKG_CONFIG="${CROSS_TOOLCHAIN_ROOT}/pkgconf-wrapper.${triplet}"

exec "${_go_exec_}" "$@"

EOF
)
echo -e "${CGOTOOL_WRPPER}" > "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}"; chmod +x "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}"
ln -sfn "$(basename ${CROSS_TOOLCHAIN_CGOTOOL_PREFIX})" "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}.aarch64-unknown-linux-gnu"
ln -sfn "$(basename ${CROSS_TOOLCHAIN_CGOTOOL_PREFIX})" "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}.aarch64-unknown-linux-musl"
ln -sfn "$(basename ${CROSS_TOOLCHAIN_CGOTOOL_PREFIX})" "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}.arm-unknown-linux-gnueabihf"
ln -sfn "$(basename ${CROSS_TOOLCHAIN_CGOTOOL_PREFIX})" "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}.x86_64-pc-linux-gnu"
ln -sfn "$(basename ${CROSS_TOOLCHAIN_CGOTOOL_PREFIX})" "${CROSS_TOOLCHAIN_CGOTOOL_PREFIX}.x86_64-pc-linux-musl"
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


PKG_LIBC=${PKG_LIBC:-"gnu"}
PKG_ARCH=${PKG_ARCH:-${CPU_ARCH:-"$(${_go_exec_} env GOARCH)"}}


case ${PKG_ARCH} in
  "amd64")
    TARGET_TRIPLE="x86_64-pc-linux-${PKG_LIBC}"
    ;;
  "arm64")
    TARGET_TRIPLE="aarch64-unknown-linux-${PKG_LIBC}"
    ;;
  "armv7" | "arm")
    TARGET_TRIPLE="arm-unknown-linux-gnueabihf"
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
