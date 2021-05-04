include(ExternalProject)

if (MSVC)
    set(_only_release_configuration -DCMAKE_CONFIGURATION_TYPES=Release)
    set(_overwrite_install_command INSTALL_COMMAND cmake --build <BINARY_DIR> --config Release --target install)
endif()

set(prefix "${CMAKE_BINARY_DIR}/deps")
set(LEDGERCORE_LIBRARY "${prefix}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ledger-core-static${CMAKE_STATIC_LIBRARY_SUFFIX}")
set(LEDGERCORE_INCLUDE_DIR "${prefix}/include")

ExternalProject_Add(
    Ledgercore
    PREFIX "${prefix}"
    DOWNLOAD_NAME libledgercore.tar.gz
    DOWNLOAD_NO_PROGRESS 1
    GIT_REPOSITORY https://github.com/itamarcps/lib-ledger-core.git
	GIT_TAG 4.2.0-mingw-fix
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
               -DCMAKE_POSITION_INDEPENDENT_CODE=${BUILD_SHARED_LIBS}
               -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
               -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
			   -DCMAKE_SYSTEM_NAME=${CMAKE_SYSTEM_NAME}
			   -DTOOLCHAIN_PREFIX=${TOOLCHAIN_PREFIX}
			   -DCMAKE_RC_COMPILER=${CMAKE_RC_COMPILER}
			   -DCMAKE_FIND_ROOT_PATH=${CMAKE_FIND_ROOT_PATH}
			   -DSYS_OPENSSL=OFF 
			   -DOPENSSL_ROOT_DIR=${CMAKE_SOURCE_DIR}/build/external/openssl-cmake/
			   -DOPENSSL_INCLUDE_DIR=${CMAKE_SOURCE_DIR}/build/external/openssl-cmake/include
			   -DOPENSSL_SSL_LIBRARIES=${CMAKE_SOURCE_DIR}/build/external/openssl-cmake/ssl
			   -DOPENSSL_USE_STATIC_LIBS=TRUE
			   -DBUILD_TESTS=OFF
               ${_only_release_configuration}
    LOG_CONFIGURE ON
    BUILD_COMMAND ""
    ${_overwrite_install_command}
    LOG_INSTALL ON
    BUILD_BYPRODUCTS "${LEDGERCORE_LIBRARY}"
	DEPENDS openssl
)

add_library(ledgercore STATIC IMPORTED)
file(MAKE_DIRECTORY "${LEDGERCORE_INCLUDE_DIR}")  # Must exist.
set_property(TARGET ledgercore PROPERTY IMPORTED_CONFIGURATIONS Release)
set_property(TARGET ledgercore PROPERTY IMPORTED_LOCATION_RELEASE "${LEDGERCORE_LIBRARY}")
set_property(TARGET ledgercore PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${LEDGERCORE_INCLUDE_DIR}")
add_dependencies(ledgercore Ledgercore ssl crypto openssl)
