#!/usr/bin/env sh
set -e

_DOWNLOAD_URL_="${RCLONE_URL}/rclone-current-linux-${TARGETARCH}.zip"
curl --fail-with-body -sSL -o "/rclone.zip" --url "${_DOWNLOAD_URL_}"
unzip -j /rclone.zip '*/rclone' -d /

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

archived="crosstool-linux${SYSROOT_LINUX_HEADER_UAPI}-gcc${SYSROOT_LIBSTDCXX_GCC_VER}-target-${SYSROOT_TARGET_ARCH}-${SYSROOT_TARGET_LIBC}.tar.gz"
tar -zcvf /${archived} .
/rclone copy "/${archived}" "r2:${S3_R2_STORAGE_BUCKET}/crosstool-ng/"


# ----------------------------
rm -rf /rclone*
rm -rf /${archived}
