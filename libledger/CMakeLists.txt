file(GLOB SOURCES "*.cpp")
file(GLOB HEADERS "*.h")

add_library(ledger ${SOURCES} ${HEADERS})
target_include_directories(ledger PRIVATE ${UTILS_INCLUDE_DIR})
target_link_libraries(ledger PUBLIC devcrypto devcore ethcore PRIVATE ethash::ethash)
