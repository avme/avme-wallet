packages:=boost libevent

qt_packages = zlib

qrencode_packages = qrencode

hardware_packages := hidapi protobuf libusb
hardware_native_packages := native_protobuf

qt_linux_packages:=qt expat libxcb xcb_proto libXau xproto freetype fontconfig libxkbcommon libxcb_util libxcb_util_render libxcb_util_keysyms libxcb_util_image libxcb_util_wm eudev $(hardware_packages)
qt_android_packages=qt

qt_darwin_packages=qt $(hardware_packages)
qt_mingw32_packages=qt $(hardware_packages)

bdb_packages=bdb
sqlite_packages=sqlite

zmq_packages=zeromq

upnp_packages=miniupnpc
natpmp_packages=libnatpmp

multiprocess_packages = libmultiprocess capnp
multiprocess_native_packages = native_libmultiprocess native_capnp

darwin_native_packages = native_ds_store native_mac_alias

$(host_arch)_$(host_os)_native_packages += native_b2 $(hardware_native_packages)

ifneq ($(build_os),darwin)
darwin_native_packages += native_cctools native_libdmg-hfsplus
endif
