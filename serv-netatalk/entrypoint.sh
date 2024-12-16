#!/usr/bin/env bash
set -e

if [ -z "${AFP_USER}" ]; then
  AFP_USER="afpu"
fi
if [ -z "${AFP_PASS}" ]; then
  printf "\e[1m\e[31m%s\e[0m\n" "Required AFP_PASS: '${AFP_PASS}'."
  exit 1
fi


AFP_USR="${AFP_USER}"
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
# remove lock files
rm -f /var/lock/netatalk
rm -f /var/lock/atalkd
rm -f /var/lock/papd

netatalk -d
