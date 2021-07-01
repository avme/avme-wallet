include(ExternalProject)
 
if (MSVC)
    set(_only_release_configuration -DCMAKE_CONFIGURATION_TYPES=Release)
    set(_overwrite_install_command INSTALL_COMMAND cmake --build <BINARY_DIR> --config Release --target install)
endif()
 
set(prefix "${CMAKE_BINARY_DIR}/deps")
set(ETHASH_LIBRARY "${prefix}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ethash${CMAKE_STATIC_LIBRARY_SUFFIX}")
set(ETHASH_INCLUDE_DIR "${prefix}/include")
set(ETHASH_BYPRODUCTS "${prefix}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}keccak${CMAKE_STATIC_LIBRARY_SUFFIX}")
 
ExternalProject_Add(
    ethash
    PREFIX "${prefix}"
    DOWNLOAD_NAME ethash-v0.5.0.tar.gz
    DOWNLOAD_NO_PROGRESS 1
    URL https://github.com/chfast/ethash/archive/v0.5.0.tar.gz
    URL_HASH SHA256=16bce25f34b733a91530d22f31626fc1060f2fa5105165efdd9ba65e3e3e10ac
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
               -DCMAKE_POSITION_INDEPENDENT_CODE=${BUILD_SHARED_LIBS}
               -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
               -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
			   -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
			   -DETHASH_BUILD_TESTS=OFF
		-DCMAKE_INSTALL_LIBDIR=lib
               ${_only_release_configuration}
    LOG_CONFIGURE 1
    BUILD_COMMAND ""
    ${_overwrite_install_command}
    LOG_INSTALL 1
    BUILD_BYPRODUCTS "${ETHASH_BYPRODUCTS}"
)
 
# Create imported library
add_library(Ethash STATIC IMPORTED)
file(MAKE_DIRECTORY "${ETHASH_INCLUDE_DIR}")  # Must exist.
set_property(TARGET Ethash PROPERTY IMPORTED_CONFIGURATIONS Release)
set_property(TARGET Ethash PROPERTY IMPORTED_LOCATION_RELEASE "${ETHASH_LIBRARY}")
set_property(TARGET Ethash PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${ETHASH_INCLUDE_DIR}")
add_dependencies(Ethash ethash ${ETHASH_BYPRODUCTS})
