#!/usr/bin/env bash
set -e

curl --fail-with-body -sSL -X GET -o "/opt/ndk.zip" \
   --url "${NDK_URL}/android-ndk-${NDK_VERSION}-linux${NDK_EXTRACT_SUFFIX}.zip"

unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/meta/"'*'
unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/build/cmake/"'*'
unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/source.properties"

unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/AndroidVersion.txt"

unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/bin/"'*-clang'
unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/bin/"'*-clang++'
unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/bin/"'ld64.lld'
unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/bin/"'ld.lld'
unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/bin/"'ld'
unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/bin/"'lld'
unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/bin/"'lld-link'
unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/bin/"'wasm-ld'
unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/bin/"'yasm'
unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/bin/"'clang'
unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/bin/"'clang++'
unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/bin/"'clang-[0-9][0-9]*'
unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/bin/"'llvm-*'

unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/include/"'*'

unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/lib/"'clang/*/include/*'
unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/lib/"'clang/*/lib/linux/libclang_rt.builtins-*-android.a'
unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/lib/"'clang/*/lib/linux/*/*'
unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/lib/"'x86_64-unknown-linux-gnu/libc++.so*'
unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/lib/"'libc++.so*'
unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/lib/"'libxml2.so*'

unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/"'usr/include/*'
unzip -q /opt/ndk.zip -d '/opt' "android-ndk-${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/"'usr/lib/*'


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


rm -f -- "/opt/ndk.zip"; mv "/opt/android-ndk-${NDK_VERSION}" "${NDK_ROOT}"
