# Pre-setup
cmake_minimum_required(VERSION 3.18.0)

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
# Macro adapted from https://stackoverflow.com/a/31004567
# TODO: decide if we'll be using this anyway or not
macro(get_depends_includes_rec list)
    FILE(GLOB_RECURSE new_list "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/include/Qt*/*.h")
    SET(dir_list "")
    FOREACH(file_path ${new_list})
        GET_FILENAME_COMPONENT(dir_path ${file_path} PATH)
        SET(dir_list ${dir_list} ${dir_path})
    ENDFOREACH()
    LIST(REMOVE_DUPLICATES dir_list)
    SET(${list} ${dir_list})
ENDMACRO()

#get_depends_includes_rec(DEPENDS_INCLUDES)

include_directories(
  "${CMAKE_SOURCE_DIR}" "${CMAKE_SOURCE_DIR}/build" "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/include" #${DEPENDS_INCLUDES}
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

# Organize libs
file(GLOB BOOST_LIBS
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libboost_filesystem-mt-x64.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libboost_log-mt-x64.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libboost_program_options-mt-x64.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libboost_system-mt-x64.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libboost_thread-mt-x64.a"
)

# Add local libs
add_subdirectory(libdevcore)
add_subdirectory(libdevcrypto)
add_subdirectory(libethcore)

# Organize executable sources and headers
file(GLOB AVME_HEADERS "src/lib/*.h")
file(GLOB AVME_SOURCES "src/lib/*.cpp")

# Compile project executables
add_executable(avme-cli
  ${AVME_HEADERS} ${AVME_SOURCES} src/main-cli.h src/main-cli.cpp
)
target_link_libraries(avme-cli PUBLIC
  devcore devcrypto ethcore ethash::ethash ${BOOST_LIBS}
)

# Compile Qt-specific stuff to embed into GUI executable.
# First command is a dummy output to force whatever depends on it to always be rebuilt. Adapted from https://stackoverflow.com/a/32062884
# moc creates a source file with meta-object data that allows for C++/Qt interfacing (e.g. classes that use the Q_OBJECT macro).
# rcc creates a source file with all the resources used in the .qrc file to be compiled into the executable.
# TODO: understand why those commands are being run twice
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

# Add project executable and link libraries to it
add_executable(avme-gui
  ${AVME_HEADERS} ${AVME_SOURCES} src/main-gui.h src/main-gui.cpp build/moc_main-gui.cpp build/qml.cpp
)

# TODO: Fix library order, it is very messy currently
target_link_libraries(avme-gui PUBLIC
  devcore devcrypto ethcore ethash::ethash -ldl ${BOOST_LIBS}
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Network.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Gui.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Qml.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/qml/QtQuick.2/libqtquick2plugin.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/qml/QtQuick/Window.2/libwindowplugin.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Quick.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libqtlibpng.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libqtharfbuzz.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libz.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5DBus.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Widgets.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Core.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/plugins/platforms/libqxcb.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5XcbQpa.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5EventDispatcherSupport.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5ServiceSupport.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5ThemeSupport.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5FontDatabaseSupport.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5DBus.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libfreetype.so.6.13.0"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libfontconfig.so.1.9.2"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libxcb-static.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libxcb.so.1.1.0"
  # I don't know why this works the way it does, it just *does*, let's roll with it
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Network.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5Gui.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/qml/QtQuick/Controls.2/libqtquickcontrols2plugin.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5QuickControls2.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5XcbQpa.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/qml/QtQuick/Templates.2/libqtquicktemplates2plugin.a"
  "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libQt5QuickTemplates2.a"
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

