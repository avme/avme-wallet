# TODO: use file(GLOB SOURCES "*.cpp") and file(GLOB HEADERS "*.h")
add_library(devcrypto
  AES.cpp
  AES.h
  Blake2.cpp
  Blake2.h
  Common.cpp
  Common.h
  CryptoPP.cpp
  CryptoPP.h
  Exceptions.h
  Hash.cpp
  Hash.h
  LibSnark.cpp
  LibSnark.h
  SecretStore.cpp
  SecretStore.h
)

# TODO: re-check those deps
target_include_directories(devcrypto PRIVATE ${UTILS_INCLUDE_DIR})
target_link_libraries(devcrypto
  PUBLIC
    devcore Secp256k1
  PRIVATE
    cryptopp-static libscrypt::scrypt
)

