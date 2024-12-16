#!/usr/bin/env bash
set -e

if [ -z "${AFP_PASS}" ]; then
  printf "\e[1m\e[31m%s\e[0m\n" "Invalid AFP_PASS: '${AFP_PASS}'."
  exit 1
fi

AFP_USR="afpu"
AFP_GRP="afpg"

if ! grep -e "^${AFP_USR}" /etc/passwd 2>&1 >/dev/null; then
  adduser -D -H ${AFP_USR}
fi
if ! grep -e "^${AFP_GRP}" /etc/group 2>&1 >/dev/null; then
  addgroup ${AFP_GRP}; addgroup ${AFP_USR} ${AFP_GRP}
fi
echo "${AFP_USR}:${AFP_PASS}" | chpasswd

# fix permissions
chmod 2775 /mnt; chown -R "${AFP_USR}:${AFP_GRP}" /mnt

netatalk -d
