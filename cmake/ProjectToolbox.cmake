include(ExternalProject)

if (MSVC)
    set(_only_release_configuration -DCMAKE_CONFIGURATION_TYPES=Release)
    set(_overwrite_install_command INSTALL_COMMAND cmake --build <BINARY_DIR> --config Release --target install)
endif()

set(prefix "${CMAKE_BINARY_DIR}/deps")
set(TOOLBOX_LIBRARY "${prefix}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}toolbox${CMAKE_STATIC_LIBRARY_SUFFIX}")
set(TOOLBOX_INCLUDE_DIR "${prefix}/include")

ExternalProject_Add(
    Toolbox
    PREFIX "${prefix}"
    DOWNLOAD_NAME toolbox-3.1.2.tar.gz
    DOWNLOAD_NO_PROGRESS 1
    URL https://github.com/edwardstock/toolbox/archive/3.1.2.tar.gz
    URL_HASH SHA256=1eeba3174a09667ad04d4df667b177eb94e2bae7d79f346d3b3e84a317289376
    PATCH_COMMAND patch -p1 < ${CMAKE_CURRENT_SOURCE_DIR}/cmake/toolbox_limit.patch
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
               -DCMAKE_POSITION_INDEPENDENT_CODE=${BUILD_SHARED_LIBS}
               -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
               -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
               -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
               -DCMAKE_SYSTEM_NAME=Generic # https://github.com/commonmark/cmark/pull/300#issuecomment-496286133
               -DENABLE_CONAN=OFF
               ${_only_release_configuration}
               -DCMAKE_INSTALL_LIBDIR=lib
    LOG_CONFIGURE 1
    BUILD_COMMAND ""
    ${_overwrite_install_command}
    LOG_INSTALL 1
    BUILD_BYPRODUCTS "${TOOLBOX_LIBRARY}"
)

add_library(toolbox STATIC IMPORTED)
file(MAKE_DIRECTORY "${TOOLBOX_INCLUDE_DIR}")  # Must exist.
set_property(TARGET toolbox PROPERTY IMPORTED_CONFIGURATIONS Release)
set_property(TARGET toolbox PROPERTY IMPORTED_LOCATION_RELEASE "${TOOLBOX_LIBRARY}")
set_property(TARGET toolbox PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${TOOLBOX_INCLUDE_DIR}")
add_dependencies(toolbox Toolbox)
