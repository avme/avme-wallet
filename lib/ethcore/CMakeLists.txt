# TODO: use file(GLOB SOURCES "*.cpp") and file(GLOB HEADERS "*.h")
add_library(ethcore
  BlockHeader.cpp
  BlockHeader.h
  ChainOperationParams.cpp
  ChainOperationParams.h
  EVMSchedule.cpp
  EVMSchedule.h
  Exceptions.h
  KeyManager.cpp
  KeyManager.h
  Precompiled.cpp
  Precompiled.h
  TransactionBase.cpp
  TransactionBase.h
)

# TODO: re-check those deps
target_include_directories(ethcore PRIVATE "${UTILS_INCLUDE_DIR}")
target_link_libraries(ethcore PUBLIC devcrypto devcore)

