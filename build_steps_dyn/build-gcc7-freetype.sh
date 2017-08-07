#!/bin/bash
set -e

source /hbb_build/build-gcc7-common.sh
source /hbb_build/build-gcc7-common2.sh

#########################

PKG_VERSION=2.7.1
PKG_NAME=freetype
PKG_TITLE=FreeType
PKG_SOURCE=http://downloads.sourceforge.net/$PKG_NAME/$PKG_NAME-$PKG_VERSION.tar.bz2

function install_pkg()
{
	local VARIANT="$1"
	local PREFIX="/hbb_$VARIANT"

	header "Installing $PKG_TITLE $PKG_VERSION libraries: $VARIANT"
	download_and_extract $PKG_NAME-$PKG_VERSION.tar.bz2 \
		$PKG_NAME-$PKG_VERSION \
		$PKG_SOURCE

	(
		source "$PREFIX/activate"
		export CFLAGS="$SHLIB_CFLAGS"
		run sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg
		run sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" -i include/freetype/config/ftoption.h
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