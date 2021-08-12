include(ExternalProject)

if (MSVC)
    set(_only_release_configuration -DCMAKE_CONFIGURATION_TYPES=Release)
    set(_overwrite_install_command INSTALL_COMMAND cmake --build <BINARY_DIR> --config Release --target install)
endif()

set(prefix "${CMAKE_BINARY_DIR}/deps")
set(SECP256K1_LIBRARY "${prefix}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}secp256k1${CMAKE_STATIC_LIBRARY_SUFFIX}")
set(SECP256K1_INCLUDE_DIR "${prefix}/include")

ExternalProject_Add(
    secp256k1
    PREFIX "${prefix}"
    DOWNLOAD_NAME secp256k1-ac8ccf29.tar.gz
    DOWNLOAD_NO_PROGRESS 1
    URL https://github.com/itamarcps/secp256k1/archive/a74a75089ff65740cc14b3a084fa7c9d27a49174.tar.gz
    URL_HASH SHA256=3d5e56561690397862869e6d58f312db045709a9b7438c3462f865b4841aeac0
    PATCH_COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${CMAKE_CURRENT_LIST_DIR}/secp256k1/CMakeLists.txt <SOURCE_DIR>
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
               -DCMAKE_POSITION_INDEPENDENT_CODE=${BUILD_SHARED_LIBS}
               -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
               -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
               -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
               ${_only_release_configuration}
               -DCMAKE_INSTALL_LIBDIR=lib
    LOG_CONFIGURE 1
    BUILD_COMMAND ""
    ${_overwrite_install_command}
    LOG_INSTALL 1
    BUILD_BYPRODUCTS "${SECP256K1_LIBRARY}"
)

# Create imported library
add_library(Secp256k1 STATIC IMPORTED)
file(MAKE_DIRECTORY "${SECP256K1_INCLUDE_DIR}")  # Must exist.
set_property(TARGET Secp256k1 PROPERTY IMPORTED_CONFIGURATIONS Release)
set_property(TARGET Secp256k1 PROPERTY IMPORTED_LOCATION_RELEASE "${SECP256K1_LIBRARY}")
set_property(TARGET Secp256k1 PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${SECP256K1_INCLUDE_DIR}")
add_dependencies(Secp256k1 secp256k1)
