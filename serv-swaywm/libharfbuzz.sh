#!/usr/bin/env bash
set -e

LIBNAME='harfbuzz'
VERSION='10.2.0'
LIBTEAM='freedesktop-team'

curl --fail-with-body -sSL -o '1.tar.gz' \
  --url "https://salsa.debian.org/${LIBTEAM}/${LIBNAME}/-/archive/upstream/${VERSION}/${LIBNAME}-upstream-${VERSION}.tar.gz"
mkdir -p "/opt/src/${LIBNAME}"; tar -xvf "1.tar.gz" -C "/opt/src/${LIBNAME}" --strip-components=1 --no-same-owner


meson_args=$(cat <<- EOF
                            \
  -Dbenchmark=disabled      \
  -Dcairo=enabled           \
  -Dchafa=disabled          \
  -Ddoc_tests=false         \
  -Ddocs=disabled           \
  -Dexperimental_api=false  \
  -Dfreetype=disabled       \
  -Dglib=disabled           \
  -Dgobject=disabled        \
  -Dgraphite2=disabled      \
  -Dicu=disabled            \
  -Dicu_builtin=true        \
  -Dintrospection=disabled  \
  -Dragel_subproject=false  \
  -Dtests=disabled          \
  -Dutilities=disabled      \
  -Dwasm=disabled           \
  -Dwith_libstdcxx=true     \

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
