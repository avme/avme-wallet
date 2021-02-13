# avme-wallet

Official wallet for the AVME Project.

## Compiling

### Dependencies

* **CMake 3.19.0** or higher
* **GCC** (native Linux) *or* **MinGW** (cross-compile from Linux to Windows)
* **Build deps for Qt 5.9.8** or higher (see [Qt docs](https://wiki.qt.io/Building_Qt_5_from_Git) for more info)
* Required packages for Bitcoin Core's depends system (see [depends/README.md](depends/README.md) for more info)

Example steps for APT-based distros:
* `sudo apt-get build-dep qt5-default`
* `sudo apt-get install build-essential mingw-w64 make automake autotools-dev cmake curl g++-multilib libtool binutils-gold bsdmainutils pkg-config python3 patch libxcb-xinerama0-dev`

### Instructions

First, clone the project with `git clone --recurse-submodules` (or, if you've already cloned it, do a `git submodule update --init external/openssl-cmake`).

Then, open a terminal at project root and do the following:

```
mkdir build && cd build

[For GCC]
make -C ../depends -j$(nproc)
cmake ..

[For MinGW]
make HOST=x86_64-w64-mingw32 -C ../depends -j$(nproc)
cmake -DCMAKE_TOOLCHAIN_FILE=cmake/x86_64-w64-mingw32.cmake ..

cmake --build .
```

