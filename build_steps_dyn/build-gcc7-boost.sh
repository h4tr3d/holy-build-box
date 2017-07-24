#!/bin/bash
set -e

source /hbb_build/build-gcc7-common.sh
source /hbb_build/build-gcc7-common2.sh

#########################

### BOOST
function install_boost()
{
	local VARIANT="$1"
	local PREFIX="/hbb_$VARIANT"

	header "Installing boost $BOOST_VERSION static libraries: $VARIANT"

	local underscore_version=$(echo $BOOST_VERSION | sed 's/\./_/g')
	local url=http://downloads.sourceforge.net/project/boost/boost/${BOOST_VERSION}/boost_${underscore_version}.tar.bz2
	download_and_extract boost_$BOOST_VERSION.tar.bz2 \
		boost_$underscore_version $url

	(
		source "$PREFIX/activate"
		export CFLAGS="$SHLIB_CFLAGS"
		run ./bootstrap.sh
		run ./b2 -j$MAKE_CONCURRENCY --prefix=$PREFIX   \
			--without-mpi --without-python              \
			threading=multi variant=release link=static \
			install
	)
	if [[ "$?" != 0 ]]; then false; fi

	echo "Leaving source directory"
	popd >/dev/null
	run rm -rf boost_$underscore_version
}

if ! eval_bool "$SKIP_BOOST"; then
	for VARIANT in $VARIANTS; do
		install_boost $VARIANT
	done
fi

