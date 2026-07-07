#!/usr/bin/env sh
set -e

NDK_VERSION="r27d"
NDK_EXTRACT_SUFFIX=""

NDK_ROOT="/opt/toolchain/ndk-${NDK_VERSION}-slim"

curl --fail-with-body -sSL -X GET -o "/opt/ndk.zip" \
   --url "${NDK_URL}/android-ndk-${NDK_VERSION}-linux${NDK_EXTRACT_SUFFIX}.zip"


extractor="unzip -q /opt/ndk.zip -d '/opt' 'android-ndk-${NDK_VERSION}'"

eval "${extractor}/meta/"'*'
eval "${extractor}/build/cmake/"'*'
eval "${extractor}/source.properties"

eval "${extractor}/toolchains/llvm/prebuilt/linux-x86_64/AndroidVersion.txt"

eval "${extractor}/toolchains/llvm/prebuilt/linux-x86_64/bin/"'yasm'
eval "${extractor}/toolchains/llvm/prebuilt/linux-x86_64/bin/"'ld'
eval "${extractor}/toolchains/llvm/prebuilt/linux-x86_64/bin/"'*-clang'
eval "${extractor}/toolchains/llvm/prebuilt/linux-x86_64/bin/"'*-clang++'
sed -i 's@usr/bin/env bash@usr/bin/env sh@g' \
   "/opt/android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/bin/"*-clang*

#eval "${extractor}/toolchains/llvm/prebuilt/linux-x86_64/lib/"'clang/*/include/*'
eval "${extractor}/toolchains/llvm/prebuilt/linux-x86_64/lib/"'clang/*/lib/linux/libclang_rt.builtins-*-android.a'
eval "${extractor}/toolchains/llvm/prebuilt/linux-x86_64/lib/"'clang/*/lib/linux/*/libatomic.a'
eval "${extractor}/toolchains/llvm/prebuilt/linux-x86_64/lib/"'clang/*/lib/linux/*/libomp.a'
eval "${extractor}/toolchains/llvm/prebuilt/linux-x86_64/lib/"'clang/*/lib/linux/*/libunwind.a'
#eval "${extractor}/toolchains/llvm/prebuilt/linux-x86_64/lib/"'clang/*/lib/linux/*/lldb-server'

eval "${extractor}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/"'usr/include/*'
eval "${extractor}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/"'usr/lib/*'


# Do NOT use the library included with the NDK: zlib
rm -f "/opt/android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include/"{zconf.h,zlib.h}
rm -f "/opt/android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/"*/libz.a
rm -f "/opt/android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/"*/*/libz.so
# Do NOT use the library included with the NDK: c++_shared
rm -f "/opt/android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/"*/libc++_shared.so
rm -f "/opt/android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/"*/*/libc++.so
# Do NOT use the library included with the NDK: gnustl_*
rm -f "/opt/android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/"*/libstdc++.a
rm -f "/opt/android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/"*/*/libstdc++.so


# ----------------------------
rm -f -- "/opt/ndk.zip"; mv "/opt/android-ndk-${NDK_VERSION}" "${NDK_ROOT}"
