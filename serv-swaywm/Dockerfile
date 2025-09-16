FROM debian:12 AS base
SHELL ["/bin/bash", "-c"]
ENV TZ='UTC' \
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
RUN ln -sfn /usr/share/zoneinfo/${TZ} /etc/localtime
ENV STAGING='/opt/staging'



FROM base AS builder
RUN ln -sf /usr/bin/pkgconf /usr/local/bin/pkg-config
RUN apt-get update -qq \
  && apt-get install -qqy \
    curl gcc g++ pkgconf-bin python3-pip \
  && apt-get clean all -qqy
RUN pip3 config set global.index-url "https://mirrors.bfsu.edu.cn/pypi/web/simple"
RUN pip3 config set global.break-system-packages true
RUN pip3 install --no-cache-dir --upgrade ninja meson && pip3 cache purge
WORKDIR '/opt'

RUN apt-get update -qq \
  && apt-get install -qqy \
    libfontconfig1-dev \
  && apt-get clean all -qqy
COPY "libpixman.sh" "libpixman.sh"
RUN ./libpixman.sh
COPY "libcairo.sh" "libcairo.sh"
RUN ./libcairo.sh

RUN apt-get update -qq \
  && apt-get install -qqy \
    autoconf automake libtool libltdl-dev make \
  && apt-get clean all -qqy
COPY "libffi8.sh" "libffi8.sh"
RUN ./libffi8.sh

RUN apt-get update -qq \
  && apt-get install -qqy \
    cmake \
  && apt-get clean all -qqy
COPY "libzlib-ng.sh" "libzlib-ng.sh"
RUN ./libzlib-ng.sh
COPY "libpcre8.sh" "libpcre8.sh"
RUN ./libpcre8.sh
COPY "libglib2.sh" "libglib2.sh"
RUN ./libglib2.sh
COPY "libharfbuzz.sh" "libharfbuzz.sh"
RUN ./libharfbuzz.sh
COPY "libfribidi.sh" "libfribidi.sh"
RUN ./libfribidi.sh
COPY "libpango.sh" "libpango.sh"
RUN ./libpango.sh

COPY "libdrm2.sh" "libdrm2.sh"
RUN ./libdrm2.sh
COPY "libaml.sh" "libaml.sh"
RUN ./libaml.sh
COPY "libneatvnc.sh" "libneatvnc.sh"
RUN ./libneatvnc.sh

RUN apt-get update -qq \
  && apt-get install -qqy \
    libxkbcommon-dev patch \
  && apt-get clean all -qqy
COPY "libjansson.sh" "libjansson.sh"
RUN ./libjansson.sh
COPY "libwayland.sh" "libwayland.sh"
RUN ./libwayland.sh
COPY "wayvnc.sh"    "wayvnc.sh"
COPY "wayvnc.patch" "wayvnc.patch"
RUN ./wayvnc.sh

COPY "libwayland-protocols.sh" "libwayland-protocols.sh"
RUN ./libwayland-protocols.sh
COPY "libliftoff.sh" "libliftoff.sh"
RUN ./libliftoff.sh
COPY "libwlroots.sh" "libwlroots.sh"
RUN ./libwlroots.sh

RUN apt-get update -qq \
  && apt-get install -qqy \
    libudev-dev shared-mime-info gettext \
  && apt-get clean all -qqy
COPY "libjson-c.sh" "libjson-c.sh"
RUN ./libjson-c.sh
COPY "libevdev.sh" "libevdev.sh"
RUN ./libevdev.sh
COPY "libinput.sh" "libinput.sh"
RUN ./libinput.sh
COPY "libjpeg80.sh" "libjpeg80.sh"
RUN ./libjpeg80.sh
COPY "libgdk-pixbuf.sh" "libgdk-pixbuf.sh"
RUN ./libgdk-pixbuf.sh
COPY "sway.sh" "sway.sh"
RUN ./sway.sh

COPY "tofi.sh" "tofi.sh"
RUN ./tofi.sh



FROM base
COPY --from=builder ${STAGING}/bin   /usr/local/bin
COPY --from=builder ${STAGING}/etc   /etc
RUN apt-get update -qq \
  && apt-get install -qqy \
    libxkbcommon0 libfontconfig1 \
  && apt-get clean all -qqy

RUN apt-get update -qq \
  && apt-get install -qqy \
    curl tree bc locales \
  && apt-get clean all -qqy
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
RUN apt-get update -qq \
  && apt-get install -qqy \
    python3-websockify \
  && apt-get clean all -qqy


ENV WLR_BACKENDS='headless'
ENV WLR_RENDERER='pixman'
ENV WLR_LIBINPUT_NO_DEVICES='1'
ENV XDG_RUNTIME_DIR='/opt/xdg'
ENV SWAYSOCK="${XDG_RUNTIME_DIR}/sway-ipc.sock"

COPY .entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
