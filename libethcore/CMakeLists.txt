file(GLOB SOURCES "*.cpp")
file(GLOB HEADERS "*.h")

add_library(ethcore ${SOURCES} ${HEADERS})
target_include_directories(ethcore PRIVATE ${UTILS_INCLUDE_DIR})
target_link_libraries(ethcore PUBLIC devcrypto devcore PRIVATE ethash::ethash)

