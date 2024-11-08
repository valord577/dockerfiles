# syntax=docker/dockerfile:1
FROM debian:12.7 AS base
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
ENV CROSS_TOOLCHAIN_ROOT="/crosstool"
WORKDIR "${CROSS_TOOLCHAIN_ROOT}"
ENV CT_PREFIX="${CROSS_TOOLCHAIN_ROOT}/release"


FROM base AS crosstool-base
RUN ln -sf /usr/bin/pkgconf /usr/local/bin/pkg-config
RUN apt-get update -qq \
  && apt-get install -qqy \
  curl unzip xz-utils git pkgconf-bin autoconf automake \
  gcc g++ flex texinfo bzip2 help2man file patch gawk \
  make libtool-bin python3 bison libncurses-dev ccache \
  && apt-get clean all -qqy

ENV CT_TAG_NAME="crosstool-ng-1.26.0"
ENV CT_LOCAL_TARBALLS_DIR="${CROSS_TOOLCHAIN_ROOT}/src"
RUN <<EOT
#!/usr/bin/env bash
set -e

git clone --no-checkout --single-branch --depth=1 https://github.com/crosstool-ng/crosstool-ng.git .
git fetch --tags --prune --prune-tags --no-recurse-submodules --depth=1; git checkout ${CT_TAG_NAME}

export CC='ccache gcc'
export CXX='ccache g++'
export PKG_CONFIG=$(command -v pkgconf)
./bootstrap
./configure --disable-rpath --disable-nls --enable-local
make -j
EOT

FROM crosstool-base AS ct-amd64-glibc
COPY ".config.linux.glibc217.amd64" ".config"
RUN ./ct-ng show-config; ./ct-ng source;
# due to the limited usage of GH action, build step by step
RUN ./ct-ng +kernel_headers; \
  ./ct-ng cc_core; ./ct-ng libc_main; \
  ./ct-ng cc_for_build; ./ct-ng cc_for_host;
ENV CROSS_TRIPLE="x86_64-pc-linux-gnu"
RUN cd ${CT_PREFIX}; mkdir lib; mv ${CROSS_TRIPLE} tmp; \
  mv tmp/lib/gcc ./lib; mv tmp/${CROSS_TRIPLE} .; rm -rf tmp; \
  rm -rf ./lib/gcc/*/*/{include-fixed,install-tools,plugin}; \
  rm -rf ${CROSS_TRIPLE}/{bin,debug-root}; \
  rm -rf ${CROSS_TRIPLE}/sysroot/{etc,sbin,var}; \
  rm -rf ${CROSS_TRIPLE}/sysroot/usr/{bin,libexec,sbin,share};
RUN cd ${CT_PREFIX}; \
  rm -rf ${CROSS_TRIPLE}/sysroot/lib/libitm.spec; \
  rm -rf ${CROSS_TRIPLE}/sysroot/lib/libstdc++.so*gdb.py; \
  mv lib/gcc ${CROSS_TRIPLE}/sysroot/usr/lib; \
  cd ${CROSS_TRIPLE}/include; CXXDIR="$(dirname c++/*/${CROSS_TRIPLE})"; cd -; \
  mkdir -p ${CROSS_TRIPLE}/sysroot/usr/include/${CROSS_TRIPLE}/${CXXDIR}; \
  mv ${CROSS_TRIPLE}/include/${CXXDIR}/${CROSS_TRIPLE}/** ${CROSS_TRIPLE}/sysroot/usr/include/${CROSS_TRIPLE}/${CXXDIR}; \
  rm -rf ${CROSS_TRIPLE}/include/${CXXDIR}/${CROSS_TRIPLE}; \
  mv ${CROSS_TRIPLE}/include/** ${CROSS_TRIPLE}/sysroot/usr/include; \
  rm -rf lib ${CROSS_TRIPLE}/{include,lib,lib64}; \
  mv ${CROSS_TRIPLE}/sysroot/** ${CROSS_TRIPLE}; rm -rf ${CROSS_TRIPLE}/sysroot;
FROM base AS target-ct-amd64-glibc
COPY --from=ct-amd64-glibc ${CT_PREFIX} .

FROM crosstool-base AS ct-arm64-glibc
COPY ".config.linux.glibc217.arm64" ".config"
RUN ./ct-ng show-config; ./ct-ng source;
# due to the limited usage of GH action, build step by step
RUN ./ct-ng +kernel_headers; \
  ./ct-ng cc_core; ./ct-ng libc_main; \
  ./ct-ng cc_for_build; ./ct-ng cc_for_host;
ENV CROSS_TRIPLE="aarch64-unknown-linux-gnu"
RUN cd ${CT_PREFIX}; mkdir lib; mv ${CROSS_TRIPLE} tmp; \
  mv tmp/lib/gcc ./lib; mv tmp/${CROSS_TRIPLE} .; rm -rf tmp; \
  rm -rf ./lib/gcc/*/*/{include-fixed,install-tools,plugin}; \
  rm -rf ${CROSS_TRIPLE}/{bin,debug-root}; \
  rm -rf ${CROSS_TRIPLE}/sysroot/{etc,sbin,var}; \
  rm -rf ${CROSS_TRIPLE}/sysroot/usr/{bin,libexec,sbin,share};
