# avme-wallet

Official ETH/TAEX wallet for the AVME Project.

## Compiling

### Dependencies

* **CMake 3.9.3** or higher (if on Windows, get the **latest** version - at least 3.19.2 will do)
* The **GNU GCC Toolchain** (Linux) or the **MSVC Toolchain** (Windows - get it [here](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2019))

### Instructions

Open a terminal at project root and do the following:

```
mkdir build && cd build
cmake ..
For Linux/GCC: cmake --build .
For Windows/MSVC: cmake --build . -- /p:Configuration=Release
```

Executable should be in `build` (Linux) or `build/Release` (Windows).

