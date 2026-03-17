FROM alpine:3.20.3
ENV TZ=UTC
ENV XZ_OPT='--threads=0'
ENV CCACHE_DIR="/ccache"
RUN sed -i s@/dl-cdn.alpinelinux.org/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apk/repositories
RUN apk update \
  && apk add --no-cache --no-check-certificate --no-interactive \
    tzdata ca-certificates \
  && apk cache -f --no-interactive purge \
  && apk cache -f --no-interactive clean
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

ARG TARGETOS
ARG TARGETARCH

RUN apk update \
  && apk add --no-cache --no-check-certificate --no-interactive \
    curl xz \
  && apk cache -f --no-interactive purge \
  && apk cache -f --no-interactive clean

ARG _JELLYFIN_VER_="10.10.3"
ARG _JELLYFIN_ROOT_="/opt"
WORKDIR "${_JELLYFIN_ROOT_}"
RUN <<EOT
#! /bin/sh
set -e

_JELLYFIN_URL_="https://repo.jellyfin.org/files/server/linux/stable/v${_JELLYFIN_VER_}/${TARGETARCH}-musl/jellyfin_${_JELLYFIN_VER_}-${TARGETARCH}-musl.tar.xz"
curl --fail-with-body -sSL -o "1.tar.xz" --url "${_JELLYFIN_URL_}"
trap 'rm -rf "1.tar.xz"' EXIT INT TERM
mkdir -p "${_JELLYFIN_ROOT_}" && tar -xvf "1.tar.xz" -C "${_JELLYFIN_ROOT_}" --strip-components=1 --no-same-owner
EOT
ENV JELLYFIN_WEB_DIR="${_JELLYFIN_ROOT_}/jellyfin-web"

ARG _JELLYFIN_PERMANENT_="/jellyfin"
ENV JELLYFIN_DATA_DIR="${_JELLYFIN_PERMANENT_}/data"
ENV JELLYFIN_CONFIG_DIR="${_JELLYFIN_PERMANENT_}/config"
ENV JELLYFIN_CACHE_DIR="${_JELLYFIN_PERMANENT_}/cache"
ENV JELLYFIN_LOG_DIR="${_JELLYFIN_PERMANENT_}/logs"
ENV JELLYFIN_FFMPEG="${_JELLYFIN_PERMANENT_}/ffmpeg"

RUN apk update \
  && apk add --no-cache --no-check-certificate --no-interactive \
    icu-libs fontconfig \
  && apk cache -f --no-interactive purge \
  && apk cache -f --no-interactive clean
CMD ["/opt/jellyfin"]
