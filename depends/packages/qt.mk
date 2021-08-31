PACKAGE=qt
$(package)_version=5.15.2
$(package)_download_path=https://download.qt.io/official_releases/qt/5.15/$($(package)_version)/submodules
$(package)_suffix=everywhere-src-$($(package)_version).tar.xz
$(package)_file_name=qtbase-$($(package)_suffix)
$(package)_sha256_hash=909fad2591ee367993a75d7e2ea50ad4db332f05e1c38dd7a5a274e156a4e0f8
$(package)_dependencies=zlib openssl
$(package)_linux_dependencies=freetype fontconfig libxcb libxkbcommon libxcb_util libxcb_util_render libxcb_util_keysyms libxcb_util_image libxcb_util_wm
$(package)_qt_libs=corelib concurrent network widgets gui plugins testlib qlalr
$(package)_patches=fix_qt_pkgconfig.patch mac-qmake.conf fix_no_printer.patch no-xlib.patch
$(package)_patches+= fix_android_jni_static.patch dont_hardcode_pwd.patch
$(package)_patches+= drop_lrelease_dependency.patch fix_qpainter_non_determinism.patch
$(package)_patches+= no_sdk_version_check.patch fix_limits_header.patch openssl-qt-crosscompile.patch

$(package)_qttranslations_file_name=qttranslations-$($(package)_suffix)
$(package)_qttranslations_sha256_hash=d5788e86257b21d5323f1efd94376a213e091d1e5e03b45a95dd052b5f570db8

$(package)_qttools_file_name=qttools-$($(package)_suffix)
$(package)_qttools_sha256_hash=c189d0ce1ff7c739db9a3ace52ac3e24cb8fd6dbf234e49f075249b38f43c1cc

$(package)_qtdeclarative_file_name=qtdeclarative-$($(package)_suffix)
$(package)_qtdeclarative_sha256_hash=c600d09716940f75d684f61c5bdaced797f623a86db1627da599027f6c635651

$(package)_qtquickcontrols2_file_name=qtquickcontrols2-$($(package)_suffix)
$(package)_qtquickcontrols2_sha256_hash=671b6ce5f4b8ecc94db622d5d5fb29ef4ff92819be08e5ea55bfcab579de8919

$(package)_qtcharts_file_name=qtcharts-$($(package)_suffix)
$(package)_qtcharts_sha256_hash=e0750e4195bd8a8b9758ab4d98d437edbe273cd3d289dd6a8f325df6d13f3d11

$(package)_extra_sources  = $($(package)_qttranslations_file_name)
$(package)_extra_sources += $($(package)_qttools_file_name)
$(package)_extra_sources += $($(package)_qtdeclarative_file_name)
$(package)_extra_sources += $($(package)_qtquickcontrols2_file_name)
$(package)_extra_sources += $($(package)_qtcharts_file_name)

