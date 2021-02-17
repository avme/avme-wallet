include(ExternalProject)

if (MSVC)
    set(_only_release_configuration -DCMAKE_CONFIGURATION_TYPES=Release)
    set(_overwrite_install_command INSTALL_COMMAND cmake --build <BINARY_DIR> --config Release --target install)
endif()

set(prefix "${CMAKE_BINARY_DIR}/deps")
set(BIP3X_LIBRARY "${prefix}/lib/bip3x-2.1/${CMAKE_STATIC_LIBRARY_PREFIX}bip39${CMAKE_STATIC_LIBRARY_SUFFIX}")
set(BIP3X_INCLUDE_DIR "${prefix}/include")

ExternalProject_Add(
    bip3x
    PREFIX "${prefix}"
    DOWNLOAD_NAME bip3x-77585ff.tar.gz
    DOWNLOAD_NO_PROGRESS 1
    URL https://github.com/itamarcps/bip3x/archive/77585ff29ce89af12baf860ab5f7afeedb81a7ce.tar.gz
    URL_HASH SHA256=fbffefc73b9974b393a1b3fccabfc32c18c6746ec3e03c439aba309f99406816
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
               -DCMAKE_POSITION_INDEPENDENT_CODE=${BUILD_SHARED_LIBS}
               -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
               -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
               -DENABLE_CONAN=OFF
               -DENABLE_BIP39_JNI=OFF
               ${_only_release_configuration}
    LOG_CONFIGURE 1
    BUILD_COMMAND ""
    ${_overwrite_install_command}
    LOG_INSTALL 1
    BUILD_BYPRODUCTS "${BIP3X_LIBRARY}"
	DEPENDS ssl crypto
)

add_library(bip39 STATIC IMPORTED)
file(MAKE_DIRECTORY "${BIP3X_INCLUDE_DIR}")  # Must exist.
set_property(TARGET bip39 PROPERTY IMPORTED_CONFIGURATIONS Release)
set_property(TARGET bip39 PROPERTY IMPORTED_LOCATION_RELEASE "${BIP3X_LIBRARY}")
set_property(TARGET bip39 PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${BIP3X_INCLUDE_DIR}")
add_dependencies(bip39 bip3x)
