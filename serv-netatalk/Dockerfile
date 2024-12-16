FROM alpine:3.20.3 AS base
ENV TZ=UTC
ENV XZ_OPT='--threads=0'
ENV CCACHE_DIR="/ccache"
RUN sed -i s@/dl-cdn.alpinelinux.org/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apk/repositories
RUN apk update \
  && apk add --no-cache --no-check-certificate --no-interactive \
    tzdata ca-certificates \
  && apk cache -f --no-interactive purge \
  && apk cache -f --no-interactive clean
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime


FROM base AS builder
RUN apk update \
  && apk add --no-cache --no-check-certificate --no-interactive \
    bash file git gcc musl-dev pkgconf db-dev libevent-dev libgcrypt-dev gnu-libiconv-dev \
  && apk cache -f --no-interactive purge \
  && apk cache -f --no-interactive clean

ENV NETATALK_VERSION="netatalk-4-0-8"
WORKDIR "/netatalk"
RUN <<EOT
#!/usr/bin/env bash
set -e

# PYPI_MIRROR="-i https://mirrors.bfsu.edu.cn/pypi/web/simple"
# git config --global http.proxy http://192.168.1.241:8118
# git config --global https.proxy $(git config --global --get http.proxy)
git clone --no-checkout --single-branch --depth=1 \
  https://github.com/Netatalk/netatalk.git .
git fetch --tags --prune --prune-tags --no-recurse-submodules --depth=1
git checkout ${NETATALK_VERSION}

python3 -m venv .env; source .env/bin/activate
pip3 install ${PYPI_MIRROR} --upgrade pip
pip3 install ${PYPI_MIRROR} --upgrade meson ninja

PKG_INST_DIR="/staging"; PKG_BULD_DIR="/build"
meson setup \
  --auto-features disabled  \
  --python.install-env venv \
  --buildtype release -Dwith-debug=false \
  --wrap-mode nofallback -Db_pie=true \
  -Dwith-acls=false \
  -Dwith-afpstats=false \
  -Dwith-cnid-last-backend=false  \
  -Dwith-cnid-mysql-backend=false \
  -Dwith-cracklib=false \
  -Dwith-cups=false \
  -Dwith-dtrace=false \
  -Dwith-gssapi=false \
  -Dwith-init-hooks=false \
  -Dwith-init-style=none  \
  -Dwith-install-hooks=false \
  -Dwith-kerberos=false \
  -Dwith-krbV-uam=false \
  -Dwith-ldap=false \
  -Dwith-manual=none \
  -Dwith-pam=false \
  -Dwith-quota=false \
  -Dwith-readmes=false \
  -Dwith-spotlight=false \
  -Dwith-tcp-wrappers=false \
  -Dwith-tests=false \
  -Dwith-testsuite=false \
  -Dwith-webmin=false \
  -Dwith-zeroconf=false \
  ${PKG_BULD_DIR} .
meson compile -C ${PKG_BULD_DIR} -j $(nproc)
meson install -C ${PKG_BULD_DIR} --destdir=${PKG_INST_DIR} --no-rebuild --strip

rm -rf ${PKG_INST_DIR}/usr/local/include
EOT


FROM base
RUN apk update \
  && apk add --no-cache --no-check-certificate --no-interactive \
    bash file tree db libevent libgcrypt gnu-libiconv-libs \
  && apk cache -f --no-interactive purge \
  && apk cache -f --no-interactive clean
COPY --from=builder /staging /
COPY afp.conf /usr/local/etc/afp.conf
COPY entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
