# syntax=docker/dockerfile:1
ARG IMAGE_VER="cb31f56ad811d125a19e6529621b67aa8f21f21f"
FROM --platform=${TARGETPLATFORM} valord577/cgo-linux-g217:${IMAGE_VER} as builder

RUN go install -v 'github.com/caddyserver/xcaddy/cmd/xcaddy@latest'
RUN <<EOT
#!/usr/bin/env bash
set -e

export XCADDY_GO_BUILD_FLAGS="-ldflags '-w -s'"
$(go env GOPATH)/bin/xcaddy build 'master' --output '/opt/caddy' \
  --with github.com/caddy-dns/alidns
EOT



FROM --platform=${TARGETPLATFORM} debian:12.5

ARG TARGETOS
ARG TARGETARCH

ENV TZ=UTC \
    DEBIAN_FRONTEND=noninteractive
RUN echo 'Acquire::http::Pipeline-Depth "0";' > /etc/apt/apt.conf.d/99nopipelining
RUN echo 'APT::Install-Recommends 0;\nAPT::Install-Suggests 0;' > /etc/apt/apt.conf.d/99norecommends
RUN sed -i s@/deb.debian.org/@/mirrors.bfsu.edu.cn/@g /etc/apt/sources.list.d/**
RUN apt-get update -qq \
  && apt-get install -qqy tzdata ca-certificates \
  && apt-get clean all -qqy
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

COPY --from=builder "/opt/caddy" "/opt/caddy"

# See https://caddyserver.com/docs/conventions#file-locations for details
ENV XDG_DATA_HOME /data
CMD ["/opt/caddy", "run", "--config", "/opt/caddyfile", "--adapter", "caddyfile"]
