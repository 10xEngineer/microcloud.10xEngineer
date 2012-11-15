#!/bin/bash

set -x -e

. shared/build-logic.sh

TEMPLATE_NAME=$1
BASE_IMAGE=01-ubuntu-precise
TMPL_ROOT=`/bin/mktemp -d`
ROOTFS=${TMPL_ROOT}/rootfs
ARCH=amd64

check_root
mkdir -p ${ROOTFS}

copy_base_image $BASE_IMAGE $TMPL_ROOT

# node.js
chroot $ROOTFS /usr/bin/apt-add-repository -y ppa:chris-lea/node.js
chroot $ROOTFS apt-get -y update

# mongodb
chroot $ROOTFS apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
chroot $ROOTFS echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' >>$ROOTFS/etc/apt/sources.list

chroot $ROOTFS apt-get -y update
chroot $ROOTFS apt-get -y install nodejs npm 
chroot $ROOTFS apt-get -y install mongodb-10gen || echo "mongodb-10gen configure failed as expected."
chroot $ROOTFS npm -g install coffee-script

create_archive $TMPL_ROOT $TEMPLATE_NAME $ARCH

rm -Rf $TMPL_ROOT
