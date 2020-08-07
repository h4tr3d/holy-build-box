#!/bin/bash
set -e

source /hbb_build/build-gcc7-common.sh
source /hbb_build/build-gcc7-common2.sh

#########################

PKG_VERSION=58.3
_PKG_VER2=58_3
PKG_NAME=icu
PKG_TITLE=ICU
PKG_SOURCE=https://github.com/unicode-org/icu/releases/download/release-${PKG_VERSION/./-}/icu4c-${PKG_VERSION/./_}-src.tgz
PKG_SOURCE2=http://www.linuxfromscratch.org/patches/blfs/8.0/icu4c-58.2-fix_enumeration-1.patch

function install_pkg()
{
	local VARIANT="$1"
	local PREFIX="/hbb_$VARIANT"

	header "Installing $PKG_TITLE $PKG_VERSION libraries: $VARIANT"
	rm -rf $PKG_NAME
	download_and_extract $PKG_NAME-$PKG_VERSION.tgz \
		$PKG_NAME \
		$PKG_SOURCE

        # Get other sources
	run curl --fail -L -o icu4c-58.2-fix_enumeration-1.patch $PKG_SOURCE2

	(
		source "$PREFIX/activate"
		export CFLAGS="$SHLIB_CFLAGS"
		export CXXFLAGS="$SHLIB_CFLAGS"
		export LDFLAGS="$SHLIB_LDFLAGS -static-libgcc"
		run patch -p1 -i icu4c-58.2-fix_enumeration-1.patch
		cd source
		run ./configure --prefix=$PREFIX \
		                --disable-static \
		                --enable-shared
		run make VERBOSE=1 -j$MAKE_CONCURRENCY
		run make install
	)
	if [[ "$?" != 0 ]]; then false; fi

	echo "Leaving source directory"
	popd >/dev/null
	run rm -rf $PKG_NAME
}

for VARIANT in $VARIANTS; do
	install_pkg $VARIANT
done
