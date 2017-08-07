#!/bin/bash
set -e

source /hbb_build/build-gcc7-common.sh
source /hbb_build/build-gcc7-common2.sh

#########################

PKG_VERSION=3.2.2
PKG_NAME=eudev
PKG_TITLE=eudev
PKG_SOURCE=https://github.com/gentoo/eudev/archive/v3.2.2.tar.gz

function install_pkg()
{
	local VARIANT="$1"
	local PREFIX="/hbb_$VARIANT"

	header "Installing $PKG_TITLE $PKG_VERSION libraries: $VARIANT"
	download_and_extract $PKG_NAME-$PKG_VERSION.tar.gz \
		$PKG_NAME-$PKG_VERSION \
		$PKG_SOURCE

	(
		source "$PREFIX/activate"
		export CFLAGS="$SHLIB_CFLAGS"
		sed -r -i 's|/usr(/bin/test)|\1|' test/udev-test.pl
		sed -i '/keyboard_lookup_key/d' src/udev/udev-builtin-keyboard.c
		cat > config.cache << "EOF"
HAVE_BLKID=1
BLKID_LIBS="-lblkid"
BLKID_CFLAGS="-I/tools/include"
EOF
                #run mv /hbb/bin/pkg-config /hbb/bin/pkg-config.off || true
                #ln -s /hbb/share/aclocal/pkg.m4 /opt/rh/autotools-latest/root/usr/share/aclocal/
                export ACLOCAL_PATH=/hbb/share/aclocal:/opt/rh/autotools-latest/root/usr/share/aclocal
                run autoreconf -f -i -s
                #run ./autogen.sh
		run ./configure \
		    --prefix=$PREFIX \
		    --with-rootprefix=/usr \
		    --with-rootlibdir=/lib \
		    --sysconfdir=/etc \
		    --enable-split-usr \
		    --disable-kmod \
		    --disable-manpages \
		    --disable-static
		run make -j$MAKE_CONCURRENCY
		# install only libraries
		run make -C src/libudev install
	)
	if [[ "$?" != 0 ]]; then false; fi

	echo "Leaving source directory"
	popd >/dev/null
	run rm -rf $PKG_NAME-$PKG_VERSION
}

for VARIANT in $VARIANTS; do
	install_pkg $VARIANT
done
