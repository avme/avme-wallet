include(ExternalProject)
 
if (MSVC)
    set(_only_release_configuration -DCMAKE_CONFIGURATION_TYPES=Release)
    set(_overwrite_install_command INSTALL_COMMAND cmake --build <BINARY_DIR> --config Release --target install)
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
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> -DBUILD_SHARED_LIBS=OFF
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
