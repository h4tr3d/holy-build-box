#!/bin/bash
set -e

source /hbb_build/build-gcc7-common.sh
source /hbb_build/build-gcc7-common2.sh

## gcc

install_gcc() {
    header "Installing GCC $GCC_VERSION"
    download_and_extract gcc-$GCC_VERSION.tar.bz2 \
		gcc-$GCC_VERSION \
		http://ftpmirror.gnu.org/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.bz2
	(
	    activate_holy_build_box_deps_installation_environment
	    run sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
	    run mkdir ../build
	    cd ../build
	    run ../gcc-$GCC_VERSION/configure \
	        --prefix=/hbb \
	        --disable-multilib \
	        --with-system-zlib \
	        --enable-languages=c,c++ \
	        --disable-libstdcxx-visibility
	    run make -j$MAKE_CONCURRENCY
	    run make install
	)
	if [[ "$?" != 0 ]]; then false; fi
	
	echo "Leaving source directory"
	popd >/dev/null
	run rm -rf gcc-$GCC_VERSION
	run rm -rf gcc-build
	
}

run yum install -y gmp-devel mpfr-devel libmpc-devel zlib-devel
install_gcc
