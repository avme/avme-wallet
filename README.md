# avme-wallet

Official wallet for the AVME Project.

## Compiling

### Dependencies

* **CMake 3.19.0** or higher
* **GCC** (native Linux) *or* **MinGW** (cross-compile from Linux to Windows) with support for **C++14** or higher
* **Build deps for Qt 5.15.2** or higher (see the [Qt docs](https://wiki.qt.io/Building_Qt_5_from_Git) for more info)
* Required packages for Bitcoin Core's depends system (see [depends/README.md](depends/README.md) for more info)
* For compiling LevelDB: **libsnappy**
* For compiling Qt: **libdouble-conversion-dev**, **libkrb5-dev** and **libvulkan**

Handy one-liner for **Debian 9 Stretch or newer**:
* `sudo apt-get build-dep qtbase5-dev && sudo apt-get install build-essential make automake cmake curl g++-multilib mingw-w64 libtool binutils bsdmainutils pkg-config python3 patch bison gperf libdouble-conversion-dev libxcb-xinerama0-dev libkrb5-dev libsnappy-dev libvulkan-dev`

### Known caveats

* **Debian 11 Bullseye and older**: CMake is too old and has to be installed manually from [their website](https://cmake.org/download)

### Instructions

* Clone the project: `git clone https://github.com/avme/avme-wallet`
* Go to the project's root folder, create a "build" folder and change to it:
  * `cd avme-wallet && mkdir build && cd build`
* **If cross-compiling with MinGW**, set both gcc and g++ to *POSIX* instead of *Win32*:
  * `sudo update-alternatives --config x86_64-w64-mingw32-gcc`
  * `sudo update-alternatives --config x86_64-w64-mingw32-g++`
  * Choose the `-posix` option for both
* Compile the depends system:
  * If using **GCC**: `make -C ../depends -j$(nproc)`
  * If using **MinGW**: `make HOST=x86_64-w64-mingw32 -C ../depends -j$(nproc)`
* Run `cmake` inside the build folder:
  * If using **GCC**: `cmake -DCMAKE_BUILD_TYPE=Release ..`
  * If using **MinGW**: `cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=cmake/x86_64-w64-mingw32.cmake ..`
  * If using **MacOS**: `cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=cmake/x86_64-apple-darwin20.cmake ..`
  * Use `-DCMAKE_BUILD_TYPE=RelWithDebInfo` to build with debug symbols
* Build the executable:
  * `cmake --build . -- -j$(nproc)`

## License

Copyright (c) 2020-2021 AVME Developers
Distributed under the MIT/X11 software license.
See the accompanying [LICENSE](LICENSE) file or http://www.opensource.org/licenses/mit-license.php.
