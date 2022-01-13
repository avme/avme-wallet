package=fontconfig
$(package)_version=2.13.94
$(package)_download_path=https://www.freedesktop.org/software/fontconfig/release/
$(package)_file_name=$(package)-$($(package)_version).tar.xz
$(package)_sha256_hash=a5f052cb73fd479ffb7b697980510903b563bbb55b8f7a2b001fcfb94026003c
$(package)_dependencies=freetype expat

define $(package)_set_vars
  $(package)_config_opts=--disable-docs --enable-static --disable-libxml2 --disable-iconv
  $(package)_config_opts += --disable-dependency-tracking --enable-option-checking
endef

define $(package)_config_cmds
  $($(package)_autoconf)
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
