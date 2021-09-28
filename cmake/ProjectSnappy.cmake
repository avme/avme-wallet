include(ExternalProject)

if (MSVC)
    set(_only_release_configuration -DCMAKE_CONFIGURATION_TYPES=Release)
    set(_overwrite_install_command INSTALL_COMMAND cmake --build <BINARY_DIR> --config Release --target install)
endif()

if (DEPENDS_PREFIX STREQUAL "x86_64-w64-mingw32")
  set(_windows_configuration -DCMAKE_CROSSCOMPILING=1 -DRUN_HAVE_STD_REGEX=0  -DRUN_HAVE_POSIX_REGEX=0 -DWIN32=ON)
endif()

set(prefix "${CMAKE_BINARY_DIR}/deps")
set(SNAPPY_LIBRARY "${prefix}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}snappy${CMAKE_STATIC_LIBRARY_SUFFIX}")
set(SNAPPY_INCLUDE_DIR "${prefix}/include")

ExternalProject_Add(
    Snappy
    PREFIX "${prefix}"
    DOWNLOAD_NAME snappy-1.1.9.tar.gz
    DOWNLOAD_NO_PROGRESS 1
    URL https://github.com/google/snappy/archive/refs/tags/1.1.9.zip
    URL_HASH SHA256=e170ce0def2c71d0403f5cda61d6e2743373f9480124bcfcd0fa9b3299d428d9
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
               -DCMAKE_POSITION_INDEPENDENT_CODE=${BUILD_SHARED_LIBS}
               -DCMAKE_SYSTEM_NAME=${CMAKE_SYSTEM_NAME}
               -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
               -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
               -DCMAKE_C_FLAGS=-I${SNAPPY_INCLUDE_DIR}
               -DCMAKE_CXX_FLAGS=-I${SNAPPY_INCLUDE_DIR}\ -I${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/include\ ${CMAKE_CXX_FLAGS}
               ${_only_release_configuration}
               ${_windows_configuration}
               -DSNAPPY_BUILD_TESTS=OFF
               -DSNAPPY_BUILD_BENCHMARKS=OFF
               -DCMAKE_INSTALL_LIBDIR=lib
    LOG_CONFIGURE 1
    BUILD_COMMAND ""
    ${_overwrite_install_command}
    LOG_INSTALL 1
    BUILD_BYPRODUCTS "${SNAPPY_LIBRARY}"
)

add_library(snappy STATIC IMPORTED)
file(MAKE_DIRECTORY "${SNAPPY_INCLUDE_DIR}")  # Must exist.
set_property(TARGET snappy PROPERTY IMPORTED_CONFIGURATIONS Release)
set_property(TARGET snappy PROPERTY IMPORTED_LOCATION_RELEASE "${SNAPPY_LIBRARY}")
set_property(TARGET snappy PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${SNAPPY_INCLUDE_DIR}")
add_dependencies(snappy Snappy)

