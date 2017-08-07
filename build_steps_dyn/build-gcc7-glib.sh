#!/bin/bash
set -e

source /hbb_build/build-gcc7-common.sh
source /hbb_build/build-gcc7-common2.sh

#########################

PKG_VERSION=2.50.3
_PKG_MAJOR=2.50
PKG_NAME=glib
PKG_TITLE=Glib
PKG_SOURCE=http://ftp.gnome.org/pub/gnome/sources/glib/${_PKG_MAJOR}/glib-$PKG_VERSION.tar.xz

function install_pkg()
{
	local VARIANT="$1"
	local PREFIX="/hbb_$VARIANT"

	header "Installing $PKG_TITLE $PKG_VERSION libraries: $VARIANT"
	#download_and_extract $PKG_NAME-$PKG_VERSION.tar.xz \
	#	$PKG_NAME-$PKG_VERSION \
	#	$PKG_SOURCE
	
	local _BASENAME=$PKG_NAME-$PKG_VERSION.tar.xz
	local _DIRNAME=$PKG_NAME-$PKG_VERSION
	run rm -f "/tmp/$_BASENAME.tmp"
	run curl --fail -L -o "/tmp/$_BASENAME.tmp" "$PKG_SOURCE"
	run mv "/tmp/$_BASENAME.tmp" "/tmp/$_BASENAME"
	run tar xJf "/tmp/$_BASENAME"
	echo "Entering $_DIRNAME"
	pushd $_DIRNAME

	(
		source "$PREFIX/activate"
		export CFLAGS="$SHLIB_CFLAGS"
		run ./configure \
		    --prefix=$PREFIX \
		    --disable-static \
		    --enable-shared \
		    --with-pcre=system \
		    --disable-fam \
                    --disable-gtk-doc \
                    --disable-libmount
                run sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
		run make -j$MAKE_CONCURRENCY
		run make install
	)
	if [[ "$?" != 0 ]]; then false; fi

	echo "Leaving source directory"
	popd >/dev/null
	run rm -rf $PKG_NAME-$PKG_VERSION
}

for VARIANT in $VARIANTS; do
	install_pkg $VARIANT
done