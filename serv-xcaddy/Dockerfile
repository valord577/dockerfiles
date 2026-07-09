ARG CONTAINER_REGISTRY_PREFIX
ARG TOOLCHAIN_IMAGE_VERSION="20260709T161253Z-f8d59b5"
FROM --platform=${BUILDPLATFORM} ${CONTAINER_REGISTRY_PREFIX}valord577/crossbuild-all-in-one:${TOOLCHAIN_IMAGE_VERSION} AS builder
ARG TARGETOS
ARG TARGETARCH

ENV CADDYSERV_VERSION="v2.11.4"
WORKDIR "/caddysrc"
RUN <<EOT
#!/usr/bin/env bash
set -e

#git config --global http.proxy http://192.168.1.241:8118
#git config --global https.proxy $(git config --global --get http.proxy)
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

#export GOPROXY=https://goproxy.cn,direct; export GOSUMDB=sum.golang.google.cn
go="/opt/toolchain/linux310-gcc7/cgotool-wrapper.${TARGETARCH}-musl"
${go} mod init caddy; ${go} mod tidy; ${go} build -v -o caddy_${TARGETARCH}
EOT


FROM alpine:edge
ENV TZ='UTC' XZ_OPT='--threads=0'
ARG PACKAGE_MANAGER_USE_MIRROR='1'
RUN [ "${PACKAGE_MANAGER_USE_MIRROR}" == "0" ] || \
  sed -i s@/dl-cdn.alpinelinux.org/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apk/repositories
RUN apk update \
  && apk add --no-cache --no-check-certificate --no-interactive \
    tzdata ca-certificates \
  && apk cache -f --no-interactive purge \
  && apk cache -f --no-interactive clean
RUN ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime

ARG TARGETOS
ARG TARGETARCH
COPY --from=builder /caddysrc/caddy_${TARGETARCH} "/opt/caddy"

# See https://caddyserver.com/docs/conventions#file-locations for details
ENV XDG_DATA_HOME="/data"
CMD ["/opt/caddy", "run", "--config", "/opt/caddyfile", "--adapter", "caddyfile"]
