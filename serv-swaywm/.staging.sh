#!/usr/bin/env bash
set -e

cd /opt

tar zcvf staging.tar.gz \
  staging/etc           \
  staging/opt           \
  staging/bin/Xwayland  \
  staging/bin/sway*     \
  staging/bin/tofi*     \
  staging/bin/wayvnc*   \
  staging/lib/lib*.so*  \
  staging/lib/xorg      \
