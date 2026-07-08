#!/usr/bin/env sh
set -e

GOLANG_SDK="1.26.5"
GOLANG_SDK_ROOT="/opt/golang"
mkdir -p "${GOLANG_SDK_ROOT}"

_DOWNLOAD_URL_="https://dl.google.com/go/go${GOLANG_SDK}.linux-${TARGETARCH}.tar.gz"
curl --fail-with-body -sSL -o "gosdk.tar.gz" --url "${_DOWNLOAD_URL_}"


tar -xf "gosdk.tar.gz" -C "${GOLANG_SDK_ROOT}" --strip-components=1 --no-same-owner \
  --wildcards \
    "go"      \
  --exclude="go/doc"  \
  --exclude="go/test" \


# https://telemetry.go.dev/
${GOLANG_SDK_ROOT}/bin/go telemetry off


# ----------------------------
rm -rf gosdk.tar.gz