RUN cd ${CT_PREFIX}; \
  rm -rf ${CROSS_TRIPLE}/sysroot/lib/libitm.spec; \
  rm -rf ${CROSS_TRIPLE}/sysroot/lib/libstdc++.so*gdb.py; \
  mv lib/gcc ${CROSS_TRIPLE}/sysroot/usr/lib; \
  cd ${CROSS_TRIPLE}/include; CXXDIR="$(dirname c++/*/${CROSS_TRIPLE})"; cd -; \
  mkdir -p ${CROSS_TRIPLE}/sysroot/usr/include/${CROSS_TRIPLE}/${CXXDIR}; \
  mv ${CROSS_TRIPLE}/include/${CXXDIR}/${CROSS_TRIPLE}/** ${CROSS_TRIPLE}/sysroot/usr/include/${CROSS_TRIPLE}/${CXXDIR}; \
  rm -rf ${CROSS_TRIPLE}/include/${CXXDIR}/${CROSS_TRIPLE}; \
  mv ${CROSS_TRIPLE}/include/** ${CROSS_TRIPLE}/sysroot/usr/include; \
  rm -rf lib ${CROSS_TRIPLE}/{include,lib,lib64}; \
  mv ${CROSS_TRIPLE}/sysroot/** ${CROSS_TRIPLE}; rm -rf ${CROSS_TRIPLE}/sysroot;
FROM base AS target-ct-arm64-glibc
COPY --from=ct-arm64-glibc ${CT_PREFIX} .

FROM crosstool-base AS ct-armhf-glibc
COPY ".config.linux.glibc217.armhf" ".config"
RUN ./ct-ng show-config; ./ct-ng source;
# due to the limited usage of GH action, build step by step
RUN ./ct-ng +kernel_headers; \
  ./ct-ng cc_core; ./ct-ng libc_main; \
  ./ct-ng cc_for_build; ./ct-ng cc_for_host;
ENV CROSS_TRIPLE="arm-unknown-linux-gnueabihf"
RUN cd ${CT_PREFIX}; mkdir lib; mv ${CROSS_TRIPLE} tmp; \
  mv tmp/lib/gcc ./lib; mv tmp/${CROSS_TRIPLE} .; rm -rf tmp; \
  rm -rf ./lib/gcc/*/*/{include-fixed,install-tools,plugin}; \
  rm -rf ${CROSS_TRIPLE}/{bin,debug-root}; \
  rm -rf ${CROSS_TRIPLE}/sysroot/{etc,sbin,var}; \
  rm -rf ${CROSS_TRIPLE}/sysroot/usr/{bin,libexec,sbin,share};
RUN cd ${CT_PREFIX}; \
  rm -rf ${CROSS_TRIPLE}/sysroot/lib/libitm.spec; \
  rm -rf ${CROSS_TRIPLE}/sysroot/lib/libstdc++.so*gdb.py; \
  mv lib/gcc ${CROSS_TRIPLE}/sysroot/usr/lib; \
  cd ${CROSS_TRIPLE}/include; CXXDIR="$(dirname c++/*/${CROSS_TRIPLE})"; cd -; \
  mkdir -p ${CROSS_TRIPLE}/sysroot/usr/include/${CROSS_TRIPLE}/${CXXDIR}; \
  mv ${CROSS_TRIPLE}/include/${CXXDIR}/${CROSS_TRIPLE}/** ${CROSS_TRIPLE}/sysroot/usr/include/${CROSS_TRIPLE}/${CXXDIR}; \
  rm -rf ${CROSS_TRIPLE}/include/${CXXDIR}/${CROSS_TRIPLE}; \
  mv ${CROSS_TRIPLE}/include/** ${CROSS_TRIPLE}/sysroot/usr/include; \
  rm -rf lib ${CROSS_TRIPLE}/{include,lib,lib64}; \
  mv ${CROSS_TRIPLE}/sysroot/** ${CROSS_TRIPLE}; rm -rf ${CROSS_TRIPLE}/sysroot;
FROM base AS target-ct-armhf-glibc
COPY --from=ct-armhf-glibc ${CT_PREFIX} .

FROM crosstool-base AS ct-amd64-musl
COPY ".config.linux.musl.amd64" ".config"
RUN ./ct-ng show-config; ./ct-ng source;
# due to the limited usage of GH action, build step by step
RUN ./ct-ng +kernel_headers; \
  ./ct-ng cc_core; ./ct-ng libc_main; \
  ./ct-ng cc_for_build; ./ct-ng cc_for_host;
ENV CROSS_TRIPLE="x86_64-pc-linux-musl"
RUN cd ${CT_PREFIX}; mkdir lib; mv ${CROSS_TRIPLE} tmp; \
  mv tmp/lib/gcc ./lib; mv tmp/${CROSS_TRIPLE} .; rm -rf tmp; \
  rm -rf ./lib/gcc/*/*/{include-fixed,install-tools,plugin}; \
  rm -rf ${CROSS_TRIPLE}/{bin,debug-root}; \
  rm -rf ${CROSS_TRIPLE}/lib/ldscripts; \
  rm -rf ${CROSS_TRIPLE}/sysroot/{etc,sbin,var}; \
  rm -rf ${CROSS_TRIPLE}/sysroot/usr/{bin,libexec,sbin,share};
