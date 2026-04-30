#!/usr/bin/env bash
set -e

cd /opt; tree -L 3

tar zcvf staging.tar.gz \
  staging/opt           \
