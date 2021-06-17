# Copyright (c) 2020-2021 AVME Developers
# Distributed under the MIT/X11 software license, see the accompanying
# file LICENSE or http://www.opensource.org/licenses/mit-license.php.

# Pre-setup
cmake_minimum_required(VERSION 3.19.0)
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
set(PROJECT_VERSION 1.2.0)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
option(TESTNET OFF)
message("C++ Standard: ${CMAKE_CXX_STANDARD}")
message("C++ Standard is required: ${CMAKE_CXX_STANDARD_REQUIRED}")
message("C++ extensions: ${CMAKE_CXX_EXTENSIONS}")
message("Using PIC: ${CMAKE_POSITION_INDEPENDENT_CODE}")
cable_add_buildinfo_library(PROJECT_NAME avme_wallet)
set(DEPENDS_PREFIX "")
if("${TOOLCHAIN_PREFIX}" STREQUAL "x86_64-w64-mingw32")
  set(DEPENDS_PREFIX "x86_64-w64-mingw32")
  message("Toolchain: x86_64-w64-mingw32")
  message("Loading Windows Libraries")
  include("${CMAKE_SOURCE_DIR}/cmake/WindowsLibraries.cmake")
else()
  if("${TOOLCHAIN_PREFIX}" STREQUAL "x86_64-apple-darwin20")
    message("Toolchain: x86_64-apple-darwin20")
    set(DEPENDS_PREFIX "x86_64-apple-darwin20.5.0")
    message("Loading Darwin Libraries")
    include("${CMAKE_SOURCE_DIR}/cmake/DarwinLibraries.cmake")
  else()
    message("Toolchain: x86_64-pc-linux-gnu")
    set(DEPENDS_PREFIX "x86_64-pc-linux-gnu")
    include("${CMAKE_SOURCE_DIR}/cmake/LinuxLibraries.cmake")
    message("Loading Linux Libraries")
  endif()
endif()

# Add Hunter packages
hunter_add_package(cryptopp)
find_package(cryptopp CONFIG REQUIRED)
hunter_add_package(libscrypt)
find_package(libscrypt CONFIG REQUIRED)

# Add external modules
add_subdirectory(external/openssl-cmake)
include(ProjectEthash)
include(ProjectLevelDB)
include(ProjectSecp256k1)
include(ProjectToolbox)
include(ProjectBip3x)
find_package(Threads)

# Include headers and libs
include_directories(
  "${CMAKE_SOURCE_DIR}"
  "${CMAKE_SOURCE_DIR}/src"
  "${CMAKE_SOURCE_DIR}/build"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/include"
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
add_subdirectory(libledger)

# Organize executable sources and headers
file(GLOB AVME_HEADERS "src/lib/*.h")
file(GLOB AVME_SOURCES "src/lib/*.cpp")

# Compile the project library
add_library(avme-lib ${AVME_HEADERS} ${AVME_SOURCES})
target_link_libraries(avme-lib PUBLIC
  devcore devcrypto ethcore ledger ${ETHASH_BYPRODUCTS} Ethash ssl crypto toolbox bip39 LevelDB ${BOOST_LIBS}
)

# Set the project version as a macro in a header file
configure_file("${CMAKE_SOURCE_DIR}/src/version.h.in" "${CMAKE_SOURCE_DIR}/src/version.h" @ONLY)

# Compile Qt-specific stuff to embed into the GUI executable.
# First command is a dummy output to force whatever depends on it to
# always be rebuilt (adapted from https://stackoverflow.com/a/32062884).
# moc creates a source file with meta-object data that allows for
# C++/Qt interfacing (e.g. classes that use the Q_OBJECT macro).
# rcc creates a source file with all the resources used in the .qrc file
# to be compiled into the executable.
add_custom_command(
  OUTPUT always_rebuild
  COMMAND ""
)
add_custom_command(
  OUTPUT "${CMAKE_SOURCE_DIR}/build/moc_main-gui.cpp"
  COMMAND "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/native/bin/moc" "${CMAKE_SOURCE_DIR}/src/main-gui.h" -o "${CMAKE_SOURCE_DIR}/build/moc_main-gui.cpp"
  DEPENDS always_rebuild
)
add_custom_command(
  OUTPUT "${CMAKE_SOURCE_DIR}/build/qml.cpp"
  COMMAND "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/native/bin/rcc" "${CMAKE_SOURCE_DIR}/src/qml.qrc" -o "${CMAKE_SOURCE_DIR}/build/qml.cpp"
  DEPENDS always_rebuild
  )

# Set testnet or mainnet
if(TESTNET)
  add_definitions(-DTESTNET)
endif()

# Compile the GUI executable
if("${TOOLCHAIN_PREFIX}" STREQUAL "x86_64-w64-mingw32")
  set(APP_ICON_RESOURCE_WINDOWS "${CMAKE_SOURCE_DIR}/src/winico.rc")
  add_executable(avme-gui WIN32
    src/version.h src/main-gui.h src/main-gui.cpp build/moc_main-gui.cpp build/qml.cpp
    ${APP_ICON_RESOURCE_WINDOWS}
  )
else()
  add_executable(avme-gui
    src/version.h src/main-gui.h src/main-gui.cpp build/moc_main-gui.cpp build/qml.cpp
  )
endif()
target_link_libraries(avme-gui PUBLIC avme-lib ${QT_LIBS})

# CPack stuff for packaging cross-platform binaries
if(WIN32)
  set(CPACK_GENERATOR ZIP)
else()
  set(CPACK_GENERATOR TGZ)
endif()
set(CPACK_PACKAGE_FILE_NAME ${PROJECT_NAME})
set(CPACK_PACKAGE_CHECKSUM SHA256)
set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY FALSE)
include(CPack)

