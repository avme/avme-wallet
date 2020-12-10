# TODO: use file(GLOB SOURCES "*.cpp") and file(GLOB HEADERS "*.h")
add_library(devcore
  Address.cpp
  Address.h
  Assertions.h
  Base64.cpp
  Base64.h
  Common.cpp
  Common.h
  CommonData.cpp
  CommonData.h
  CommonIO.cpp
  CommonIO.h
  Exceptions.h
  FileSystem.cpp
  FileSystem.h
  FixedHash.cpp
  FixedHash.h
  Guards.cpp
  Guards.h
  Log.cpp
  Log.h
  LoggingProgramOptions.cpp
  LoggingProgramOptions.h
  RLP.cpp
  RLP.h
  SHA3.cpp
  SHA3.h
  StateCacheDB.cpp
  StateCacheDB.h
  Terminal.h
  TrieCommon.cpp
  TrieCommon.h
  TrieDB.h
  TrieHash.cpp
  TrieHash.h
  vector_ref.h
)

# Prevent including system-level boost headers
target_include_directories(devcore SYSTEM PUBLIC ${Boost_INCLUDE_DIR})

target_link_libraries(devcore
  PUBLIC
    Boost::filesystem Boost::system Boost::log Boost::thread Threads::Threads
  PRIVATE
    ethash::ethash
)

