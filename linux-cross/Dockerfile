# syntax=docker/dockerfile:1
ARG CONTAINER_REGISTRY_PREFIX
ARG LINUX_UAPI_VERSION="310"
ARG TOOLCHAIN_IMAGE_VERSION="48236811d75b294beb3275d05b115f5e3cf2d11f"

FROM ${CONTAINER_REGISTRY_PREFIX}valord577/ct-linux${LINUX_UAPI_VERSION}:${TOOLCHAIN_IMAGE_VERSION}
RUN apt-get update -qq \
  && apt-get install -qqy \
  tree patchelf curl zip unzip xz-utils git nasm \
  make ccache python3 python3-venv cmake file \
  && apt-get clean all -qqy