define $(package)_set_vars
$(package)_config_opts_release = -release
$(package)_config_opts_release += -silent
$(package)_config_opts_debug = -debug
$(package)_config_opts_debug += -optimized-tools
$(package)_config_opts += -bindir $(build_prefix)/bin
$(package)_config_opts += -c++std c++17
$(package)_config_opts += -confirm-license
$(package)_config_opts += -hostprefix $(build_prefix)
$(package)_config_opts += -no-compile-examples
$(package)_config_opts += -no-cups
$(package)_config_opts += -no-egl
$(package)_config_opts += -no-eglfs
$(package)_config_opts += -no-evdev
$(package)_config_opts += -no-freetype
$(package)_config_opts += -no-glib
$(package)_config_opts += -no-icu
$(package)_config_opts += -no-ico
$(package)_config_opts += -no-iconv
$(package)_config_opts += -no-kms
$(package)_config_opts += -no-linuxfb
$(package)_config_opts += -no-libjpeg
$(package)_config_opts += -no-libproxy
$(package)_config_opts += -no-libudev
$(package)_config_opts += -no-mtdev
$(package)_config_opts += -no-openvg
$(package)_config_opts += -no-reduce-relocations
$(package)_config_opts += -no-schannel
$(package)_config_opts += -no-sctp
$(package)_config_opts += -no-securetransport
$(package)_config_opts += -no-sql-db2
$(package)_config_opts += -no-sql-ibase
$(package)_config_opts += -no-sql-oci
$(package)_config_opts += -no-sql-tds
$(package)_config_opts += -no-sql-mysql
$(package)_config_opts += -no-sql-odbc
$(package)_config_opts += -no-sql-psql
$(package)_config_opts += -no-sql-sqlite
$(package)_config_opts += -no-sql-sqlite2
$(package)_config_opts += -no-system-proxies
$(package)_config_opts += -no-use-gold-linker
$(package)_config_opts += -no-zstd
$(package)_config_opts += -nomake examples
$(package)_config_opts += -nomake tests
$(package)_config_opts += -opensource
$(package)_config_opts += -pkg-config
$(package)_config_opts += -prefix $(host_prefix)
$(package)_config_opts += -gif
$(package)_config_opts += -qt-libpng
$(package)_config_opts += -qt-pcre
$(package)_config_opts += -qt-harfbuzz
$(package)_config_opts += -system-zlib
$(package)_config_opts += -static
$(package)_config_opts += -v
$(package)_config_opts += -no-feature-bearermanagement
$(package)_config_opts += -no-feature-colordialog
$(package)_config_opts += -feature-commandlineparser
$(package)_config_opts += -feature-concurrent
$(package)_config_opts += -no-feature-dial
$(package)_config_opts += -no-feature-fontcombobox
$(package)_config_opts += -no-feature-ftp
$(package)_config_opts += -no-feature-image_heuristic_mask
$(package)_config_opts += -no-feature-keysequenceedit
$(package)_config_opts += -no-feature-lcdnumber
$(package)_config_opts += -no-feature-pdf
$(package)_config_opts += -no-feature-printdialog
$(package)_config_opts += -no-feature-printer
$(package)_config_opts += -no-feature-printpreviewdialog
$(package)_config_opts += -no-feature-printpreviewwidget
$(package)_config_opts += -no-feature-sessionmanager
$(package)_config_opts += -no-feature-socks5
$(package)_config_opts += -no-feature-sql
$(package)_config_opts += -no-feature-sqlmodel
$(package)_config_opts += -no-feature-statemachine
$(package)_config_opts += -no-feature-syntaxhighlighter
$(package)_config_opts += -no-feature-textbrowser
$(package)_config_opts += -no-feature-textmarkdownwriter
$(package)_config_opts += -no-feature-textodfwriter
$(package)_config_opts += -no-feature-topleveldomain
$(package)_config_opts += -no-feature-udpsocket
$(package)_config_opts += -no-feature-undocommand
$(package)_config_opts += -no-feature-undogroup
$(package)_config_opts += -no-feature-undostack
$(package)_config_opts += -no-feature-undoview
$(package)_config_opts += -no-feature-vnc
$(package)_config_opts += -no-feature-wizard
$(package)_config_opts += -no-feature-xml

$(package)_config_opts_darwin = -no-dbus
$(package)_config_opts_darwin += -no-opengl
$(package)_config_opts_darwin += -pch
$(package)_config_opts_darwin += -device-option QMAKE_MACOSX_DEPLOYMENT_TARGET=$(OSX_MIN_VERSION)
$(package)_config_opts_darwin += -openssl-linked
$(package)_config_opts_darwin += -L $(host_prefix)/lib
$(package)_config_opts_darwin += -I $(host_prefix)/include

