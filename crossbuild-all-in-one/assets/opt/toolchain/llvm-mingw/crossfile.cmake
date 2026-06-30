if(_LLVM_MINGW_CROSS_TOOLCHAIN_INCLUDED)
  return()
endif()
set(_LLVM_MINGW_CROSS_TOOLCHAIN_INCLUDED true)


get_filename_component(triplet
  "${CMAKE_CURRENT_LIST_FILE}" LAST_EXT
)
string(REGEX REPLACE "^\\." "" triplet "${triplet}")
message(STATUS "Triplet: ${triplet}")
if(triplet MATCHES "^(arm64|aarch64-)")
  set(target_arch "aarch64")
  set(triplet "aarch64-w64-mingw32")
elseif(triplet MATCHES "^(amd64|x86_64-)")
  set(target_arch "x86_64")
  set(triplet "x86_64-w64-mingw32")
else()
  message(FATAL_ERROR "Unsupported Triplet: ${triplet}")
endif()

set(MinGW TRUE)
set(WIN32 TRUE)
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR "${target_arch}")
set(CMAKE_CROSSCOMPILING TRUE)
set(CMAKE_SYSROOT "${CMAKE_CURRENT_LIST_DIR}/${triplet}")
set(CMAKE_C_COMPILER   "${CMAKE_CURRENT_LIST_DIR}/bin/${triplet}-clang")
set(CMAKE_CXX_COMPILER "${CMAKE_CURRENT_LIST_DIR}/bin/${triplet}-clang++")
set(CMAKE_RC_COMPILER  "${CMAKE_CURRENT_LIST_DIR}/bin/${triplet}-windres")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(PKG_CONFIG_EXECUTABLE "${CMAKE_CURRENT_LIST_DIR}/pkgconf-wrapper.${triplet}" CACHE FILEPATH "pkgconf executable")
