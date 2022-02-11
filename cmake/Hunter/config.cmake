# cryptopp has very bad CMakeLists.txt config.
# We have to enforce "cross compiling mode" there by setting CMAKE_SYSTEM_VERSION=NO
# to any "false" value.

if("${TOOLCHAIN_PREFIX}" STREQUAL "arm-apple-darwin21.2.0")
  hunter_config(cryptopp VERSION ${HUNTER_cryptopp_VERSION} CMAKE_ARGS CMAKE_SYSTEM_VERSION=NO
                                                                       DISABLE_ASM=YES)
else()
  hunter_config(cryptopp VERSION ${HUNTER_cryptopp_VERSION} CMAKE_ARGS CMAKE_SYSTEM_VERSION=NO)
endif()

if(MSVC)
  hunter_config(
    libscrypt
    VERSION ${HUNTER_libscrypt_VERSION}
    CMAKE_ARGS CMAKE_C_FLAGS=-D_CRT_SECURE_NO_WARNINGS
  )
endif()

