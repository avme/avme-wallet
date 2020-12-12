file(GLOB SOURCES "*.cpp")
file(GLOB HEADERS "*.h")

add_library(devcore ${SOURCES} ${HEADERS})

# Prevent including system-level boost headers
target_include_directories(devcore SYSTEM PUBLIC ${Boost_INCLUDE_DIR})
target_link_libraries(devcore
  PUBLIC
    avme_wallet-buildinfo Boost::filesystem Boost::system
    Boost::log Boost::thread Threads::Threads
  PRIVATE
    ethash::ethash
)

