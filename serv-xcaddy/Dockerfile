ARG CONTAINER_REGISTRY_PREFIX
ARG TOOLCHAIN_IMAGE_VERSION="07dcb8281c82686f54791e993f5f894360dfa5c9"
FROM --platform=${BUILDPLATFORM} ${CONTAINER_REGISTRY_PREFIX}valord577/linux-cross-cgo:${TOOLCHAIN_IMAGE_VERSION} AS builder
ARG TARGETOS
ARG TARGETARCH

ENV CADDYSERV_VERSION="v2.8.4"
WORKDIR "/caddysrc"
RUN <<EOT
#!/usr/bin/env bash
set -e

# git config --global http.proxy http://192.168.1.241:8118
# git config --global https.proxy $(git config --global --get http.proxy)
git clone --no-checkout --single-branch --depth=1 \
  https://github.com/caddyserver/caddy.git .
git fetch --tags --prune --prune-tags --no-recurse-submodules --depth=1
git checkout ${CADDYSERV_VERSION} -- cmd/caddy/main.go

mv cmd/caddy/main.go .; rm -rf .git; rm -rf cmd
set -x
{
  LINE_NUM=$(grep -n 'modules/standard' main.go | cut -d ':' -f 1)
  LINE_NUM=$(expr ${LINE_NUM} + 1)
  # caddy plugin(s) here...
  sed -i "${LINE_NUM}s@^@\t_ \"github.com/caddy-dns/alidns\"\n@" main.go
}
set +x

# export GOPROXY=https://goproxy.cn,direct; export GOSUMDB=sum.golang.google.cn
go mod init caddy; go mod tidy; export GO111MODULE=on
PKG_LIBC="musl" PKG_ARCH="${TARGETARCH}" go build -v -o caddy_${TARGETARCH}
EOT


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
COPY --from=builder /caddysrc/caddy_${TARGETARCH} "/opt/caddy"

# See https://caddyserver.com/docs/conventions#file-locations for details
ENV XDG_DATA_HOME="/data"
CMD ["/opt/caddy", "run", "--config", "/opt/caddyfile", "--adapter", "caddyfile"]
