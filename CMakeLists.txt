cmake_minimum_required(VERSION 3.9.3)

# Get and setup Hunter
include("cmake/HunterGate.cmake")
HunterGate(
  URL "https://github.com/ruslo/hunter/archive/v0.23.211.tar.gz"
  SHA1 "c022f0c2480e835a6bafdd734035ec2071b51897"
)

# Project data
project(avme-wallet)
set(PROJECT_VERSION 0.0.1)
# TODO: set compiler flags and C++ standard

# Boost options
# TODO: re-check deps
set(Boost_USE_STATIC_LIBS ON) # Link to static versions of Boost libraries
set(Boost_USE_MULTITHREADED ON) # Use multithreaded libs

# External packages
hunter_add_package(Boost COMPONENTS program_options filesystem system thread context fiber log)
find_package(Boost CONFIG REQUIRED program_options filesystem system thread context fiber log)

hunter_add_package(cryptopp)
find_package(cryptopp CONFIG REQUIRED)

hunter_add_package(libscrypt)
find_package(libscrypt CONFIG REQUIRED)

hunter_add_package(ethash)
find_package(ethash CONFIG REQUIRED)

message("Crypto++: ${HUNTER_cryptopp_VERSION}")

# TODO: find out what are those about
#include(ProjectSecp256k1)
#include(ProjectLibFF)
find_package(Threads)
#configure_project()

# Global include path for all libs
# TODO: Check this out later
include_directories("${CMAKE_SOURCE_DIR}")

add_subdirectory(lib/devcore)
add_subdirectory(lib/devcrypto)
add_subdirectory(lib/ethcore)
#add_subdirectory(lib/json_spirit)  # TODO: get rid of this dependency if possible

# Project executable
add_executable(avme-wallet src/avme-wallet.cpp src/avme-wallet.h src/main.cpp)
target_link_libraries(avme-wallet PUBLIC devcore devcrypto ethcore)

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

