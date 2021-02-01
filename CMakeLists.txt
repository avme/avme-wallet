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

cable_add_buildinfo_library(PROJECT_NAME avme_wallet)

# Boost options
set(Boost_USE_STATIC_LIBS ON) # Link to static versions of Boost libraries
set(Boost_USE_MULTITHREADED ON) # Use multithreaded libs

# External packages
hunter_add_package(Boost COMPONENTS filesystem log program_options system thread)
find_package(Boost CONFIG REQUIRED filesystem log program_options system thread)

hunter_add_package(cryptopp)
find_package(cryptopp CONFIG REQUIRED)
message("Crypto++: ${HUNTER_cryptopp_VERSION}")

hunter_add_package(libscrypt)
find_package(libscrypt CONFIG REQUIRED)

hunter_add_package(ethash)
find_package(ethash CONFIG REQUIRED)

include(ProjectSecp256k1)
find_package(Threads)

#Include paths for libs and headers
include_directories("${CMAKE_SOURCE_DIR}" "${CMAKE_SOURCE_DIR}/build")

# Add dirs with required libraries
add_subdirectory(libdevcore)
add_subdirectory(libdevcrypto)
add_subdirectory(libethcore)

# Project executable
add_executable(avme-wallet
  src/json.h src/json.cpp
  src/network.h src/network.cpp
  src/avme-wallet.h src/avme-wallet.cpp
  src/main.cpp
)
target_link_libraries(avme-wallet PUBLIC devcore devcrypto ethcore)


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

