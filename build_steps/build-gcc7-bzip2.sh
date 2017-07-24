#!/bin/bash
set -e

source /hbb_build/build-gcc7-common.sh
source /hbb_build/build-gcc7-common2.sh

#########################

### bzip2
function install_bzip2()
{
	local VARIANT="$1"
	local PREFIX="/hbb_$VARIANT"

	header "Installing bzip2 $BZIP2_VERSION static libraries: $VARIANT"
	download_and_extract bzip2-$BZIP2_VERSION.tar.gz \
		bzip2-$BZIP2_VERSION \
		http://bzip.org/${BZIP2_VERSION}/bzip2-$BZIP2_VERSION.tar.gz

	(
		source "$PREFIX/activate"
		export CFLAGS="$STATICLIB_CFLAGS"
		
		# use our optimization and enable -fPIC if pointed by variant for static lib building
		run sed -i "s|-O2|${CFLAGS}|g" Makefile
		#run sed -i "s|-O2|${CFLAGS}|g" Makefile-libbz2_so
		
		run make -j$MAKE_CONCURRENCY
		run make install PREFIX=$PREFIX
		run rm -f $PREFIX/bin/bz* $PREFIX/bin/bunzip2
	)
	if [[ "$?" != 0 ]]; then false; fi

	echo "Leaving source directory"
	popd >/dev/null
	run rm -rf bzip2-$BZIP2_VERSION
}

if ! eval_bool "$SKIP_BZIP2"; then
	for VARIANT in $VARIANTS; do
		install_bzip2 $VARIANT
	done
fi

