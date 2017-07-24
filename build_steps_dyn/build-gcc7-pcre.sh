#!/bin/bash
set -e

source /hbb_build/build-gcc7-common.sh
source /hbb_build/build-gcc7-common2.sh

#########################

PKG_VERSION=8.40
PKG_NAME=pcre
PKG_TITLE=PCRE
PKG_SOURCE=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$PKG_VERSION.tar.bz2

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
		run ./configure --prefix=$PREFIX \
		                --disable-static \
		                --enable-shared \
		                --enable-unicode-properties       \
                                --enable-pcre16                   \
                                --enable-pcre32                   \
                                --enable-pcregrep-libz            \
                                --enable-pcregrep-libbz2
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