ifneq ($(build_os),darwin)
$(package)_config_opts_darwin += -xplatform macx-clang-linux
$(package)_config_opts_darwin += -device-option MAC_SDK_PATH=$(OSX_SDK)
$(package)_config_opts_darwin += -device-option MAC_SDK_VERSION=$(OSX_SDK_VERSION)
$(package)_config_opts_darwin += -device-option CROSS_COMPILE="$(host)-"
$(package)_config_opts_darwin += -device-option MAC_MIN_VERSION=$(OSX_MIN_VERSION)
$(package)_config_opts_darwin += -device-option MAC_TARGET=$(host)
$(package)_config_opts_darwin += -device-option XCODE_VERSION=$(XCODE_VERSION)
$(package)_config_opts_darwin += -openssl-linked
$(package)_config_opts_darwin += -L $(host_prefix)/lib
$(package)_config_opts_darwin += -I $(host_prefix)/include
endif

# for macOS on Apple Silicon (ARM) see https://bugreports.qt.io/browse/QTBUG-85279
$(package)_config_opts_arm_darwin += -device-option QMAKE_APPLE_DEVICE_ARCHS=arm64

$(package)_config_opts_linux = -xcb
$(package)_config_opts_linux += -no-xcb-xlib
$(package)_config_opts_linux += -no-feature-xlib
$(package)_config_opts_linux += -system-freetype
$(package)_config_opts_linux += -fontconfig
$(package)_config_opts_linux += -no-opengl
$(package)_config_opts_linux += -dbus-runtime
$(package)_config_opts_arm_linux += -platform linux-g++ -xplatform bitcoin-linux-g++
$(package)_config_opts_i686_linux  = -xplatform linux-g++-32
$(package)_config_opts_x86_64_linux = -xplatform linux-g++-64
$(package)_config_opts_aarch64_linux = -xplatform linux-aarch64-gnu-g++
$(package)_config_opts_powerpc64_linux = -platform linux-g++ -xplatform bitcoin-linux-g++
$(package)_config_opts_powerpc64le_linux = -platform linux-g++ -xplatform bitcoin-linux-g++
$(package)_config_opts_riscv64_linux = -platform linux-g++ -xplatform bitcoin-linux-g++
$(package)_config_opts_s390x_linux = -platform linux-g++ -xplatform bitcoin-linux-g++

$(package)_config_opts_mingw32 = -no-opengl
$(package)_config_opts_mingw32 += -no-dbus
$(package)_config_opts_mingw32 += -xplatform win32-g++
$(package)_config_opts_mingw32 += -device-option CROSS_COMPILE="$(host)-"
$(package)_config_opts_mingw32 += -pch
$(package)_config_opts_mingw32 += -openssl-linked
$(package)_config_opts_mingw32 += -static-runtime
$(package)_config_opts_mingw32 += -L $(host_prefix)/lib
$(package)_config_opts_mingw32 += -I $(host_prefix)/include

$(package)_config_opts_android = -xplatform android-clang
$(package)_config_opts_android += -android-sdk $(ANDROID_SDK)
$(package)_config_opts_android += -android-ndk $(ANDROID_NDK)
$(package)_config_opts_android += -android-ndk-platform android-$(ANDROID_API_LEVEL)
$(package)_config_opts_android += -device-option CROSS_COMPILE="$(host)-"
$(package)_config_opts_android += -egl
$(package)_config_opts_android += -qpa xcb
$(package)_config_opts_android += -no-eglfs
$(package)_config_opts_android += -no-dbus
$(package)_config_opts_android += -opengl es2
$(package)_config_opts_android += -qt-freetype
$(package)_config_opts_android += -no-fontconfig
$(package)_config_opts_android += -L $(host_prefix)/lib
$(package)_config_opts_android += -I $(host_prefix)/include
$(package)_config_opts_android += -pch

$(package)_config_opts_aarch64_android += -android-arch arm64-v8a
$(package)_config_opts_armv7a_android += -android-arch armeabi-v7a
$(package)_config_opts_x86_64_android += -android-arch x86_64
$(package)_config_opts_i686_android += -android-arch i686

$(package)_build_env  = QT_RCC_TEST=1
$(package)_build_env += QT_RCC_SOURCE_DATE_OVERRIDE=1
endef

