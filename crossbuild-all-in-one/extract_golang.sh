#!/usr/bin/env sh
set -e

GOLANG_SDK="1.26.4"
GOLANG_SDK_ROOT="/opt/golang"

_DOWNLOAD_URL_="https://dl.google.com/go/go${GOLANG_SDK}.linux-${TARGETARCH}.tar.gz"
curl --fail-with-body -sSL -o "gosdk.tar.gz" --url "${_DOWNLOAD_URL_}"
mkdir -p "${GOLANG_SDK_ROOT}" && tar xf "gosdk.tar.gz" -C "${GOLANG_SDK_ROOT}" --strip-components=1 --no-same-owner

# https://telemetry.go.dev/
${GOLANG_SDK_ROOT}/bin/go telemetry off
# remove unused files...
rm -rf -- ${GOLANG_SDK_ROOT}/test


# ----------------------------
rm -rf gosdk.tar.gz
