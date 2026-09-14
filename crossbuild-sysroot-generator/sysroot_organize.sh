#!/usr/bin/env bash
set -ex

# ENV:
#  - CT_PREFIX

cd ${CT_PREFIX}/*; CROSS_TRIPLE="$(basename ${PWD})"; cd ..;
cd ${CROSS_TRIPLE}/lib/gcc/${CROSS_TRIPLE}/*; CXX_VERSION="$(basename ${PWD})"; cd -;
#cd ${CT_PREFIX}; CROSS_TRIPLE="x86_64-w64-mingw32"; CXX_VERSION="7.5.0"

mv ${CROSS_TRIPLE} tmp; mkdir ${CROSS_TRIPLE}
SYSROOT="${CROSS_TRIPLE}"
mkdir -p ${CROSS_TRIPLE}/lib
mkdir -p ${CROSS_TRIPLE}/usr
if [[ "${CROSS_TRIPLE}" =~ ^x86_64.*$ ]] \
  || [[ "${CROSS_TRIPLE}" =~ ^aarch64.*$ ]]; then
  { pushd "${SYSROOT}/";     ln -sfn lib lib64; popd; }
  { pushd "${SYSROOT}/usr/"; ln -sfn lib lib64; popd; }
fi

if [[ "${SYSROOT}" =~ ^.*-mingw.*$ ]]; then
  {
    if [[ "${SYSROOT}" =~ ^$(uname -m)-.*$ ]]; then
      executables=(
        "dlltool"
        "gendef"
        "genidl"
        "genpeimg"
        "widl"
        "windmc"
        "windres"
      )

      mkdir -p ${SYSROOT}/bin;
      for x in "${executables[@]}"; do
        mv "tmp/bin/${CROSS_TRIPLE}-${x}" "${SYSROOT}/bin/${x}"
      done
    fi
  }
  {
    libraries=(
      "libatomic.a"
      "libstdc++.a"
      "libstdc++exp.a"
      "libstdc++fs.a"
      "libsupc++.a"
    )

    for x in "${libraries[@]}"; do
      mv "tmp/${CROSS_TRIPLE}/sysroot/lib/${x}" "${SYSROOT}/lib"
    done
  }
  {
    mv tmp/${CROSS_TRIPLE}/sysroot/mingw/{include,lib} ${SYSROOT}/usr/
  }
  {
    libraries=(
      "libgcc.a"
      "libgcc_eh.a"
    )

    mkdir -p ${SYSROOT}/usr/lib/gcc/${CROSS_TRIPLE}/${CXX_VERSION}; \
      mv  tmp/lib/gcc/${CROSS_TRIPLE}/${CXX_VERSION}/*.o   "${SYSROOT}/usr/lib/gcc/${CROSS_TRIPLE}/${CXX_VERSION}"
    for x in "${libraries[@]}"; do
      mv "tmp/lib/gcc/${CROSS_TRIPLE}/${CXX_VERSION}/${x}" "${SYSROOT}/usr/lib/gcc/${CROSS_TRIPLE}/${CXX_VERSION}"
    done
  }
elif [[ "${SYSROOT}" =~ ^.*-linux-.*$ ]]; then
  {
    if [[ "${SYSROOT}" =~ ^.*-gnu.*$ ]]; then
      libraries=(
        "libBrokenLocale-2.17.so"
        "libBrokenLocale.so.1"
        "libanl-2.17.so"
        "libanl.so.1"
        "libatomic.a"
        "libc-2.17.so"
        "libc.so.6"
        "libdl-2.17.so"
        "libdl.so.2"
        "libgcc_s.so"
        "libgcc_s.so.1"
        "libm-2.17.so"
        "libm.so.6"
        "libnsl-2.17.so"
        "libnsl.so.1"
        "libpthread-2.17.so"
        "libpthread.so.0"
        "libresolv-2.17.so"
        "libresolv.so.2"
        "librt-2.17.so"
        "librt.so.1"
        "libstdc++.a"
        "libstdc++fs.a"
        "libsupc++.a"
        "libutil-2.17.so"
        "libutil.so.1"
      )
    elif [[ "${SYSROOT}" =~ ^.*-musl.*$ ]]; then
      libraries=(
        "libatomic.a"
        "libgcc_s.so"
        "libgcc_s.so.1"
        "libstdc++.a"
        "libstdc++fs.a"
        "libsupc++.a"
      )
    elif [[ "${SYSROOT}" =~ ^.*-uclibc.*$ ]]; then
      libraries=(
        "libatomic.a"
        "libc.so.0"
        "libc.so.1"
        "libgcc_s.so"
        "libgcc_s.so.1"
        "libstdc++.a"
        "libstdc++fs.a"
        "libsupc++.a"
        "libuClibc-1.0.54.so"
      )
    fi

    mv tmp/${CROSS_TRIPLE}/sysroot/lib/ld-*.so* "${SYSROOT}/lib"
    for x in "${libraries[@]}"; do
      mv "tmp/${CROSS_TRIPLE}/sysroot/lib/${x}" "${SYSROOT}/lib"
    done
  }
  {
    mv tmp/${CROSS_TRIPLE}/sysroot/usr/include ${SYSROOT}/usr/
  }
  {
    if [[ "${SYSROOT}" =~ ^.*-gnu.*$ ]]; then
      libraries=(
        "libBrokenLocale.so"
        "libanl.so"
        "libc.so"
        "libc_nonshared.a"
        "libdl.so"
        "libm.so"
        "libnsl.so"
        "libpthread.so"
        "libpthread_nonshared.a"
        "libresolv.so"
        "librt.so"
        "libutil.so"
      )
    elif [[ "${SYSROOT}" =~ ^.*-musl.*$ ]]; then
      libraries=(
        "libc.so"
        "libcrypt.a"
        "libdl.a"
        "libm.a"
        "libpthread.a"
        "libresolv.a"
        "librt.a"
        "libutil.a"
        "libxnet.a"
      )
    elif [[ "${SYSROOT}" =~ ^.*-uclibc.*$ ]]; then
      libraries=(
        "libc.so"
        "libcrypt.a"
        "libdl.a"
        "libm.a"
        "libnsl.a"
        "libpthread.a"
        "libpthread_nonshared.a"
        "libresolv.a"
        "librt.a"
        "libutil.a"
        "uclibc_nonshared.a"
      )
    fi

    mkdir -p ${SYSROOT}/usr/lib; \
      mv  tmp/${CROSS_TRIPLE}/sysroot/usr/lib/*.o   "${SYSROOT}/usr/lib"
    for x in "${libraries[@]}"; do
      mv "tmp/${CROSS_TRIPLE}/sysroot/usr/lib/${x}" "${SYSROOT}/usr/lib"
    done
  }
  {
    libraries=(
      "libgcc.a"
      "libgcc_eh.a"
    )

    mkdir -p ${SYSROOT}/usr/lib/gcc/${CROSS_TRIPLE}/${CXX_VERSION}; \
      mv  tmp/lib/gcc/${CROSS_TRIPLE}/${CXX_VERSION}/*.o   "${SYSROOT}/usr/lib/gcc/${CROSS_TRIPLE}/${CXX_VERSION}"
    for x in "${libraries[@]}"; do
      mv "tmp/lib/gcc/${CROSS_TRIPLE}/${CXX_VERSION}/${x}" "${SYSROOT}/usr/lib/gcc/${CROSS_TRIPLE}/${CXX_VERSION}"
    done
  }
fi

mkdir -p ${SYSROOT}/usr/include/${CROSS_TRIPLE}/c++; \
  mv tmp/${CROSS_TRIPLE}/include/c++/${CXX_VERSION}/${CROSS_TRIPLE} ${SYSROOT}/usr/include/${CROSS_TRIPLE}/c++/${CXX_VERSION}
mkdir -p ${SYSROOT}/usr/include/c++/${CXX_VERSION}; \
  mv tmp/${CROSS_TRIPLE}/include/c++/${CXX_VERSION}/**              ${SYSROOT}/usr/include/c++/${CXX_VERSION}


# ----------------------------
rm -rf tmp



<<'CROSSTOOL-NG-RELEASE-TREE-VIEW'
${CT_PREFIX}
└── {CROSS_TRIPLE}  <--- ### temporarily renamed to "tmp" ###
    ├── bin
    │   ├── {CROSS_TRIPLE}-{binutils}
    ├── etc
    ├── include
    ├── lib
    │   ├── bfd-plugins
    │   ├── gcc  <--- ### move to "${SYSROOT}/usr/lib/; then remove unused files" ###
    │   ├── gprofng
    │   └── libgprofng.a
    ├── libexec
    ├── share
    └── {CROSS_TRIPLE}
        ├── bin
        │   ├── {binutils}
        ├── debug-root
        ├── include  <--- ### move to "${SYSROOT}/"; then merge into "${SYSROOT}/usr/include" ###
        ├── lib
        │   └── ldscripts
        ├── lib64
        │   ├── {library} -> ../../{CROSS_TRIPLE}/sysroot/lib64/{library}
        └── sysroot
            ├── etc
            ├── lib           <--- ### move to "${SYSROOT}/" ###
            ├── lib64 -> lib
            ├── sbin
            ├── usr
            │   ├── bin
            │   ├── include       <--- ### move to "${SYSROOT}/usr/" ###
            │   ├── lib           <--- ### move to "${SYSROOT}/usr/" ###
            │   ├── lib64 -> lib
            │   ├── libexec
            │   ├── sbin
            │   └── share
            └── var
CROSSTOOL-NG-RELEASE-TREE-VIEW
