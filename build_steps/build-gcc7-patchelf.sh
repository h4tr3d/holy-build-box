#!/bin/bash
set -e

source /hbb_build/build-gcc7-common.sh
source /hbb_build/build-gcc7-common2.sh

### linuxdeployqt

install_pkg() {
    header "Installing Linuxdeployqt"

    download_and_extract patchelf-0.9.tar.bz2 \
                patchelf-0.9 \
                https://nixos.org/releases/patchelf/patchelf-0.9/patchelf-0.9.tar.bz2

    (
        activate_holy_build_box_deps_installation_environment
        run ./configure --prefix=/hbb
        run make -j$MAKE_CONCURRENCY
        run make install
    )
    if [[ "$?" != 0 ]]; then false; fi

    echo "Leaving source directory"
    popd >/dev/null
    run rm -rf patchelf-0.9
}

install_pkg

