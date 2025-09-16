#!/usr/bin/env bash
set -e

LIBNAME='libdrm'
VERSION='libdrm-2.4.125'

curl --fail-with-body -sSL -o '1.tar.gz' \
  --url "https://gitlab.freedesktop.org/mesa/${LIBNAME}/-/archive/${VERSION}/${LIBNAME}-${VERSION}.tar.gz"
mkdir -p "/opt/src/${LIBNAME}"; tar -xvf "1.tar.gz" -C "/opt/src/${LIBNAME}" --strip-components=1 --no-same-owner


meson_args=$(cat <<- EOF
                          \
  -Damdgpu=disabled       \
  -Dcairo-tests=disabled  \
  -Detnaviv=disabled      \
  -Dfreedreno=disabled    \
  -Dintel=disabled        \
  -Dnouveau=disabled      \
  -Domap=disabled         \
  -Dradeon=disabled       \
  -Dtegra=disabled        \
  -Dvc4=disabled          \
  -Dvmwgfx=disabled       \
  -Dudev=true             \
  -Dtests=false           \
  -Dvalgrind=disabled     \
  -Dinstall-test-programs=false  \
  -Dman-pages=disabled    \

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
