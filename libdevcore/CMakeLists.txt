file(GLOB SOURCES "*.cpp")
file(GLOB HEADERS "*.h")

add_library(devcore ${SOURCES} ${HEADERS})

target_link_libraries(devcore
  PUBLIC
    avme_wallet-buildinfo ${BOOST_LIBS} ${QT_LIBS}
  PRIVATE
    Ethash ${ETHASH_BYPRODUCTS} bip39 toolbox
)
