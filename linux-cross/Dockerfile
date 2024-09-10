# syntax=docker/dockerfile:1
ARG TARGETOS
ARG TARGETARCH
ARG CONTAINER_REGISTRY_PREFIX

ARG LINUX_UAPI_VERSION="310"
ARG TOOLCHAIN_IMAGE_VERSION="11bbfede4ca41635235d9b587a7e48782627650e"

FROM ${CONTAINER_REGISTRY_PREFIX}valord577/ct-linux${LINUX_UAPI_VERSION}:${TOOLCHAIN_IMAGE_VERSION}
RUN ln -sf /usr/bin/pkgconf /usr/local/bin/pkg-config
RUN apt-get update -qq \
  && apt-get install -qqy \
  tree patchelf curl zip unzip xz-utils git file \
  make ccache python3 python3-venv cmake pkgconf-bin \
  && apt-get clean all -qqy
