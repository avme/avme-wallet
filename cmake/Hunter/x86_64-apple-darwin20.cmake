# Sample toolchain file for building for Darwin inside Darwin system
#

set(CMAKE_SYSTEM_NAME Darwin)
set(TOOLCHAIN_PREFIX x86_64-apple-darwin20)
set(HOMEBREW_GCC_PATH /usr/local/Cellar/gcc/10.2.0_4/bin/)

# cross compilers to use for C, C++ and Fortran
set(CMAKE_C_COMPILER ${HOMEBREW_GCC_PATH}${TOOLCHAIN_PREFIX}-gcc-10)
set(CMAKE_CXX_COMPILER ${HOMEBREW_GCC_PATH}${TOOLCHAIN_PREFIX}-g++-10)
set(CMAKE_Fortran_COMPILER ${HOMEBREW_GCC_PATH}${TOOLCHAIN_PREFIX}-gfortran-10)

# target environment on the build host system
set(CMAKE_FIND_ROOT_PATH /usr/lib)

# modify default behavior of FIND_XXX() commands
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
