FROM debian:sid-20250811 AS base
SHELL ["/bin/bash", "-c"]
ENV TZ='UTC' \
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
RUN ln -sfn /usr/share/zoneinfo/${TZ} /etc/localtime
ENV STAGING='/opt/staging'



FROM base AS builder
RUN ln -sf /usr/bin/pkgconf /usr/local/bin/pkg-config
RUN apt update -qq \
  && apt install -qqy \
    curl gcc g++ pkgconf-bin python3-pip \
  && apt clean all -qqy
RUN pip3 config set global.index-url "https://mirrors.bfsu.edu.cn/pypi/web/simple"
RUN pip3 config set global.break-system-packages true
RUN pip3 install --no-cache-dir --upgrade ninja meson && pip3 cache purge
WORKDIR '/opt'

RUN apt update -qq \
  && apt install -qqy \
    libfontconfig1-dev libpixman-1-dev \
  && apt clean all -qqy
COPY "libcairo.sh" "libcairo.sh"
RUN ./libcairo.sh

RUN apt update -qq \
  && apt install -qqy \
    libglib2.0-dev \
  && apt clean all -qqy
COPY "libharfbuzz.sh" "libharfbuzz.sh"
RUN ./libharfbuzz.sh

RUN apt update -qq \
  && apt install -qqy \
    libfribidi-dev \
  && apt clean all -qqy
COPY "libpango.sh" "libpango.sh"
RUN ./libpango.sh

RUN apt update -qq \
  && apt install -qqy \
    libdrm-dev libaml-dev libxxhash-dev \
  && apt clean all -qqy
COPY "libneatvnc.sh" "libneatvnc.sh"
RUN ./libneatvnc.sh

RUN apt update -qq \
  && apt install -qqy \
    libwayland-dev libxkbcommon-dev libjansson-dev patch \
  && apt clean all -qqy
COPY "wayvnc.sh"    "wayvnc.sh"
COPY "wayvnc.patch" "wayvnc.patch"
RUN ./wayvnc.sh

RUN apt update -qq \
  && apt install -qqy \
    wayland-protocols libliftoff-dev \
  && apt clean all -qqy
COPY "libwlroots.sh" "libwlroots.sh"
RUN ./libwlroots.sh

RUN apt update -qq \
  && apt install -qqy \
    libjson-c-dev libgdk-pixbuf-2.0-dev libevdev-dev libinput-dev \
  && apt clean all -qqy
COPY "sway.sh" "sway.sh"
RUN ./sway.sh

COPY "wmenu.sh" "wmenu.sh"
RUN ./wmenu.sh



FROM base
COPY --from=builder ${STAGING}/bin   /usr/local/bin
COPY --from=builder ${STAGING}/etc   /etc
COPY --from=builder ${STAGING}/share /share
RUN apt update -qq \
  && apt install -qqy \
    libglib2.0-0t64 libdrm2 libpixman-1-0 libevdev2  \
    libxkbcommon0 libfontconfig1 libgdk-pixbuf-2.0-0 \
    libwayland-cursor0 libwayland-client0 libwayland-server0 \
    libaml0 libjansson4 libfribidi0 libjson-c5 \
  && apt clean all -qqy

RUN apt update -qq \
  && apt install -qqy \
    curl tree bc locales \
  && apt clean all -qqy
ENV TZ='Asia/Shanghai'
RUN ln -sfn /usr/share/zoneinfo/${TZ} /etc/localtime
RUN echo 'en_US.UTF-8 UTF-8' >>/etc/locale.gen && locale-gen
ENV LC_ALL='en_US.UTF-8' LANG='en_US.UTF-8' LANGUAGE='en_US:en'

RUN <<EOT
#!/usr/bin/env bash
set -e

VER_NOVNC='v1.6.0'
curl --fail-with-body -sSL -o '1.tar.gz' \
  --url "https://salsa.debian.org/openstack-team/third-party/novnc/-/archive/${VER_NOVNC}/novnc-${VER_NOVNC}.tar.gz"
mkdir -p '/opt/novnc'; tar -xvf '1.tar.gz' -C '/opt/novnc' --strip-components=1 --no-same-owner

rm -f '1.tar.gz'
EOT
COPY assets/. /
RUN apt update -qq \
  && apt install -qqy \
    python3-websockify \
  && apt clean all -qqy


ENV WLR_BACKENDS='headless'
ENV WLR_RENDERER='pixman'
ENV WLR_LIBINPUT_NO_DEVICES='1'
ENV XDG_RUNTIME_DIR='/opt/xdg'
ENV SWAYSOCK="${XDG_RUNTIME_DIR}/sway-ipc.sock"

COPY .entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
