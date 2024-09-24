# syntax=docker/dockerfile:1
ARG CONTAINER_REGISTRY_PREFIX
ARG WINDOWS_C_RUNTIME="ucrt"
ARG TOOLCHAIN_IMAGE_VERSION="976a02a900f1b2d91a35c2ee8ea384fb376960d0"

FROM ${CONTAINER_REGISTRY_PREFIX}valord577/ct-mingw-${WINDOWS_C_RUNTIME}:${TOOLCHAIN_IMAGE_VERSION}
RUN apt-get update -qq \
  && apt-get install -qqy \
  tree patchelf curl zip unzip xz-utils git \
  make ccache python3 python3-venv cmake file \
  && apt-get clean all -qqy
