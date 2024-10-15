# syntax=docker/dockerfile:1
ARG CONTAINER_REGISTRY_PREFIX
ARG TOOLCHAIN_IMAGE_VERSION="340867670c99512abd403dd40fb800d3cfabbe25"
FROM ${CONTAINER_REGISTRY_PREFIX}valord577/cross-sysroot-linux:${TOOLCHAIN_IMAGE_VERSION}

RUN apt-get update -qq \
  && apt-get install -qqy \
  tree patchelf curl zip unzip xz-utils git nasm \
  make ccache python3 python3-venv cmake file \
  && apt-get clean all -qqy
