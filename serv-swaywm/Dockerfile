FROM archlinux:latest AS base
SHELL ["/bin/bash", "-c"]
ENV TZ='Asia/Shanghai' XZ_OPT='--threads=0' CCACHE_DIR="/ccache"
RUN echo 'en_US.UTF-8 UTF-8' >>/etc/locale.gen && locale-gen
ENV LC_ALL='en_US.UTF-8' LANG='en_US.UTF-8' LANGUAGE='en_US:en'
COPY .pacman.conf /etc/pacman.conf
RUN pacman-key --init \
  && pacman -Syy --noconfirm tzdata ca-certificates
RUN ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime
ENV STAGING='/opt/staging'



FROM base AS builder
RUN pacman -Syy --noconfirm \
  curl gcc pkgconf cmake meson patch tree
WORKDIR '/opt'
ENV LD_LIBRARY_PATH="${STAGING}/lib:/usr/local/lib" \
    PKG_CONFIG_PATH="${STAGING}/lib/pkgconfig:/usr/local/lib/pkgconfig"

RUN pacman -Syy --noconfirm \
  fontconfig pixman pcre2 libffi fribidi shared-mime-info jansson libxkbcommon-x11

COPY "libglib2.sh" "libglib2.sh"
RUN ./libglib2.sh
COPY "libcairo.sh" "libcairo.sh"
RUN ./libcairo.sh
COPY "libharfbuzz.sh" "libharfbuzz.sh"
RUN ./libharfbuzz.sh
COPY "libpango.sh" "libpango.sh"
RUN ./libpango.sh
COPY "libjpeg80.sh" "libjpeg80.sh"
RUN ./libjpeg80.sh
COPY "libgdk-pixbuf.sh" "libgdk-pixbuf.sh"
RUN ./libgdk-pixbuf.sh

COPY "libdrm2.sh" "libdrm2.sh"
RUN ./libdrm2.sh

COPY "libwayland.sh" "libwayland.sh"
RUN ./libwayland.sh
COPY "libwayland-protocols.sh" "libwayland-protocols.sh"
RUN ./libwayland-protocols.sh
COPY "libaml.sh" "libaml.sh"
RUN ./libaml.sh
COPY "libneatvnc.sh" "libneatvnc.sh"
RUN ./libneatvnc.sh
COPY "wayvnc.sh"    "wayvnc.sh"
COPY "wayvnc.patch" "wayvnc.patch"
RUN ./wayvnc.sh

RUN pacman -Syy --noconfirm \
  libx11 libxkbfile libxfont2 libxcvt libxshmfence xtrans xcb-util-wm libinput libevdev json-c
ENV PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:/usr/local/share/pkgconfig"
COPY "xwayland.sh" "xwayland.sh"
RUN ./xwayland.sh
COPY "libliftoff.sh" "libliftoff.sh"
RUN ./libliftoff.sh
COPY "libwlroots.sh" "libwlroots.sh"
RUN ./libwlroots.sh
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
COPY --from=builder /opt/staging.tar.gz /opt
RUN tar -xvf /opt/staging.tar.gz -C / --no-same-owner \
  --transform 's@^staging/bin@usr/local/bin@' \
  --transform 's@^staging/lib@usr/local/lib@' \
  --transform 's@^staging/etc@etc@' \
  --transform 's@^staging/opt@opt@' \
  --transform 's@^staging/var@var@' \
  --transform 's@^staging/share@usr/share@'
RUN ln -sfn /usr/share /
RUN pacman -Syy --noconfirm \
  xcb-util-wm fontconfig pixman libffi fribidi jansson json-c \
  libevdev pcre2 libxkbcommon-x11 noto-fonts-cjk python-numpy \
  libx11 libxshmfence libxkbfile libxfont2 libxcvt libxrender \
  xkeyboard-config xorg-xkbcomp libxi libevdev libxtst


ENV LD_LIBRARY_PATH="/usr/local/lib"
ENV WLR_BACKENDS='headless'
ENV WLR_RENDERER='pixman'
ENV WLR_LIBINPUT_NO_DEVICES='1'
ENV WLR_XWAYLAND='/usr/local/bin/Xwayland'
ENV XDG_RUNTIME_DIR='/opt/xdg'
ENV SWAYSOCK="${XDG_RUNTIME_DIR}/sway-ipc.sock"

COPY .entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
