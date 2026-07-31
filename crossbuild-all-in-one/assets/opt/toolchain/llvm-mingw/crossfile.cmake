if(_LLVM_MINGW_CROSS_TOOLCHAIN_INCLUDED)
  return()
endif()
set(_LLVM_MINGW_CROSS_TOOLCHAIN_INCLUDED true)


get_filename_component(fext
  "${CMAKE_CURRENT_LIST_FILE}" LAST_EXT
)
string(REGEX REPLACE "^\\." "" fext "${fext}")
string(REGEX MATCHALL "[^-]+" archinfo "${fext}")
list(GET archinfo 0 arch)


set(triplet)
set(extra_flags)
if(arch STREQUAL "amd64")
  set(triplet "x86_64-w64-mingw32")
  set(extra_flags "-march=x86-64-v2")
elseif(arch STREQUAL "arm64")
  set(triplet "aarch64-w64-mingw32")
  set(extra_flags "-march=armv8-a")
else()
  message(FATAL_ERROR "Unsupported ARCH: ${arch}")
endif()



set(MinGW TRUE)
set(WIN32 TRUE)
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR "${arch}")
set(CMAKE_CROSSCOMPILING TRUE)
set(CMAKE_SYSROOT "${CMAKE_CURRENT_LIST_DIR}/${triplet}")
set(CMAKE_C_COMPILER   "${CMAKE_CURRENT_LIST_DIR}/bin/${triplet}-clang"   ${extra_flags})
set(CMAKE_CXX_COMPILER "${CMAKE_CURRENT_LIST_DIR}/bin/${triplet}-clang++" ${extra_flags})
set(CMAKE_RC_COMPILER  "${CMAKE_CURRENT_LIST_DIR}/bin/${triplet}-windres")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(PKG_CONFIG_EXECUTABLE "${CMAKE_CURRENT_LIST_DIR}/pkgconf-wrapper.${arch}" CACHE FILEPATH "pkgconf executable")