RUN cd ${CT_PREFIX}; \
  rm -rf ${CROSS_TRIPLE}/sysroot/lib/libitm.spec; \
  rm -rf ${CROSS_TRIPLE}/sysroot/lib/libstdc++.so*gdb.py; \
  mv lib/gcc ${CROSS_TRIPLE}/sysroot/usr/lib; \
  cd ${CROSS_TRIPLE}/include; CXXDIR="$(dirname c++/*/${CROSS_TRIPLE})"; cd -; \
  mkdir -p ${CROSS_TRIPLE}/sysroot/usr/include/${CROSS_TRIPLE}/${CXXDIR}; \
  mv ${CROSS_TRIPLE}/include/${CXXDIR}/${CROSS_TRIPLE}/** ${CROSS_TRIPLE}/sysroot/usr/include/${CROSS_TRIPLE}/${CXXDIR}; \
  rm -rf ${CROSS_TRIPLE}/include/${CXXDIR}/${CROSS_TRIPLE}; \
  mv ${CROSS_TRIPLE}/include/** ${CROSS_TRIPLE}/sysroot/usr/include; \
  rm -rf lib ${CROSS_TRIPLE}/{include,lib,lib64}; \
  mv ${CROSS_TRIPLE}/sysroot/** ${CROSS_TRIPLE}; rm -rf ${CROSS_TRIPLE}/sysroot;
FROM base AS target-ct-amd64-musl
COPY --from=ct-amd64-musl ${CT_PREFIX} .

FROM crosstool-base AS ct-arm64-musl
COPY ".config.linux.musl.arm64" ".config"
RUN ./ct-ng show-config; ./ct-ng source;
# due to the limited usage of GH action, build step by step
RUN ./ct-ng +kernel_headers; \
  ./ct-ng cc_core; ./ct-ng libc_main; \
  ./ct-ng cc_for_build; ./ct-ng cc_for_host;
ENV CROSS_TRIPLE="aarch64-unknown-linux-musl"
RUN cd ${CT_PREFIX}; mkdir lib; mv ${CROSS_TRIPLE} tmp; \
  mv tmp/lib/gcc ./lib; mv tmp/${CROSS_TRIPLE} .; rm -rf tmp; \
  rm -rf ./lib/gcc/*/*/{include-fixed,install-tools,plugin}; \
  rm -rf ${CROSS_TRIPLE}/{bin,debug-root}; \
  rm -rf ${CROSS_TRIPLE}/lib/ldscripts; \
  rm -rf ${CROSS_TRIPLE}/sysroot/{etc,sbin,var}; \
  rm -rf ${CROSS_TRIPLE}/sysroot/usr/{bin,libexec,sbin,share};
RUN cd ${CT_PREFIX}; \
  rm -rf ${CROSS_TRIPLE}/sysroot/lib/libitm.spec; \
  rm -rf ${CROSS_TRIPLE}/sysroot/lib/libstdc++.so*gdb.py; \
  mv lib/gcc ${CROSS_TRIPLE}/sysroot/usr/lib; \
  cd ${CROSS_TRIPLE}/include; CXXDIR="$(dirname c++/*/${CROSS_TRIPLE})"; cd -; \
  mkdir -p ${CROSS_TRIPLE}/sysroot/usr/include/${CROSS_TRIPLE}/${CXXDIR}; \
  mv ${CROSS_TRIPLE}/include/${CXXDIR}/${CROSS_TRIPLE}/** ${CROSS_TRIPLE}/sysroot/usr/include/${CROSS_TRIPLE}/${CXXDIR}; \
  rm -rf ${CROSS_TRIPLE}/include/${CXXDIR}/${CROSS_TRIPLE}; \
  mv ${CROSS_TRIPLE}/include/** ${CROSS_TRIPLE}/sysroot/usr/include; \
  rm -rf lib ${CROSS_TRIPLE}/{include,lib,lib64}; \
  mv ${CROSS_TRIPLE}/sysroot/** ${CROSS_TRIPLE}; rm -rf ${CROSS_TRIPLE}/sysroot;
FROM base AS target-ct-arm64-musl
COPY --from=ct-arm64-musl ${CT_PREFIX} .
