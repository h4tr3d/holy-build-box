#!/bin/bash
set -e

source /hbb_build/build-gcc7-common.sh
source /hbb_build/build-gcc7-common2.sh

#########################

PKG_VERSION=2.12.1
PKG_NAME=fontconfig
PKG_TITLE=Fontconfig
PKG_SOURCE=http://www.freedesktop.org/software/fontconfig/release/fontconfig-$PKG_VERSION.tar.bz2

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
		run sed -e '/FC_CHAR_WIDTH/s/CHAR_WIDTH/CHARWIDTH/'             \
                        -e '/FC_CHARWIDTH/a #define FC_CHAR_WIDTH FC_CHARWIDTH' \
                        -i fontconfig/fontconfig.h
                run sed 's/CHAR_WIDTH/CHARWIDTH/' -i src/fcobjs.h
                # Hack for libtool to pass linkage fails
                #export LIBS="$PREFIX/lib/libfreetype.a  $PREFIX/lib/libharfbuzz.a $PREFIX/lib/libpng16.a -lbz2 -lz"
		run ./configure --prefix=$PREFIX --disable-static --enable-shared --disable-docs
		run make V=1 -j$MAKE_CONCURRENCY
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
