#!/bin/bash
set -e

source /hbb_build/build-gcc7-common.sh
source /hbb_build/build-gcc7-common2.sh

### linuxdeployqt

install_pkg() {
    header "Installing Linuxdeployqt"

    git clone https://github.com/probonopd/linuxdeployqt.git linuxdeployqt-git && \
        pushd linuxdeployqt-git
        #&& \
        #git checkout -b _work $BINUTILS_COMMIT

    (
        activate_holy_build_box_deps_installation_environment
        run mkdir -p build
        cd build
        export PATH="$PATH:/hbb_exe/bin"
        run qmake ..
        run make -j2
        run cp bin/linuxdeployqt $PREFIX/bin/
    )
    if [[ "$?" != 0 ]]; then false; fi

    echo "Leaving source directory"
    popd >/dev/null
    run rm -rf linuxdeployqt-git
}

install_pkg

