FROM archlinux:latest AS base
SHELL ["/bin/bash", "-c"]
ENV TZ='Asia/Shanghai' XZ_OPT='--threads=0' CCACHE_DIR="/ccache"
RUN echo 'en_US.UTF-8 UTF-8' >>/etc/locale.gen && locale-gen
ENV LC_ALL='en_US.UTF-8' LANG='en_US.UTF-8' LANGUAGE='en_US:en'
RUN echo 'Server = http://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' >/etc/pacman.d/mirrorlist
RUN pacman-key --init \
  && pacman -Syy --noconfirm tzdata ca-certificates \
  && yes | pacman -Scc
RUN ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime
ENV STAGING='/opt/staging'
ARG GITHUB_PROXY=""


#FROM base AS builder
#RUN pacman -Syy --noconfirm \
#  curl tree
#COPY "novnc.sh" "novnc.sh"
#RUN ./novnc.sh
#COPY assets/. ${STAGING}/
#COPY ".staging.sh" ".staging.sh"
#RUN ./.staging.sh




FROM base
#COPY --from=builder /opt/staging.tar.gz /opt
#RUN tar -xvf /opt/staging.tar.gz -C / --no-same-owner \
#  --transform 's@^staging/opt@opt@'
RUN pacman -Syy --noconfirm \
    weston python-numpy libdisplay-info neatvnc \
    git e2fsprogs patch file unzip noto-fonts-cjk \
  && yes | pacman -Scc


ENV LIBGL_ALWAYS_SOFTWARE='1'
ENV WLR_BACKENDS='headless'
ENV WLR_RENDERER='pixman'
ENV WLR_LIBINPUT_NO_DEVICES='1'
ENV XDG_RUNTIME_DIR='/opt/xdg'

COPY .entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
