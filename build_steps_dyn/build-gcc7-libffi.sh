#!/bin/bash
set -e

source /hbb_build/build-gcc7-common.sh
source /hbb_build/build-gcc7-common2.sh

#########################

PKG_VERSION=3.2.1
PKG_NAME=libffi
PKG_TITLE=libffi
PKG_SOURCE=ftp://sourceware.org/pub/libffi/libffi-$PKG_VERSION.tar.gz

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
		run sed -e '/^includesdir/ s/$(libdir).*$/$(includedir)/' \
                        -i include/Makefile.in
                run sed -e '/^includedir/ s/=.*$/=@includedir@/' \
                        -e 's/^Cflags: -I${includedir}/Cflags:/' \
                        -i libffi.pc.in
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
