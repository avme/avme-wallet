file(GLOB SOURCES "*.cpp")
file(GLOB HEADERS "*.h")

add_library(devcore ${SOURCES} ${HEADERS})

# Prevent including system-level boost headers
target_include_directories(devcore SYSTEM PUBLIC ${Boost_INCLUDE_DIR})
target_link_libraries(devcore
  PUBLIC
    avme_wallet-buildinfo
    "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libboost_filesystem-mt-x64.a"
    "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libboost_log-mt-x64.a"
    "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libboost_program_options-mt-x64.a"
    "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libboost_system-mt-x64.a"
    "${CMAKE_SOURCE_DIR}/depends/${DEPENDS_PREFIX}/lib/libboost_thread-mt-x64.a"
  PRIVATE
    ethash::ethash
)

