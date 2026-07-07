#!/usr/bin/env bash
set -e

_CMAKE_URL_="${CMAKE_URL}/v${CMAKE_X}.${CMAKE_Y}/cmake-${CMAKE_X}.${CMAKE_Y}.${CMAKE_Z}-linux-$(uname -m).tar.gz"
curl --fail-with-body -sSL -o "1.tar.gz" --url "${_CMAKE_URL_}"
trap 'rm -rf "1.tar.gz"' EXIT INT TERM
mkdir -p "${CMAKE_ROOT}"; tar xf "1.tar.gz" -C "${CMAKE_ROOT}" --strip-components=1 --no-same-owner

# remove unused files...
rm -f "${CMAKE_ROOT}/bin/ccmake"
rm -f "${CMAKE_ROOT}/bin/cmake-gui"

rm -rf "${CMAKE_ROOT}/man"
rm -rf "${CMAKE_ROOT}/doc"

rm -rf "${CMAKE_ROOT}/share/aclocal"
rm -rf "${CMAKE_ROOT}/share/applications"
rm -rf "${CMAKE_ROOT}/share/bash-completion"
rm -rf "${CMAKE_ROOT}/share/emacs"
rm -rf "${CMAKE_ROOT}/share/icons"
rm -rf "${CMAKE_ROOT}/share/mime"
rm -rf "${CMAKE_ROOT}/share/vim"
