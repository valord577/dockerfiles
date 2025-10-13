FROM debian:12 AS base
SHELL ["/bin/bash", "-c"]
ENV TZ=UTC \
    DEBIAN_FRONTEND=noninteractive
ENV XZ_OPT='--threads=0'
ENV CCACHE_DIR="/ccache"
RUN rm -f -- /etc/apt/apt.conf.d/70debconf
RUN echo 'Acquire::http::Pipeline-Depth "0";' > /etc/apt/apt.conf.d/99nopipelining
RUN echo 'APT::Install-Recommends 0;\nAPT::Install-Suggests 0;' > /etc/apt/apt.conf.d/99norecommends
RUN sed -i s@/deb.debian.org/@/mirrors.bfsu.edu.cn/@g /etc/apt/sources.list.d/**
RUN apt update -qq \
  && apt install -qqy tzdata ca-certificates \
  && apt clean all -qqy
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime
ENV CROSS_TOOLCHAIN_ROOT="/crosstool"
WORKDIR "${CROSS_TOOLCHAIN_ROOT}"
ENV CT_PREFIX="${CROSS_TOOLCHAIN_ROOT}/release"


FROM base AS crosstool-ng
RUN ln -sf /usr/bin/pkgconf /usr/local/bin/pkg-config
RUN apt update -qq \
  && apt install -qqy \
    curl unzip xz-utils git pkgconf-bin autoconf automake \
    gcc g++ flex texinfo bzip2 help2man file patch gawk \
    make libtool-bin python3 bison libncurses-dev ccache \
  && apt clean all -qqy

ENV CT_TAG_NAME="crosstool-ng-1.27.0"
ENV CT_LOCAL_TARBALLS_DIR="${CROSS_TOOLCHAIN_ROOT}/src"
RUN <<EOT
#!/usr/bin/env bash
set -e

git config --global --add safe.directory "*"
git init
git remote add x https://github.com/crosstool-ng/crosstool-ng.git
git fetch --no-tags --prune --no-recurse-submodules --depth=1 x +refs/tags/${CT_TAG_NAME}
git checkout FETCH_HEAD

./bootstrap
./configure --disable-rpath --disable-nls --enable-local
make -j $(nproc)
EOT


ARG SYSROOT_LINUX_HEADER_UAPI="310"
ARG SYSROOT_LIBSTDCXX_GCC_VER="7"
# ["amd64", "arm64", "armhf"] x ["musl", "gnu"]
ARG SYSROOT_TARGET_ARCH="amd64"
ENV SYSROOT_TARGET_ARCH="${SYSROOT_TARGET_ARCH}"
ARG SYSROOT_TARGET_LIBC="gnu"
ENV SYSROOT_TARGET_LIBC="${SYSROOT_TARGET_LIBC}"

COPY ".config.linux${SYSROOT_LINUX_HEADER_UAPI}.gcc${SYSROOT_LIBSTDCXX_GCC_VER}.${SYSROOT_TARGET_ARCH}.${SYSROOT_TARGET_LIBC}.ini" ".config"
RUN ./ct-ng show-config; ./ct-ng source;
# due to the limited usage of GH action, build step by step
RUN ./ct-ng +kernel_headers; \
  ./ct-ng cc_core; ./ct-ng libc_main; \
  ./ct-ng cc_for_build; ./ct-ng cc_for_host;

COPY "organize_sysroot.sh" "organize_sysroot.sh"
RUN ./organize_sysroot.sh



FROM base
COPY --from=crosstool-ng ${CT_PREFIX} .