define $(package)_fetch_cmds
$(call fetch_file,$(package),$($(package)_download_path),$($(package)_download_file),$($(package)_file_name),$($(package)_sha256_hash)) && \
$(call fetch_file,$(package),$($(package)_download_path),$($(package)_qttranslations_file_name),$($(package)_qttranslations_file_name),$($(package)_qttranslations_sha256_hash)) && \
$(call fetch_file,$(package),$($(package)_download_path),$($(package)_qttools_file_name),$($(package)_qttools_file_name),$($(package)_qttools_sha256_hash)) && \
$(call fetch_file,$(package),$($(package)_download_path),$($(package)_qtdeclarative_file_name),$($(package)_qtdeclarative_file_name),$($(package)_qtdeclarative_sha256_hash)) && \
$(call fetch_file,$(package),$($(package)_download_path),$($(package)_qtquickcontrols2_file_name),$($(package)_qtquickcontrols2_file_name),$($(package)_qtquickcontrols2_sha256_hash)) && \
$(call fetch_file,$(package),$($(package)_download_path),$($(package)_qtcharts_file_name),$($(package)_qtcharts_file_name),$($(package)_qtcharts_sha256_hash))
endef

define $(package)_extract_cmds
  mkdir -p $($(package)_extract_dir) && \
  echo "$($(package)_sha256_hash)  $($(package)_source)" > $($(package)_extract_dir)/.$($(package)_file_name).hash && \
  echo "$($(package)_qttranslations_sha256_hash)  $($(package)_source_dir)/$($(package)_qttranslations_file_name)" >> $($(package)_extract_dir)/.$($(package)_file_name).hash && \
  echo "$($(package)_qttools_sha256_hash)  $($(package)_source_dir)/$($(package)_qttools_file_name)" >> $($(package)_extract_dir)/.$($(package)_file_name).hash && \
  echo "$($(package)_qtdeclarative_sha256_hash)  $($(package)_source_dir)/$($(package)_qtdeclarative_file_name)" >> $($(package)_extract_dir)/.$($(package)_file_name).hash && \
  echo "$($(package)_qtquickcontrols2_sha256_hash)  $($(package)_source_dir)/$($(package)_qtquickcontrols2_file_name)" >> $($(package)_extract_dir)/.$($(package)_file_name).hash && \
  echo "$($(package)_qtcharts_sha256_hash)  $($(package)_source_dir)/$($(package)_qtcharts_file_name)" >> $($(package)_extract_dir)/.$($(package)_file_name).hash && \
  $(build_SHA256SUM) -c $($(package)_extract_dir)/.$($(package)_file_name).hash && \
  mkdir qtbase && \
  tar --no-same-owner --strip-components=1 -xf $($(package)_source) -C qtbase && \
  mkdir qttranslations && \
  tar --no-same-owner --strip-components=1 -xf $($(package)_source_dir)/$($(package)_qttranslations_file_name) -C qttranslations && \
  mkdir qttools && \
  tar --no-same-owner --strip-components=1 -xf $($(package)_source_dir)/$($(package)_qttools_file_name) -C qttools && \
  mkdir qtdeclarative && \
  tar --no-same-owner --strip-components=1 -xf $($(package)_source_dir)/$($(package)_qtdeclarative_file_name) -C qtdeclarative && \
  mkdir qtquickcontrols2 && \
  tar --no-same-owner --strip-components=1 -xf $($(package)_source_dir)/$($(package)_qtquickcontrols2_file_name) -C qtquickcontrols2 && \
  mkdir qtcharts && \
  tar --no-same-owner --strip-components=1 -xf $($(package)_source_dir)/$($(package)_qtcharts_file_name) -C qtcharts
endef

