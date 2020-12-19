# cryptopp has very bad CMakeLists.txt config.
# We have to enforce "cross compiling mode" there by setting CMAKE_SYSTEM_VERSION=NO
# to any "false" value.
hunter_config(cryptopp VERSION ${HUNTER_cryptopp_VERSION} CMAKE_ARGS CMAKE_SYSTEM_VERSION=NO)

if(MINGW)
  hunter_config(Boost VERSION 1.70.0-p0) # https://github.com/boostorg/build/issues/532
else()
  hunter_config(Boost VERSION 1.72.0-p0)
endif()

if(MSVC)
  hunter_config(
    libscrypt
    VERSION ${HUNTER_libscrypt_VERSION}
    CMAKE_ARGS CMAKE_C_FLAGS=-D_CRT_SECURE_NO_WARNINGS
  )
endif()

