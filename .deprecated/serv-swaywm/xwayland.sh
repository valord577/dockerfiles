#!/usr/bin/env bash
set -e

LIBNAME='xserver'
VERSION='xwayland-24.1.9'

curl --fail-with-body -sSL -o '1.tar.gz' \
  --url "https://gitlab.freedesktop.org/xorg/${LIBNAME}/-/archive/${VERSION}/${LIBNAME}-${VERSION}.tar.gz"
mkdir -p "/opt/src/${LIBNAME}"; tar -xvf "1.tar.gz" -C "/opt/src/${LIBNAME}" --strip-components=1 --no-same-owner


meson_args=$(cat <<- EOF
                          \
  -Dwerror=false          \
  -Ddevel-docs=false      \
  -Ddocs=false            \
  -Ddocs-pdf=false        \
  -Ddpms=false            \
  -Ddri3=false            \
  -Ddtrace=false          \
  -Dglamor=false          \
  -Dglx=false             \
  -Dinput_thread=false    \
  -Dipv6=false            \
  -Dlibunwind=false       \
  -Dlisten_local=false    \
  -Dlisten_tcp=false      \
  -Dscreensaver=false     \
  -Dsecure-rpc=false      \
  -Dsystemd_notify=false  \
  -Dxace=true             \
  -Dxcsecurity=false      \
  -Dxdm-auth-1=false      \
  -Dxdmcp=false           \
  -Dxinerama=false        \
  -Dxselinux=false        \

EOF
)
meson setup \
  --prefix '/'                  \
  --pkgconfig.relocatable       \
  --libdir lib                  \
  --wrap-mode nofallback        \
  -Db_pie=true -Db_ndebug=true  \
  --default-library static      \
  --buildtype release           \
  ${meson_args} "/opt/tmp/${LIBNAME}" "/opt/src/${LIBNAME}"
meson compile -C "/opt/tmp/${LIBNAME}" -j 0
meson install -C "/opt/tmp/${LIBNAME}" --no-rebuild --strip --destdir=${STAGING}
