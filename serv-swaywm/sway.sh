#!/usr/bin/env bash
set -e

LIBNAME='sway'
VERSION='1.11'

curl --fail-with-body -sSL -o '1.tar.gz' \
  --url "https://github.com/swaywm/${LIBNAME}/archive/refs/tags/${VERSION}.tar.gz"
mkdir -p "/opt/src/${LIBNAME}"; tar -xvf "1.tar.gz" -C "/opt/src/${LIBNAME}" --strip-components=1 --no-same-owner


meson_args=$(cat <<- EOF
                            \
  -Dwerror=false            \
  -Dbash-completions=false  \
  -Ddefault-wallpaper=false \
  -Dfish-completions=false  \
  -Dman-pages=disabled      \
  -Dzsh-completions=false   \

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
