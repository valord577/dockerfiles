# syntax=docker/dockerfile:1
FROM --platform=${TARGETPLATFORM} centos:7.9.2009

ARG TARGETOS
ARG TARGETARCH

ENV TZ=UTC
RUN <<EOT
#!/usr/bin/env bash
set -e

yum --noplugins --nogpgcheck makecache
yum --noplugins --nogpgcheck -y install \
  centos-release-scl-rh epel-release
yum --noplugins --nogpgcheck -y install \
  tzdata ca-certificates wget \
  rh-git227-git \
  devtoolset-10-gcc devtoolset-10-gcc-c++
yum --noplugins --nogpgcheck clean all

localedef -c -f UTF-8 -i en_US en_US.UTF-8
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

cat > "/opt/rh/scl_enable" <<- EOF
#!/usr/bin/env bash

# Enabling Software Collections Binaries On A Docker Image
#   see https://austindewey.com/2019/03/26/enabling-software-collections-binaries-on-a-docker-image/

# IMPORTANT:
#   Do not add more content to this file unless you know what you are
#   doing. This file is sourced everytime the shell session is opened.
#
# This will make scl collection binaries work out of box.
unset BASH_ENV PROMPT_COMMAND ENV
source scl_source enable rh-git227
source scl_source enable devtoolset-10

EOF
EOT
ENV BASH_ENV="/opt/rh/scl_enable" \
    ENV="/opt/rh/scl_enable" \
    PROMPT_COMMAND=". /opt/rh/scl_enable"


ENV GOLANG_SDK="1.21.7"
ENV GOLANG_SDK_URL="https://dl.google.com/go/go${GOLANG_SDK}.linux-${TARGETARCH}.tar.gz"
ENV GOLANG_SDK_ROOT="/opt/go"
ENV PATH="${GOLANG_SDK_ROOT}/bin:${PATH}"
RUN <<EOT
#!/usr/bin/env bash
set -e

wget -q -O "gosdk.tar.gz" "${GOLANG_SDK_URL}"
trap 'rm -rf "gosdk.tar.gz"' EXIT INT TERM
mkdir -p "${GOLANG_SDK_ROOT}" && tar xf "gosdk.tar.gz" -C "${GOLANG_SDK_ROOT}" --strip-components=1
EOT
ENV CGO_ENABLED=1
ENV GOTOOLCHAIN=local
