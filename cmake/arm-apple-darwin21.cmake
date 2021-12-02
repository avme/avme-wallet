# Sample toolchain file for building for Darwin inside Darwin system
#

set(CMAKE_SYSTEM_NAME Darwin)
set(TOOLCHAIN_PREFIX arm-apple-darwin21.1.0)

# cross compilers to use for C, C++ and Fortran
set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)
#set(CMAKE_Fortran_COMPILER ${HOMEBREW_GCC_PATH}${TOOLCHAIN_PREFIX}-gfortran-10)

# target environment on the build host system
set(CMAKE_FIND_ROOT_PATH /usr/lib/)

# modify default behavior of FIND_XXX() commands
#set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
#set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
#set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
