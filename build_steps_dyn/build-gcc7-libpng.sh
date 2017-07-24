#!/bin/bash
set -e

source /hbb_build/build-gcc7-common.sh
source /hbb_build/build-gcc7-common2.sh

#########################

PKG_VERSION=1.6.28
PKG_NAME=libpng
PKG_TITLE=libpng
PKG_SOURCE=http://downloads.sourceforge.net/libpng/libpng-$PKG_VERSION.tar.xz
PKG_SOURCE2=http://downloads.sourceforge.net/project/apng/libpng/libpng16/libpng-1.6.28-apng.patch.gz

function install_pkg()
{
	local VARIANT="$1"
	local PREFIX="/hbb_$VARIANT"

	header "Installing $PKG_TITLE $PKG_VERSION libraries: $VARIANT"

	local _BASENAME=$PKG_NAME-$PKG_VERSION.tar.xz
	local _DIRNAME=$PKG_NAME-$PKG_VERSION
	run rm -f "/tmp/$_BASENAME.tmp"
	run curl --fail -L -o "/tmp/$_BASENAME.tmp" "$PKG_SOURCE"
	run mv "/tmp/$_BASENAME.tmp" "/tmp/$_BASENAME"
	run tar xJf "/tmp/$_BASENAME"
	echo "Entering $_DIRNAME"
	pushd $_DIRNAME

	#wget -c $PKG_SOURCE2
	run curl --fail -L -o libpng-1.6.28-apng.patch.gz $PKG_SOURCE2

	(
		source "$PREFIX/activate"
		export CFLAGS="$SHLIB_CFLAGS"
		gzip -cd libpng-1.6.28-apng.patch.gz | patch -p0
		export LIBS="-lpthread"
		run ./configure --prefix=$PREFIX --disable-static --enable-shared
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
