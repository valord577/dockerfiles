#!/usr/bin/env bash
set -e

LIBNAME='wayvnc'
VERSION='v0.9.1'

curl --fail-with-body -sSL -o '1.tar.gz' \
  --url "https://github.com/any1/${LIBNAME}/archive/refs/tags/${VERSION}.tar.gz"
mkdir -p "/opt/src/${LIBNAME}"; tar -xvf "1.tar.gz" -C "/opt/src/${LIBNAME}" --strip-components=1 --no-same-owner

patch "/opt/src/${LIBNAME}/src/pixels.c" "wayvnc.patch"
ln -sfn ${STAGING}/bin/wayland-scanner /usr/local/bin/

meson_args=$(cat <<- EOF
                       \
  -Dman-pages=disabled \
  -Dpam=disabled       \
  -Dsystemtap=false    \
  -Dtests=false        \

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
