FROM alpine:edge
ENV TZ='UTC' XZ_OPT='--threads=0'
RUN sed -i s@/dl-cdn.alpinelinux.org/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apk/repositories
RUN apk update \
  && apk add --no-cache --no-check-certificate --no-interactive \
    tzdata ca-certificates \
  && apk cache -f --no-interactive purge \
  && apk cache -f --no-interactive clean
RUN ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime
# ----------------------------
ENV LLVM_TOOL_VERSION="18"
ENV LLVM_TOOL_DIR="/usr/lib/llvm${LLVM_TOOL_VERSION}"
ENV PATH="${LLVM_TOOL_DIR}/bin:${PATH}"
ENV CC="clang" CXX="clang++" CPP="clang-cpp"
RUN apk update \
  && apk add --no-cache --no-check-certificate --no-interactive \
    clang${LLVM_TOOL_VERSION} llvm${LLVM_TOOL_VERSION} lld${LLVM_TOOL_VERSION} \
  && apk cache -f --no-interactive purge \
  && apk cache -f --no-interactive clean
# ----------------------------
RUN apk update \
  && apk add --no-cache --no-check-certificate --no-interactive \
    gcompat zip xz git curl tree file pkgconf ccache nasm cmake python3 make \
  && apk cache -f --no-interactive purge \
  && apk cache -f --no-interactive clean
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
COPY "extract_golang.sh" "extract_golang.sh"
RUN ./extract_golang.sh
# ----------------------------
ARG MINGW_URL="https://github.com/mstorsjo/llvm-mingw/releases/download"
ARG MINGW_VERSION="20250114"
ARG MINGW_DEFAULT="ucrt-ubuntu-20.04"
COPY "extract_llvm-mingw.sh" "extract_llvm-mingw.sh"
RUN ./extract_llvm-mingw.sh
# ----------------------------
COPY "extract_ndk_r27d.sh" "extract_ndk_r27d.sh"
RUN ./extract_ndk_r27d.sh
# ----------------------------
COPY assets/. /
