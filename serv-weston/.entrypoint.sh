#!/usr/bin/env bash
set -e

passwd -d root

mkdir -p ${XDG_RUNTIME_DIR}; mkdir -p /tmp/.X11-unix;

cert='/tmp/tls.cert'; key='/tmp/tls.key'
openssl req -x509 -nodes -days 3660 -newkey rsa:4096 \
  -keyout ${key} -out ${cert} \
  -subj "/C=XX/ST=Self/L=Self/O=Self/OU=Self/CN=Self"
/opt/websockify/run --cert=${cert} --key=${key} \
  -D --web=/opt/novnc/ 0.0.0.0:55900 127.0.0.1:5900


WESTON_COMMAND=$(cat <<- EOF
weston --backend=vnc --port=5900     \
  --disable-transport-layer-security \
  --width=${DISPLAY_W:-'1920'} --height=${DISPLAY_H:-'1088'}
EOF
)
#if [ $# -gt 0 ]; then
#  WESTON_COMMAND="${WESTON_COMMAND} -- $@"
#fi
printf "\e[1m\e[36m%s\e[0m\n" "${WESTON_COMMAND}"; eval ${WESTON_COMMAND}

