#!/usr/bin/env bash
set -ex

# ENV:
#  - CT_PREFIX

cd ${CT_PREFIX}/*; CROSS_TRIPLE="$(basename ${PWD})"; cd ..;
mv ${CROSS_TRIPLE} tmp; mkdir ${CROSS_TRIPLE}
SYSROOT="${CROSS_TRIPLE}"
mkdir -p ${CROSS_TRIPLE}/usr

mv tmp/${CROSS_TRIPLE}/sysroot/lib ${SYSROOT}/
mv tmp/${CROSS_TRIPLE}/sysroot/usr/{include,lib} ${SYSROOT}/usr/
rm -f ${SYSROOT}/lib/libstdc++.so*gdb.py;

mv tmp/lib/gcc ${SYSROOT}/usr/lib/
rm -rf ${SYSROOT}/usr/lib/gcc/*/*/{include,include-fixed,install-tools,plugin}

mv tmp/${CROSS_TRIPLE}/include ${SYSROOT}/
cd ${SYSROOT}/include; CXXDIR="$(dirname c++/*/${CROSS_TRIPLE})"; cd -;
mkdir -p ${SYSROOT}/usr/include/${CROSS_TRIPLE}/${CXXDIR}
mv ${SYSROOT}/include/${CXXDIR}/${CROSS_TRIPLE}/** ${SYSROOT}/usr/include/${CROSS_TRIPLE}/${CXXDIR}
rm -rf ${SYSROOT}/include/${CXXDIR}/${CROSS_TRIPLE}
mv ${SYSROOT}/include/** ${SYSROOT}/usr/include/
rm -rf ${SYSROOT}/include

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
