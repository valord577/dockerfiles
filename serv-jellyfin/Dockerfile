# syntax=docker/dockerfile:1
FROM debian:12.7
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

ARG TARGETOS
ARG TARGETARCH

RUN apt-get update -qq \
  && apt-get install -qqy curl xz-utils \
  && apt-get clean all -qqy

ARG _JELLYFIN_VER_="10.9.11"
ARG _JELLYFIN_ROOT_="/jellyfin"
ARG _JELLYFIN_PERMANENT_="${_JELLYFIN_ROOT_}/permanent"
WORKDIR "${_JELLYFIN_ROOT_}"
RUN <<EOT
#!/usr/bin/env bash
set -e

_JELLYFIN_URL_="https://repo.jellyfin.org/files/server/linux/stable/v${_JELLYFIN_VER_}/${TARGETARCH}/jellyfin_${_JELLYFIN_VER_}-${TARGETARCH}.tar.xz"
curl --fail-with-body -sSL -o "jellyfin.tar.xz" --url "${_JELLYFIN_URL_}"
trap 'rm -rf "jellyfin.tar.xz"' EXIT INT TERM
mkdir -p "${_JELLYFIN_ROOT_}/jellyfin" && tar -xvf "jellyfin.tar.xz" -C "${_JELLYFIN_ROOT_}/jellyfin" --strip-components=1 --no-same-owner
EOT
ENV JELLYFIN_WEB_DIR="${_JELLYFIN_ROOT_}/jellyfin/jellyfin-web"
ENV JELLYFIN_DATA_DIR="${_JELLYFIN_PERMANENT_}/data"
ENV JELLYFIN_CONFIG_DIR="${_JELLYFIN_PERMANENT_}/config"
ENV JELLYFIN_CACHE_DIR="${_JELLYFIN_PERMANENT_}/cache"
ENV JELLYFIN_LOG_DIR="${_JELLYFIN_PERMANENT_}/logs"
ENV JELLYFIN_FFMPEG="${_JELLYFIN_PERMANENT_}/ffmpeg"

RUN apt-get update -qq \
  && apt-get install -qqy libicu72 libfontconfig1 \
  && apt-get clean all -qqy
CMD ["/jellyfin/jellyfin/jellyfin"]
