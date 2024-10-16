# syntax=docker/dockerfile:1
ARG CONTAINER_REGISTRY_PREFIX
ARG TOOLCHAIN_IMAGE_VERSION="3e1f43e63fc1cde7fa92c69e7833015de4792624"
FROM ${CONTAINER_REGISTRY_PREFIX}valord577/cross-sysroot-linux:${TOOLCHAIN_IMAGE_VERSION}

RUN apt-get update -qq \
  && apt-get install -qqy \
  tree patchelf curl zip unzip xz-utils git nasm \
  make python3 python3-venv cmake file autoconf \
  && apt-get clean all -qqy
