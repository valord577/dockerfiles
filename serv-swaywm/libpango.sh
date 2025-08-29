#!/usr/bin/env bash
set -e

LIBNAME='pango'
VERSION='1.56.4'
LIBTEAM='gnome-team'

curl --fail-with-body -sSL -o '1.tar.gz' \
  --url "https://salsa.debian.org/${LIBTEAM}/${LIBNAME}/-/archive/upstream/${VERSION}/${LIBNAME}-upstream-${VERSION}.tar.gz"
mkdir -p "/opt/src/${LIBNAME}"; tar -xvf "1.tar.gz" -C "/opt/src/${LIBNAME}" --strip-components=1 --no-same-owner


meson_args=$(cat <<- EOF
                           \
  -Dbuild-examples=false   \
  -Dbuild-testsuite=false  \
  -Dcairo=enabled          \
  -Ddocumentation=false    \
  -Dfreetype=disabled      \
  -Dgtk_doc=false          \
  -Dintrospection=disabled \
  -Dlibthai=disabled       \
  -Dman-pages=false        \
  -Dsysprof=disabled       \
  -Dxft=disabled           \

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