# Preprocessing steps work as follows:
#
# 1. Apply our patches to the extracted source. See each patch for more info.
#
# 2. Point to lrelease in qttools/bin/lrelease; otherwise Qt will look for it in
# $(host)/native/bin/lrelease and not find it.
#
# 3. Create a macOS-Clang-Linux mkspec using our mac-qmake.conf.
#
# 4. After making a copy of the mkspec for the linux-arm-gnueabi host, named
# bitcoin-linux-g++, replace instances of linux-arm-gnueabi with $(host). This
# way we can generically support hosts like riscv64-linux-gnu, which Qt doesn't
# ship a mkspec for. See it's usage in config_opts_* above.
#
# 5. Put our C, CXX and LD FLAGS into gcc-base.conf. Only used for non-host builds.
#
# 6. Do similar for the win32-g++ mkspec.
#
# 7. In clang.conf, swap out clang & clang++, for our compiler + flags. See #17466.
#
# 8. Adjust a regex in toolchain.prf, to accommodate Guix's usage of
# CROSS_LIBRARY_PATH. See #15277.
define $(package)_preprocess_cmds
  patch -p1 -i $($(package)_patch_dir)/drop_lrelease_dependency.patch && \
  patch -p1 -i $($(package)_patch_dir)/dont_hardcode_pwd.patch && \
  patch -p1 -i $($(package)_patch_dir)/fix_qt_pkgconfig.patch && \
  patch -p1 -i $($(package)_patch_dir)/fix_no_printer.patch && \
  patch -p1 -i $($(package)_patch_dir)/fix_android_jni_static.patch && \
  patch -p1 -i $($(package)_patch_dir)/no-xlib.patch && \
  patch -p1 -i $($(package)_patch_dir)/fix_qpainter_non_determinism.patch && \
  patch -p1 -i $($(package)_patch_dir)/no_sdk_version_check.patch && \
  patch -p1 -i $($(package)_patch_dir)/fix_limits_header.patch && \
  patch -p1 -i $($(package)_patch_dir)/openssl-qt-crosscompile.patch && \
  sed -i.old "s|updateqm.commands = \$$$$\$$$$LRELEASE|updateqm.commands = $($(package)_extract_dir)/qttools/bin/lrelease|" qttranslations/translations/translations.pro && \
  mkdir -p qtbase/mkspecs/macx-clang-linux &&\
  cp -f qtbase/mkspecs/macx-clang/qplatformdefs.h qtbase/mkspecs/macx-clang-linux/ &&\
  cp -f $($(package)_patch_dir)/mac-qmake.conf qtbase/mkspecs/macx-clang-linux/qmake.conf && \
  cp -r qtbase/mkspecs/linux-arm-gnueabi-g++ qtbase/mkspecs/bitcoin-linux-g++ && \
  sed -i.old "s/arm-linux-gnueabi-/$(host)-/g" qtbase/mkspecs/bitcoin-linux-g++/qmake.conf && \
  echo "!host_build: QMAKE_CFLAGS     += $($(package)_cflags) $($(package)_cppflags)" >> qtbase/mkspecs/common/gcc-base.conf && \
  echo "!host_build: QMAKE_CXXFLAGS   += $($(package)_cxxflags) $($(package)_cppflags)" >> qtbase/mkspecs/common/gcc-base.conf && \
  echo "!host_build: QMAKE_LFLAGS     += $($(package)_ldflags)" >> qtbase/mkspecs/common/gcc-base.conf && \
  sed -i.old "s|QMAKE_CFLAGS           += |!host_build: QMAKE_CFLAGS            = $($(package)_cflags) $($(package)_cppflags) |" qtbase/mkspecs/win32-g++/qmake.conf && \
  sed -i.old "s|QMAKE_CXXFLAGS         += |!host_build: QMAKE_CXXFLAGS            = $($(package)_cxxflags) $($(package)_cppflags) |" qtbase/mkspecs/win32-g++/qmake.conf && \
  sed -i.old "0,/^QMAKE_LFLAGS_/s|^QMAKE_LFLAGS_|!host_build: QMAKE_LFLAGS            = $($(package)_ldflags)\n&|" qtbase/mkspecs/win32-g++/qmake.conf && \
  sed -i.old "s|QMAKE_CC                = \$$$$\$$$${CROSS_COMPILE}clang|QMAKE_CC                = $($(package)_cc)|" qtbase/mkspecs/common/clang.conf && \
  sed -i.old "s|QMAKE_CXX               = \$$$$\$$$${CROSS_COMPILE}clang++|QMAKE_CXX               = $($(package)_cxx)|" qtbase/mkspecs/common/clang.conf && \
  sed -i.old "s/LIBRARY_PATH/(CROSS_)?\0/g" qtbase/mkspecs/features/toolchain.prf
