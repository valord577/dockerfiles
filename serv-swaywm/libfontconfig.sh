#!/usr/bin/env bash
set -e

LIBNAME='fontconfig'
VERSION='2.17.1'

curl --fail-with-body -sSL -o '1.tar.gz' \
  --url "https://gitlab.freedesktop.org/fontconfig/${LIBNAME}/-/archive/${VERSION}/${LIBNAME}-${VERSION}.tar.gz"
mkdir -p "/opt/src/${LIBNAME}"; tar -xvf "1.tar.gz" -C "/opt/src/${LIBNAME}" --strip-components=1 --no-same-owner


meson_args=$(cat <<- EOF
                          \
  -Dcache-build=disabled  \
  -Ddoc=disabled          \
  -Dtests=disabled        \
  -Dxml-backend=expat     \

EOF
)
meson setup \
  --prefix '/'                  \
  --pkgconfig.relocatable       \
  --libdir lib                  \
  --wrap-mode nofallback        \
  -Db_pie=true -Db_ndebug=true  \
  --default-library shared      \
  --buildtype release           \
  -Dprefer_static=true          \
  ${meson_args} "/opt/tmp/${LIBNAME}" "/opt/src/${LIBNAME}"
meson compile -C "/opt/tmp/${LIBNAME}" -j 0
meson install -C "/opt/tmp/${LIBNAME}" --no-rebuild --strip --destdir=${STAGING}
