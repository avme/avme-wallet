# avme-wallet

Official wallet for the AVME Project.

## Compiling

### Dependencies

* **CMake 3.19.0** or higher
* **GCC** (native Linux) *or* **MinGW** (cross-compile from Linux to Windows) with support for **C++14** or higher
* **Build deps for Qt 5.15.2** or higher (see the [Qt docs](https://wiki.qt.io/Building_Qt_5_from_Git) for more info)
* Required packages for Bitcoin Core's depends system (see [depends/README.md](depends/README.md) for more info)

Example for APT-based distros:
* `sudo apt-get build-dep qt5-default`
* `sudo apt-get install bison build-essential mingw-w64 make automake autotools-dev cmake curl g++-multilib libdouble-conversion-dev libtool binutils-gold bsdmainutils pkg-config python3 patch libxcb-xinerama0-dev`

### Instructions

* Clone the project:
  * `git clone --recurse-submodules https://github.com/avme/avme-wallet`
  * If you've already cloned it, just update the submodules with `git submodule update --init external/openssl-cmake`
* Go to the project's root folder, create a "build" folder and change to it:
  * `cd avme-wallet && mkdir build && cd build`
* *If cross-compiling with MinGW*, make sure to set it to POSIX like so:
  * `sudo update-alternatives --config x86_64-w64-mingw32-g++`
  * Then, choose the option that ends with `-posix`
* Compile the depends system:
  * If using **GCC**: `make -C ../depends -j$(nproc)`
  * If using **MinGW**: `make HOST=x86_64-w64-mingw32 -C ../depends -j$(nproc)`
* Run `cmake` inside the build folder:
  * If building for **testnet**: `cmake -DTESTNET=ON ..`
  * If using **GCC**: `cmake -DCMAKE_BUILD_TYPE=Release ..`
  * If using **MinGW**: `cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=cmake/x86_64-w64-mingw32.cmake ..`
  * If using **MacOS**: `cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=cmake/x86_64-apple-darwin20.cmake ..`
  * Use `-DCMAKE_BUILD_TYPE=RelWithDebInfo` for debug symbols
* Build the executable:
  * `cmake --build . -- -j$(nproc)`

## License

Copyright (c) 2020-2021 AVME Developers
Distributed under the MIT/X11 software license.
See the accompanying [LICENSE](LICENSE) file or http://www.opensource.org/licenses/mit-license.php.
