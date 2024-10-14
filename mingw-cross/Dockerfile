# syntax=docker/dockerfile:1
ARG CONTAINER_REGISTRY_PREFIX
ARG TOOLCHAIN_IMAGE_VERSION="7566c58c81be08eccef6e69a5f6e48fbf2c87b88"
FROM ${CONTAINER_REGISTRY_PREFIX}valord577/cross-sysroot-mingw:${TOOLCHAIN_IMAGE_VERSION}

RUN apt-get update -qq \
  && apt-get install -qqy \
  tree patchelf curl zip unzip xz-utils git nasm \
  make ccache python3 python3-venv cmake file \
  && apt-get clean all -qqy
