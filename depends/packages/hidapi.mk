package=hidapi
$(package)_version=0.10.1
$(package)_download_path=https://github.com/libusb/hidapi/archive
$(package)_file_name=$(package)-$($(package)_version).tar.gz
$(package)_sha256_hash=f71dd8a1f46979c17ee521bc2117573872bbf040f8a4750e492271fc141f2644
$(package)_linux_dependencies=libusb eudev

define $(package)_set_vars
$(package)_config_opts=--enable-static --disable-shared
$(package)_config_opts+=--prefix=$(host_prefix)
$(package)_config_opts_darwin+=RANLIB="ranlib" AR="ar" CC="clang"
$(package)_config_opts_linux+=libudev_LIBS="-L$(host_prefix)/lib -ludev"
$(package)_config_opts_linux+=libudev_CFLAGS=-I$(host_prefix)/include
$(package)_config_opts_linux+=libusb_LIBS="-L$(host_prefix)/lib -lusb-1.0"
$(package)_config_opts_linux+=libusb_CFLAGS=-I$(host_prefix)/include/libusb-1.0
$(package)_config_opts_linux+=--with-pic
endef

define $(package)_config_cmds
  ./bootstrap &&\
  $($(package)_autoconf) $($(package)_config_opts)
endef

define $(package)_build_cmds
  $(MAKE)
endef

define $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) install
endef

define $(package)_postprocess_cmds
  rm lib/*.la
endef

