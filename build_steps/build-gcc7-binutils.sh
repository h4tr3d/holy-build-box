#!/bin/bash
set -e

source /hbb_build/build-gcc7-common.sh
source /hbb_build/build-gcc7-common2.sh

### binutils

install_binutils() {
    header "Installing Binutils $BINUTILS_VERSION"
    
    #git clone https://sourceware.org/git/binutils-gdb.git binutils-$BINUTILS_VERSION && \
    #    pushd binutils-$BINUTILS_VERSION && \
    #    git checkout -b _work $BINUTILS_COMMIT
    download_and_extract binutils-$BINUTILS_VERSION.tar.bz2 \
		binutils-$BINUTILS_VERSION \
		http://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.bz2
    (
        activate_holy_build_box_deps_installation_environment
        run sed -i "/ac_cpp=/s/\$CPPFLAGS/\$CPPFLAGS -O2/" libiberty/configure
        run ./configure \
                --prefix=/hbb \
                --with-lib-path=/hbb/lib:/usr/local/lib64:/lib64:/usr/lib64:/usr/local/lib:/lib:/usr/lib \
                --enable-threads \
                --enable-shared \
                --enable-ld=default \
                --enable-gold \
                --enable-plugins \
                --enable-deterministic-archives \
                --with-pic \
                --disable-werror \
                --disable-gdb
        run make -j$MAKE_CONCURRENCY configure-host
        run make -j$MAKE_CONCURRENCY tooldir=/hbb
        run make -j$MAKE_CONCURRENCY install
    )
    if [[ "$?" != 0 ]]; then false; fi
    
    echo "Leaving source directory"
	popd >/dev/null
	run rm -rf binutils-$BINUTILS_VERSION
}

install_binutils

