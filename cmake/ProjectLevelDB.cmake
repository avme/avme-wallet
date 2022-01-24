include(ExternalProject)

if (MSVC)
    set(_only_release_configuration -DCMAKE_CONFIGURATION_TYPES=Release)
    set(_overwrite_install_command INSTALL_COMMAND cmake --build <BINARY_DIR> --config Release --target install)
endif()

if (DEPENDS_PREFIX STREQUAL "x86_64-w64-mingw32")
  set(_windows_configuration -DLEVELDB_PLATFORM_NAME=LEVELDB_PLATFORM_WINDOWS -DCMAKE_CROSSCOMPILING=1 -DRUN_HAVE_STD_REGEX=0  -DRUN_HAVE_POSIX_REGEX=0 -DWIN32=ON -DLEVELDB_BUILD_TESTS=OFF -DLEVELDB_BUILD_BENCHMARKS=OFF)
endif()

set(prefix "${CMAKE_BINARY_DIR}/deps")
set(LEVELDB_LIBRARY "${prefix}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}leveldb${CMAKE_STATIC_LIBRARY_SUFFIX}")
set(LEVELDB_INCLUDE_DIR "${prefix}/include")

ExternalProject_Add(
  leveldb
  PREFIX "${prefix}"
  GIT_REPOSITORY https://github.com/itamarcps/leveldb
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
             -DCMAKE_POSITION_INDEPENDENT_CODE=${BUILD_SHARED_LIBS}
             -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
             -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
             -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
             ${_only_release_configuration}
             ${_windows_configuration}
             -DCMAKE_INSTALL_LIBDIR=lib
  LOG_CONFIGURE 1
  BUILD_COMMAND ""
  ${_overwrite_install_command}
  LOG_INSTALL 1
  BUILD_BYPRODUCTS "${LEVELDB_BYPRODUCTS}"
  DEPENDS snappy
)

# Create imported library
add_library(LevelDB STATIC IMPORTED)
file(MAKE_DIRECTORY "${LEVELDB_INCLUDE_DIR}")  # Must exist.
set_property(TARGET LevelDB PROPERTY IMPORTED_CONFIGURATIONS Release)
set_property(TARGET LevelDB PROPERTY IMPORTED_LOCATION_RELEASE "${LEVELDB_LIBRARY}")
set_property(TARGET LevelDB PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${LEVELDB_INCLUDE_DIR}")
add_dependencies(LevelDB leveldb snappy ${LEVELDB_BYPRODUCTS})
