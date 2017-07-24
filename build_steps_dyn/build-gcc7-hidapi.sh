#!/bin/bash
set -e

source /hbb_build/build-gcc7-common.sh
source /hbb_build/build-gcc7-common2.sh

#########################

PKG_VERSION=0.8.0-rc1
PKG_NAME=hidapi
PKG_TITLE=hidapi
PKG_SOURCE=https://github.com/signal11/hidapi/archive/hidapi-0.8.0-rc1.tar.gz

function install_pkg()
{
	local VARIANT="$1"
	local PREFIX="/hbb_$VARIANT"

	header "Installing $PKG_TITLE $PKG_VERSION libraries: $VARIANT"
	download_and_extract $PKG_NAME-$PKG_VERSION.tar.gz \
		$PKG_NAME-$PKG_NAME-$PKG_VERSION \
		$PKG_SOURCE

	(
		source "$PREFIX/activate"
		export CFLAGS=""
		export LDFLAGS=""
		run ./bootstrap
		run ./configure \
		    --prefix=$PREFIX \
		    --disable-static \
		    --enable-shared
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
