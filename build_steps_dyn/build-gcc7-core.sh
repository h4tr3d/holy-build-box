#!/bin/bash
set -e

source /hbb_build/build-gcc7-common.sh

#########################

header "Initializing"
run mkdir -p /hbb /hbb/bin
run cp /hbb_build/libcheck /hbb/bin/
run cp /hbb_build/hardening-check /hbb/bin/
run cp /hbb_build/setuser /hbb/bin/
run cp /hbb_build/activate_func.sh /hbb/activate_func.sh
run cp /hbb_build/hbb-activate /hbb/activate
run cp /hbb_build/activate-exec /hbb/activate-exec

run groupadd -g 9327 builder
run adduser --uid 9327 --gid 9327 builder

for VARIANT in $VARIANTS; do
	run mkdir -p /hbb_$VARIANT
	run cp /hbb_build/activate-exec /hbb_$VARIANT/
	run cp /hbb_build/variants/$VARIANT.sh /hbb_$VARIANT/activate
done

header "Updating system"
# This required due to bugs in yum on overlayfs:
# https://bugzilla.redhat.com/show_bug.cgi?id=1213602
# https://github.com/docker/docker/issues/10180
run touch /var/lib/rpm/*
run rpm --rebuilddb

#run yum update -y
#run yum install -y curl epel-release centos-release-scl-rh

# Enable autotools-latest EPEL
# ref: https://copr.fedorainfracloud.org/coprs/praiskup/autotools/
# ref: http://woshub.com/install-configure-repos-centos-rhel/
#run yum install -y https://www.softwarecollections.org/en/scls/praiskup/autotools/epel-6-${OSARCH}/download/praiskup-autotools-epel-6-${OSARCH}.noarch.rpm
(
    cd /etc/yum.repos.d
    #run wget -c https://copr.fedorainfracloud.org/coprs/praiskup/autotools/repo/epel-6/praiskup-autotools-epel-6.repo
    run run curl --fail -L -o praiskup-autotools-epel-6.repo https://copr.fedorainfracloud.org/coprs/praiskup/autotools/repo/epel-6/praiskup-autotools-epel-6.repo
)

run yum update -y
run yum install -y curl epel-release centos-release-scl-rh scl-utils

header "Installing compiler toolchain"
cd /
# Use devtoolset-7
# ref: https://forums.centos.org/viewtopic.php?t=71663
run yum install -y devtoolset-7-gcc devtoolset-7-gcc-c++ \
		devtoolset-7-binutils devtoolset-7  make file diffutils \
		patch perl bzip2 which gzip autotools-latest python27 \
		bison git doxygen
