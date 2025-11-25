#!/usr/bin/env bash
set -e

if [ $# -gt 0 ]; then
  pacman -Syy --noconfirm $@
fi




mkdir -p ${XDG_RUNTIME_DIR}


sway -V &

try='0'; try_max='3'; swaymsg_ret='0'
while true; do
  if [ ${try} -ge ${try_max} ]; then { break; } else { sleep 1; } fi

  # https://man.archlinux.org/man/sway-output.5.en
  set +e
    {
      swaymsg output HEADLESS-1 mode ${DISPLAY_SIZE:-'1920x1080@60Hz'}; swaymsg_ret=${?}
    }
  set -e
  if [ ${swaymsg_ret} -eq 0 ];  then { break; } else { try=$(echo "$try + 1" | bc); } fi
done
if [ ${try} -ge ${try_max} ]; then
  printf "\e[1m\e[31m%s\e[0m\n" "unable to start swaywm"
  exit 1
fi

swaymsg -t get_outputs

WAYLAND_DISPLAY='wayland-1' wayvnc -L info 0.0.0.0 &
/opt/websockify/run \
  -D --web=/opt/novnc/ 0.0.0.0:55900 127.0.0.1:5900

sleep inf
