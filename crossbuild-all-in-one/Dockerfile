FROM debian:12
SHELL ["/bin/bash", "-c"]
ENV TZ=UTC \
    DEBIAN_FRONTEND=noninteractive
ENV XZ_OPT='--threads=0'
ENV CCACHE_DIR="/ccache"
RUN rm -f -- /etc/apt/apt.conf.d/70debconf
RUN echo 'Acquire::http::Pipeline-Depth "0";' > /etc/apt/apt.conf.d/99nopipelining
RUN echo 'APT::Install-Recommends 0;\nAPT::Install-Suggests 0;' > /etc/apt/apt.conf.d/99norecommends
ARG PACKAGE_MANAGER_USE_MIRROR='1'
RUN [ "${PACKAGE_MANAGER_USE_MIRROR}" == "0" ] || \
  sed -i s@/deb.debian.org/@/repo.huaweicloud.com/@g /etc/apt/sources.list.d/**
RUN apt-get update -qq \
  && apt-get install -qqy tzdata ca-certificates \
  && apt-get clean all -qqy
RUN ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime
# ----------------------------
ENV LLVM_TOOL_VERSION="16"
ENV LLVM_TOOL_DIR="/usr/lib/llvm-${LLVM_TOOL_VERSION}"
ENV PATH="${PATH}:${LLVM_TOOL_DIR}/bin"
ENV CC="clang" CXX="clang++" CPP="clang-cpp"
RUN ln -sf /usr/bin/pkgconf /usr/local/bin/pkg-config
RUN apt-get update -qq \
  && apt-get install -qqy pkgconf-bin \
    clang-${LLVM_TOOL_VERSION} llvm-${LLVM_TOOL_VERSION} lld-${LLVM_TOOL_VERSION} \
  && apt-get clean all -qqy
# ----------------------------
RUN apt-get update -qq \
  && apt-get install -qqy \
    git curl zip unzip xz-utils tree file nasm make \
    python3 python3-venv patchelf \
  && apt-get clean all -qqy
# ----------------------------
ARG TARGETOS
ARG TARGETARCH
WORKDIR "/opt/toolchain"
# ----------------------------
ARG RCLONE_URL="https://downloads.rclone.org"
COPY "extract_linux_sysroot.sh" "extract_linux_sysroot.sh"
RUN --mount=type=secret,id=S3_R2_ACCOUNT_ID,env=S3_R2_ACCOUNT_ID \
    --mount=type=secret,id=S3_R2_ACCESS_KEY,env=S3_R2_ACCESS_KEY \
    --mount=type=secret,id=S3_R2_SECRET_KEY,env=S3_R2_SECRET_KEY \
    --mount=type=secret,id=S3_R2_STORAGE_REGION,env=S3_R2_STORAGE_REGION \
    --mount=type=secret,id=S3_R2_STORAGE_BUCKET,env=S3_R2_STORAGE_BUCKET \
    ./extract_linux_sysroot.sh
# ----------------------------
ARG MINGW_URL="https://github.com/mstorsjo/llvm-mingw/releases/download"
ARG MINGW_VERSION="20250114"
ARG MINGW_DEFAULT="ucrt-ubuntu-20.04"
COPY "extract_llvm-mingw.sh" "extract_llvm-mingw.sh"
RUN ./extract_llvm-mingw.sh
# ----------------------------
ARG NDK_URL="https://dl.google.com/android/repository"
COPY "extract_ndk_r27d.sh" "extract_ndk_r27d.sh"
RUN ./extract_ndk_r27d.sh
# ----------------------------
ARG CMAKE_URL="https://cmake.org/files"
ENV CMAKE_X="3"
ENV CMAKE_Y="30"
ENV CMAKE_Z="9"
ENV CMAKE_ROOT="/opt/cmake"
COPY "extract_cmake.sh" "extract_cmake.sh"
RUN ./extract_cmake.sh
ENV PATH="${CMAKE_ROOT}/bin:${PATH}"
# ----------------------------
COPY "extract_golang.sh" "extract_golang.sh"
RUN ./extract_golang.sh
# ----------------------------
COPY assets/. /