endef

# qtquickcontrols2 can't be compiled along with qtdeclarative because we need
# its mkspecs folder to properly compile it.
# we copy that folder there so it can detect the quick module - this is why
# qtquickcontrols2 is configured at build_cmds and not here.
# same thing with qtcharts and qtquickcontrols2, apparently.
# don't ask me why, that's how qt works when not doing it the way they want you
# to do it and it's absolutely *bonkers* :(
define $(package)_config_cmds
  export PKG_CONFIG_SYSROOT_DIR=/ && \
  export PKG_CONFIG_LIBDIR=$(host_prefix)/lib/pkgconfig && \
  export PKG_CONFIG_PATH=$(host_prefix)/share/pkgconfig  && \
  cd qtbase && \
  ./configure $($(package)_config_opts) && \
  echo "host_build: QT_CONFIG ~= s/system-zlib/zlib" >> mkspecs/qconfig.pri && \
  echo "CONFIG += force_bootstrap" >> mkspecs/qconfig.pri && \
  cd .. && \
  $(MAKE) -C qtbase sub-src-clean && \
  qtbase/bin/qmake -o qttranslations/Makefile qttranslations/qttranslations.pro && \
  qtbase/bin/qmake -o qttranslations/translations/Makefile qttranslations/translations/translations.pro && \
  qtbase/bin/qmake -o qttools/src/linguist/lrelease/Makefile qttools/src/linguist/lrelease/lrelease.pro && \
  qtbase/bin/qmake -o qttools/src/linguist/lupdate/Makefile qttools/src/linguist/lupdate/lupdate.pro && \
	qtbase/bin/qmake -o qtdeclarative/Makefile qtdeclarative/qtdeclarative.pro
endef

define $(package)_build_cmds
  $(MAKE) -C qtbase/src $(addprefix sub-,$($(package)_qt_libs)) && \
  $(MAKE) -C qttools/src/linguist/lrelease && \
  $(MAKE) -C qttools/src/linguist/lupdate && \
  $(MAKE) -C qttranslations && \
  $(MAKE) -C qtdeclarative && \
  cp -r qtdeclarative/mkspecs qtquickcontrols2/mkspecs && \
	qtbase/bin/qmake -o qtquickcontrols2/Makefile qtquickcontrols2/qtquickcontrols2.pro && \
  $(MAKE) -C qtquickcontrols2 && \
	cp -r qtquickcontrols2/mkspecs qtcharts/mkspecs && \
	qtbase/bin/qmake -o qtcharts/Makefile qtcharts/qtcharts.pro && \
	$(MAKE) -C qtcharts
endef

define $(package)_stage_cmds
  $(MAKE) -C qtbase/src INSTALL_ROOT=$($(package)_staging_dir) $(addsuffix -install_subtargets,$(addprefix sub-,$($(package)_qt_libs))) && \
  $(MAKE) -C qttools/src/linguist/lrelease INSTALL_ROOT=$($(package)_staging_dir) install_target && \
  $(MAKE) -C qttools/src/linguist/lupdate INSTALL_ROOT=$($(package)_staging_dir) install_target && \
  $(MAKE) -C qttranslations INSTALL_ROOT=$($(package)_staging_dir) install_subtargets && \
  $(MAKE) -C qtdeclarative INSTALL_ROOT=$($(package)_staging_dir) install_subtargets && \
  $(MAKE) -C qtquickcontrols2 INSTALL_ROOT=$($(package)_staging_dir) install_subtargets && \
  $(MAKE) -C qtcharts INSTALL_ROOT=$($(package)_staging_dir) install_subtargets
endef

define $(package)_postprocess_cmds
  rm -rf native/mkspecs/ native/lib/ lib/cmake/ && \
  rm -f lib/lib*.la lib/*.prl plugins/*/*.prl
endef
