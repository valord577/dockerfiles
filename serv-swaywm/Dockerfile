FROM debian:sid-20251020 AS base
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
    curl gcc g++ cpp pkgconf python3-pip cmake \
  && apt-get clean all -qqy
RUN pip3 config set global.index-url "https://mirrors.bfsu.edu.cn/pypi/web/simple"
RUN pip3 config set global.break-system-packages true
RUN pip3 install --no-cache-dir --upgrade ninja meson && pip3 cache purge
WORKDIR '/opt'
ENV LD_LIBRARY_PATH="${STAGING}/lib"
ENV PKG_CONFIG_PATH="${STAGING}/lib/pkgconfig"

RUN apt-get update -qq \
  && apt-get install -qqy \
    gperf zlib1g-dev \
  && apt-get clean all -qqy
RUN rm -f /usr/lib/x86_64-linux-gnu/libz.a

COPY "libbrotli.sh" "libbrotli.sh"
RUN ./libbrotli.sh
COPY "libpng16.sh" "libpng16.sh"
RUN ./libpng16.sh
COPY "libfreetype6.sh" "libfreetype6.sh"
RUN ./libfreetype6.sh

COPY "libexpat.sh" "libexpat.sh"
RUN ./libexpat.sh
COPY "libjson-c.sh" "libjson-c.sh"
RUN ./libjson-c.sh
COPY "libfontconfig.sh" "libfontconfig.sh"
RUN ./libfontconfig.sh

COPY "libpixman.sh" "libpixman.sh"
RUN ./libpixman.sh
COPY "libcairo.sh" "libcairo.sh"
RUN ./libcairo.sh

RUN apt-get update -qq \
  && apt-get install -qqy \
    autoconf automake libtool libltdl-dev make \
  && apt-get clean all -qqy
RUN rm -f /usr/lib/x86_64-linux-gnu/libltdl.a
COPY "libffi8.sh" "libffi8.sh"
RUN ./libffi8.sh

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

RUN apt-get update -qq \
  && apt-get install -qqy \
    xutils-dev xfonts-utils \
    libx11-dev libxkbfile-dev libxcvt-dev libmd-dev libxshmfence-dev \
    libxcb-composite0-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-res0-dev \
  && apt-get clean all -qqy
RUN rm -f /usr/lib/x86_64-linux-gnu/libX11.a
RUN rm -f /usr/lib/x86_64-linux-gnu/libXau.a
RUN rm -f /usr/lib/x86_64-linux-gnu/libXdmcp.a
RUN rm -f /usr/lib/x86_64-linux-gnu/libmd.a
RUN rm -f /usr/lib/x86_64-linux-gnu/libxcb.a
RUN rm -f /usr/lib/x86_64-linux-gnu/libxcb-composite.a
RUN rm -f /usr/lib/x86_64-linux-gnu/libxcb-ewmh.a
RUN rm -f /usr/lib/x86_64-linux-gnu/libxcb-icccm.a
RUN rm -f /usr/lib/x86_64-linux-gnu/libxcb-render.a
RUN rm -f /usr/lib/x86_64-linux-gnu/libxcb-res.a
RUN rm -f /usr/lib/x86_64-linux-gnu/libxcb-shape.a
RUN rm -f /usr/lib/x86_64-linux-gnu/libxcb-xfixes.a
RUN rm -f /usr/lib/x86_64-linux-gnu/libxkbfile.a
RUN rm -f /usr/lib/x86_64-linux-gnu/libxshmfence.a

COPY "libfontenc1.sh" "libfontenc1.sh"
RUN ./libfontenc1.sh
COPY "libxfont2.sh" "libxfont2.sh"
RUN ./libxfont2.sh
COPY "xwayland.sh" "xwayland.sh"
RUN ./xwayland.sh
COPY "libliftoff.sh" "libliftoff.sh"
RUN ./libliftoff.sh
COPY "libwlroots.sh" "libwlroots.sh"
RUN ./libwlroots.sh

RUN apt-get update -qq \
  && apt-get install -qqy \
    libudev-dev shared-mime-info gettext \
  && apt-get clean all -qqy
RUN rm -f /usr/lib/x86_64-linux-gnu/libcap.a
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

COPY "novnc.sh" "novnc.sh"
RUN ./novnc.sh
COPY assets/. ${STAGING}/
COPY ".staging.sh" ".staging.sh"
RUN ./.staging.sh




FROM base
RUN apt-get update -qq \
  && apt-get install -qqy \
    locales python3-pip \
  && apt-get clean all -qqy
ENV TZ='Asia/Shanghai'
RUN ln -sfn /usr/share/zoneinfo/${TZ} /etc/localtime
RUN echo 'en_US.UTF-8 UTF-8' >>/etc/locale.gen && locale-gen
ENV LC_ALL='en_US.UTF-8' LANG='en_US.UTF-8' LANGUAGE='en_US:en'
RUN pip3 config set global.index-url "https://mirrors.bfsu.edu.cn/pypi/web/simple"
RUN pip3 config set global.break-system-packages true
RUN pip3 install --no-cache-dir -U --upgrade-strategy only-if-needed websockify==0.13.0 && pip3 cache purge


COPY --from=builder /opt/staging.tar.gz /opt
RUN tar -xvf /opt/staging.tar.gz -C / --no-same-owner \
  --transform 's@^staging/bin@usr/local/bin@' \
  --transform 's@^staging/lib@usr/local/lib@' \
  --transform 's@^staging/etc@etc@' \
  --transform 's@^staging/opt@opt@' \
  --transform 's@^staging/var@var@' \
  --transform 's@^staging/share@usr/share@'
RUN ln -sfn /usr/share /
RUN apt-get update -qq \
  && apt-get install -qqy \
    zlib1g libxkbcommon-x11-0 fonts-noto-cjk libxcvt0 libxshmfence1 \
    libxcb-composite0 libxcb-ewmh2 libxcb-icccm4 libxcb-res0 libxcb-xfixes0 libxcb-render0 \
    libx11-6 libxext6 libxi6 libxrender1 libxtst6 x11-xkb-utils \
  && apt-get clean all -qqy


ENV WLR_BACKENDS='headless'
ENV WLR_RENDERER='pixman'
ENV WLR_LIBINPUT_NO_DEVICES='1'
ENV WLR_XWAYLAND='/usr/local/bin/Xwayland'
ENV XDG_RUNTIME_DIR='/opt/xdg'
ENV SWAYSOCK="${XDG_RUNTIME_DIR}/sway-ipc.sock"

COPY .entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
