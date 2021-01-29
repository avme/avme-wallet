# Pre-setup
cmake_minimum_required(VERSION 3.9.3)

include(cmake/cable/bootstrap.cmake)
include(CableBuildInfo)
include(CableBuildType)
include(GNUInstallDirs)

cable_set_build_type(DEFAULT RelWithDebInfo CONFIGURATION_TYPES Debug;Release;RelWithDebInfo)

# Map current configuration to configurations of imported targets.
set(CMAKE_MAP_IMPORTED_CONFIG_DEBUG Release)
set(CMAKE_MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release)

# Get Hunter
include("cmake/HunterGate.cmake")
HunterGate(
  URL "https://github.com/cpp-pm/hunter/archive/v0.23.288.tar.gz"
  SHA1 "6c9b2bc606d86ae31f96a62fc68f0a593024815b"
  LOCAL # Load config from `${CMAKE_CURRENT_LIST_DIR}/cmake/Hunter/config.cmake`
)

# Project data
project(avme_wallet)
set(PROJECT_VERSION 0.0.1)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
message("C++ Standard: ${CMAKE_CXX_STANDARD}")
message("C++ Standard is required: ${CMAKE_CXX_STANDARD_REQUIRED}")
message("C++ extensions: ${CMAKE_CXX_EXTENSIONS}")
message("Using PIC: ${CMAKE_POSITION_INDEPENDENT_CODE}")

set(DEPENDS_PREFIX "")
if("${TOOLCHAIN_PREFIX}" STREQUAL "x86_64-w64-mingw32")
  message("Toolchain: x86_64-w64-mingw32")
  set(DEPENDS_PREFIX "x86_64-w64-mingw32")
else()
  message("Toolchain: x86_64-pc-linux-gnu")
  set(DEPENDS_PREFIX "x86_64-pc-linux-gnu")
endif()

cable_add_buildinfo_library(PROJECT_NAME avme_wallet)

# Add Hunter packages
hunter_add_package(cryptopp)
find_package(cryptopp CONFIG REQUIRED)

hunter_add_package(libscrypt)
find_package(libscrypt CONFIG REQUIRED)

hunter_add_package(ethash)
find_package(ethash CONFIG REQUIRED)

include(ProjectSecp256k1)
include(ProjectLibFF)
find_package(Threads)

# Include paths for local libs and headers
include_directories(
  "${CMAKE_SOURCE_DIR}" "${CMAKE_SOURCE_DIR}/build" "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/include"
)
link_directories(
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib"
)

# Uncomment to see include and link directories
#get_property(inc_dirs DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY INCLUDE_DIRECTORIES)
#get_property(link_dirs DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY LINK_DIRECTORIES)
#foreach(dir ${inc_dirs})
#  message(STATUS "dir='${dir}'")
#endforeach()
#foreach(dir ${link_dirs})
#  message(STATUS "dir='${dir}'")
#endforeach()

# Add local libs
add_subdirectory(libdevcore)
add_subdirectory(libdevcrypto)
add_subdirectory(libethcore)

# Add project executable
add_executable(avme-wallet
  src/json.h src/json.cpp
  src/network.h src/network.cpp
  src/avme-wallet.h src/avme-wallet.cpp
  src/main.cpp
)
# TODO: link those in a more clean way (here and on libdevcore)
target_link_libraries(avme-wallet PUBLIC
  devcore devcrypto ethcore ethash::ethash
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libboost_filesystem-mt-x64.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libboost_log-mt-x64.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libboost_program_options-mt-x64.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libboost_system-mt-x64.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libboost_thread-mt-x64.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Core.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Gui.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Qml.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Quick.a"
)

# TODO: the install part

# CPack stuff for packaging cross-platform binaries
# TODO: understand what this does
if(WIN32)
  set(CPACK_GENERATOR ZIP)
else()
  set(CPACK_GENERATOR TGZ)
endif()
set(CPACK_PACKAGE_FILE_NAME ${PROJECT_NAME})
set(CPACK_PACKAGE_CHECKSUM SHA256)
set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY FALSE)
include(CPack)

