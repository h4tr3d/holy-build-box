#!/bin/bash
set -e

source /hbb_build/build-gcc7-common.sh
source /hbb_build/build-gcc7-common2.sh

#########################

source /hbb_build/build-gcc7-qt5-common.sh

function install_pkg()
{
	local VARIANT="$1"
	local PREFIX="/hbb_$VARIANT"

	header "Installing $PKG_TITLE $PKG_VERSION libraries: $VARIANT"

        local _DIRNAME=$PKG_NAME-$PKG_VERSION-build-$VARIANT
        run mkdir -p $_DIRNAME
	echo "Entering $_DIRNAME"
	pushd $_DIRNAME

	(
		source "$PREFIX/activate"
		export CFLAGS="$SHLIB_CFLAGS"
		# Fix compilation test for Sqlite3
		echo 'LIBS += -pthread' >> /qt-everywhere-opensource-src-$PKG_VERSION/qtbase/config.tests/unix/sqlite/sqlite.pro
		# CentOS6 headers too old
		#BTN_TRIGGER_HAPPY1      0x2c0
		#BTN_TRIGGER_HAPPY2      0x2c1
		#BTN_TRIGGER_HAPPY3      0x2c2
		#BTN_TRIGGER_HAPPY4      0x2c3
		echo 'DEFINES += BTN_TRIGGER_HAPPY1=0x2c0 BTN_TRIGGER_HAPPY2=0x2c1 BTN_TRIGGER_HAPPY3=0x2c2 BTN_TRIGGER_HAPPY4=0x2c3' >> /qt-everywhere-opensource-src-$PKG_VERSION/qtgamepad/src/plugins/gamepads/evdev/evdev.pro
		# no -gtk integration - more impact is needed
		run ../qt-everywhere-opensource-src-$PKG_VERSION/configure \
		    -prefix $PREFIX \
		    -confirm-license           \
                    -opensource                \
                    -release                   \
                    -no-static                 \
                    -shared                    \
                    -c++std c++1z              \
                    -dbus-runtime              \
                    -openssl-runtime           \
                    -qt-harfbuzz           \
                    -qt-sqlite             \
                    -qt-zlib               \
                    -qt-libpng             \
                    -qt-freetype           \
                    -qt-pcre                   \
                    -system-xcb                \
                    -nomake examples           \
                    -nomake tests              \
                    -no-rpath                  \
                    -skip qtwebengine          \
                    -evdev                     \
                    -xcb                       \
                    -qpa xcb                   \
                    -cups                      \
                    -ssl                       \
                    -glib
		run make -j$MAKE_CONCURRENCY
		run make install
		
		# Remove reference to the build directory
		run find $PREFIX/lib/pkgconfig -name "*.pc" -exec perl -pi -e "s, -L$PWD/?\S+,,g" {} \;
		
		run find $PREFIX/ -name qt_lib_bootstrap_private.pri -exec sed -i -e "s:$PWD/qtbase:/$PREFIX/lib/:g" {} \;
		run find $PREFIX/ -name \*.prl -exec sed -i -e '/^QMAKE_PRL_BUILD_DIR/d' {} \;
	)
	if [[ "$?" != 0 ]]; then false; fi

	echo "Leaving source directory"
	popd >/dev/null
	run rm -rf $_DIRNAME
}

for VARIANT in $VARIANTS; do
	install_pkg $VARIANT
done

# Clean up
rm -rf qt-everywhere-opensource-src-$PKG_VERSION
rm -f /tmp/$PKG_NAME-$PKG_VERSION.tar.xz
