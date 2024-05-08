# syntax=docker/dockerfile:1
FROM --platform=${TARGETPLATFORM} centos:7.9.2009

ARG TARGETOS
ARG TARGETARCH

RUN rm -f -- /etc/yum.repos.d/**
COPY "yum.conf"  "/etc/yum.conf"
COPY "epel.repo" "/etc/yum.repos.d/epel.repo"
COPY "base.repo" "/etc/yum.repos.d/base.repo"
RUN [ "$(uname -m)" == "x86_64" ] || \
  sed -i "s@centos/$releasever@centos-altarch/$releasever@g" /etc/yum.repos.d/base.repo
RUN localedef -c -f UTF-8 -i en_US en_US.UTF-8
ENV TZ=UTC
RUN yum -y install tzdata \
  && yum clean all
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime
ENV XZ_OPT='--threads=0'

RUN <<EOT
#!/usr/bin/env bash
set -e

yum -y install \
  wget rh-git227-git \
  devtoolset-10-gcc  \
  devtoolset-10-gcc-c++
yum clean all

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
ENV CGO_ENABLED=1
ENV GOTOOLCHAIN=local


# extra libraries
RUN yum -y install \
  ca-certificates \
  && yum clean all
