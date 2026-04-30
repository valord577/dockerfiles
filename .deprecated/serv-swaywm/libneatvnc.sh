#!/usr/bin/env bash
set -e

LIBNAME='neatvnc'
VERSION='v0.9.5'

curl --fail-with-body -sSL -o '1.tar.gz' \
  --url "https://github.com/any1/${LIBNAME}/archive/refs/tags/${VERSION}.tar.gz"
mkdir -p "/opt/src/${LIBNAME}"; tar -xvf "1.tar.gz" -C "/opt/src/${LIBNAME}" --strip-components=1 --no-same-owner


meson_args=$(cat <<- EOF
                      \
  -Dbenchmarks=false  \
  -Dsystemtap=false   \
  -Dtests=false       \
  -Dtls=disabled      \

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
