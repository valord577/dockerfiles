#!/usr/bin/env bash
set -e

cd /opt

tar zcvf staging.tar.gz \
  staging/bin/Xwayland  \
  staging/bin/fc-*      \
  staging/bin/sway*     \
  staging/bin/tofi*     \
  staging/bin/wayvnc*   \
  staging/lib/libXfont2.so*       \
  staging/lib/libfontconfig.so*   \
  staging/lib/libfreetype.so*     \
  staging/lib/libwayland-*.so*    \
  staging/lib/xorg                \
  staging/etc  \
  staging/opt  \
  staging/var  \
  staging/share/fontconfig      \
  staging/share/xml/fontconfig  \
