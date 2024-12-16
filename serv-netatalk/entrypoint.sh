#!/usr/bin/env bash
set -e

if [ -z "${AFP_PASS}" ]; then
  printf "\e[1m\e[31m%s\e[0m\n" "Invalid AFP_PASS: '${AFP_PASS}'."
  exit 1
fi

adduser -D -H afpu
addgroup afpg; addgroup afpu afpg
echo "afpu:${AFP_PASS}" | chpasswd

# fix permissions
chmod 2775 /mnt; chown -R "afpu:afpg" /mnt

netatalk -d
