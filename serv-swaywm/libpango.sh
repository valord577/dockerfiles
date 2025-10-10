#!/usr/bin/env bash
set -e

LIBNAME='pango'
VERSION='1.57.0'

curl --fail-with-body -sSL -o '1.tar.gz' \
  --url "https://gitlab.gnome.org/GNOME/${LIBNAME}/-/archive/${VERSION}/${LIBNAME}-${VERSION}.tar.gz"
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
