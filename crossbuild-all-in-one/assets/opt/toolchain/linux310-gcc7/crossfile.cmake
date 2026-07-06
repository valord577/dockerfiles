if(_LINUX_CROSS_TOOLCHAIN_INCLUDED)
  return()
endif()
set(_LINUX_CROSS_TOOLCHAIN_INCLUDED true)


get_filename_component(triplet
  "${CMAKE_CURRENT_LIST_FILE}" LAST_EXT
)
string(REGEX REPLACE "^\\." "" triplet "${triplet}")
message(STATUS "Triplet: ${triplet}")
if(triplet MATCHES "^(aarch64|x86_64|arm)-")
  set(target_arch "${CMAKE_MATCH_1}")
else()
  message(FATAL_ERROR "Unsupported Triplet: ${triplet}")
endif()

set(extra_flags)
if(target_arch STREQUAL "arm")
  set(extra_flags "-march=armv7-a" "-mfpu=neon-vfpv4" "-mfloat-abi=hard")
endif()

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR "${target_arch}")
set(CMAKE_CROSSCOMPILING TRUE)
set(CMAKE_SYSROOT "${CMAKE_CURRENT_LIST_DIR}/${triplet}")
set(CMAKE_C_COMPILER   "clang"   "--target=${triplet}" "--gcc-toolchain=${CMAKE_SYSROOT}/usr" ${extra_flags})
set(CMAKE_CXX_COMPILER "clang++" "--target=${triplet}" "--gcc-toolchain=${CMAKE_SYSROOT}/usr" ${extra_flags})
set(CMAKE_ASM_COMPILER "${CMAKE_C_COMPILER}")
set(CMAKE_LINKER_TYPE  "LLD")

set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(PKG_CONFIG_EXECUTABLE "${CMAKE_CURRENT_LIST_DIR}/pkgconf-wrapper.${triplet}" CACHE FILEPATH "pkgconf executable")
