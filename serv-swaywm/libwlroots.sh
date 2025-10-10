#!/usr/bin/env bash
set -e

LIBNAME='wlroots'
VERSION='0.19.1'

curl --fail-with-body -sSL -o '1.tar.gz' \
  --url "https://gitlab.freedesktop.org/wlroots/${LIBNAME}/-/archive/${VERSION}/${LIBNAME}-${VERSION}.tar.gz"
mkdir -p "/opt/src/${LIBNAME}"; tar -xvf "1.tar.gz" -C "/opt/src/${LIBNAME}" --strip-components=1 --no-same-owner


meson_args=$(cat <<- EOF
                       \
  -Dwerror=false       \
  -Dallocators=udmabuf \
  -Dbackends=          \
  -Dexamples=false     \
  -Drenderers=         \
  -Dsession=disabled   \
  -Dxwayland=disabled  \

EOF
)
meson setup \
  --prefix '/usr/local'         \
  --pkgconfig.relocatable       \
  --libdir lib                  \
  --wrap-mode nofallback        \
  -Db_pie=true -Db_ndebug=true  \
  --default-library static      \
  --buildtype release           \
  ${meson_args} "/opt/tmp/${LIBNAME}" "/opt/src/${LIBNAME}"
meson compile -C "/opt/tmp/${LIBNAME}" -j 0
meson install -C "/opt/tmp/${LIBNAME}" --no-rebuild --strip
