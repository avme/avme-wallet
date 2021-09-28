include(ExternalProject)
 
if (MSVC)
    set(_only_release_configuration -DCMAKE_CONFIGURATION_TYPES=Release)
    set(_overwrite_install_command INSTALL_COMMAND cmake --build <BINARY_DIR> --config Release --target install)
endif()

if (DEPENDS_PREFIX STREQUAL "x86_64-w64-mingw32")
  set(_windows_configuration -DCMAKE_CROSSCOMPILING=1 -DRUN_HAVE_STD_REGEX=0  -DRUN_HAVE_POSIX_REGEX=0 -DWIN32=ON)
endif()

set(prefix "${CMAKE_BINARY_DIR}/deps")
set(MD4C_LIBRARY "${prefix}/lib/md4c/${CMAKE_STATIC_LIBRARY_PREFIX}md4c${CMAKE_STATIC_LIBRARY_SUFFIX}")
set(MD4C_INCLUDE_DIR "${prefix}/include")

ExternalProject_Add(
    libmd4c
    PREFIX "${prefix}"
    DOWNLOAD_NAME 
    DOWNLOAD_NO_PROGRESS 1
    URL https://github.com/mity/md4c/archive/release-0.4.8.zip
    URL_HASH SHA256=bc7910a0ac6ca4863353d585a1ddc150d1e9b9c4dd02bc55520c5a6620e1e211
    PATCH_COMMAND patch -p1 < ${CMAKE_CURRENT_SOURCE_DIR}/cmake/libmd4c_no_md2html.patch
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> 
               -DBUILD_SHARED_LIBS=OFF
               -DCMAKE_POSITION_INDEPENDENT_CODE=${BUILD_SHARED_LIBS}
               -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
               -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
               -DCMAKE_C_FLAGS=-I${MD4C_INCLUDE_DIR}
               -DCMAKE_CXX_FLAGS=-I${MD4C_INCLUDE_DIR}\ -I${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/include\ ${CMAKE_CXX_FLAGS}
               ${_only_release_configuration}
               ${_windows_configuration}
               -DCMAKE_INSTALL_LIBDIR=lib/md4c
    LOG_CONFIGURE 1
    ${_overwrite_install_command}
    BUILD_BYPRODUCTS "${MD4C_LIBRARY}"
)

add_library(md4c STATIC IMPORTED)
file(MAKE_DIRECTORY "${MD4C_INCLUDE_DIR}")  # Must exist.
set_property(TARGET md4c PROPERTY IMPORTED_CONFIGURATIONS Release)
set_property(TARGET md4c PROPERTY IMPORTED_LOCATION_RELEASE "${MD4C_LIBRARY}")
set_property(TARGET md4c PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${MD4C_INCLUDE_DIR}")
add_dependencies(md4c libmd4c)
