#!/bin/bash
set -e

source /hbb_build/build-gcc7-common.sh
source /hbb_build/build-gcc7-common2.sh

#########################

### Finalizing

if ! eval_bool "$SKIP_FINALIZE"; then
	header "Finalizing"
	run yum remove -y gmp-devel mpfr-devel libmpc-devel zlib-devel
	run yum clean -y all
	run rm -rf /hbb/share/doc /hbb/share/man
	run rm -rf /hbb_build /tmp/*
	for VARIANT in $VARIANTS; do
		run rm -rf /hbb_$VARIANT/share/doc /hbb_$VARIANT/share/man
	done
fi
