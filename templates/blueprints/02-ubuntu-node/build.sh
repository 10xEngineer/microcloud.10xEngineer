#!/bin/bash

set -x -e

. shared/build-logic.sh

BASE_IMAGE=01-ubuntu-precise
TMPL_ROOT=`/bin/mktemp -d`
ROOTFS=${TMPL_ROOT}/rootfs

check_root
mkdir -p rootfs

copy_base_image $BASE_IMAGE $TMPL_ROOT

chroot $ROOTFS apt-get install nodejs npm