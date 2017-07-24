#!/bin/bash
set -e

source /hbb_build/build-gcc7-common.sh
source /hbb_build/build-gcc7-common2.sh

#########################

source /hbb_build/build-gcc7-qt5-common.sh

function prepare_pkg()
{
	header "Prepare $PKG_TITLE $PKG_VERSION libraries to build"

	local _BASENAME=$PKG_NAME-$PKG_VERSION.tar.xz
	local _DIRNAME=$PKG_NAME-$PKG_VERSION
	run rm -f "/tmp/$_BASENAME.tmp"
	run curl --fail -L -o "/tmp/$_BASENAME.tmp" "$PKG_SOURCE"
	run mv "/tmp/$_BASENAME.tmp" "/tmp/$_BASENAME"
	run tar xJf "/tmp/$_BASENAME"
}

prepare_pkg