# syntax=docker/dockerfile:1
ARG IMAGE_VER="046450f7a422ddcea9ad4a5a23d86f94ba33e477"
FROM --platform=${TARGETPLATFORM} valord577/cgo-linux-g217:${IMAGE_VER} as builder

RUN go install -v 'github.com/caddyserver/xcaddy/cmd/xcaddy@v0.4.2'
RUN <<EOT
#!/usr/bin/env bash
set -e

export XCADDY_GO_BUILD_FLAGS="-ldflags '-w -s'"
$(go env GOPATH)/bin/xcaddy build 'v2.8.4' --output '/opt/caddy' \
  --with github.com/caddy-dns/alidns
EOT



FROM --platform=${TARGETPLATFORM} debian:12.6

ARG TARGETOS
ARG TARGETARCH

ENV TZ=UTC \
    DEBIAN_FRONTEND=noninteractive
RUN rm -f -- /etc/apt/apt.conf.d/70debconf
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
