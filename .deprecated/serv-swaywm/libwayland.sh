#!/usr/bin/env bash
set -e

LIBNAME='wayland'
VERSION='1.24.0'

curl --fail-with-body -sSL -o '1.tar.gz' \
  --url "https://gitlab.freedesktop.org/wayland/${LIBNAME}/-/archive/${VERSION}/${LIBNAME}-${VERSION}.tar.gz"
mkdir -p "/opt/src/${LIBNAME}"; tar -xvf "1.tar.gz" -C "/opt/src/${LIBNAME}" --strip-components=1 --no-same-owner


meson_args=$(cat <<- EOF
                         \
  -Ddocumentation=false  \
  -Ddtd_validation=true  \
  -Dtests=false          \

EOF
)
meson setup \
  --prefix '/'                     \
  --pkgconfig.relocatable          \
  --libdir lib                     \
  --wrap-mode nofallback           \
  -Db_pie=true -Db_ndebug=true     \
  --default-library shared         \
  --default-both-libraries shared  \
  --buildtype release              \
  ${meson_args} "/opt/tmp/${LIBNAME}" "/opt/src/${LIBNAME}"
meson compile -C "/opt/tmp/${LIBNAME}" -j 0
meson install -C "/opt/tmp/${LIBNAME}" --no-rebuild --strip --destdir=${STAGING}
