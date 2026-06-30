#!/usr/bin/env sh
set -e

LINUX_SYSROOT="/opt/toolchain/linux310-gcc7"
mkdir -p ${LINUX_SYSROOT}; cd $(dirname ${LINUX_SYSROOT})

_DOWNLOAD_URL_="${RCLONE_URL}/rclone-current-linux-${TARGETARCH}.zip"
curl --fail-with-body -sSL -o "rclone.zip" --url "${_DOWNLOAD_URL_}"
unzip -j rclone.zip '*/rclone' -d .

cat > "rclone.conf" <<- EOF
[r2]
type = s3
provider = Cloudflare
access_key_id = ${S3_R2_ACCESS_KEY}
secret_access_key = ${S3_R2_SECRET_KEY}
region = ${S3_R2_STORAGE_REGION}
endpoint = https://${S3_R2_ACCOUNT_ID}.r2.cloudflarestorage.com
no_check_bucket = true
no_head = true
EOF

props='amd64-gnu arm64-gnu armhf-gnu amd64-musl arm64-musl armhf-musl'
for prop in ${props}; do
  ./rclone copy "r2:${S3_R2_STORAGE_BUCKET}/crosstool-ng/crosstool-linux310-gcc7-target-${prop}.tar.gz" "."
done
for prop in ${props}; do
  tar -xvf "crosstool-linux310-gcc7-target-${prop}.tar.gz" -C "${LINUX_SYSROOT}" --no-same-owner
done


# ----------------------------
rm -rf rclone*
rm -rf crosstool-linux310-gcc7-target-*.tar.gz
