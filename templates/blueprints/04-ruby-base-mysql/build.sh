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

# policy-rc.d
cp blueprints/${TEMPLATE_NAME}/assets/invoke-rc.d $ROOTFS/usr/sbin/policy-rc.d

# mysql presseed
chroot $ROOTFS bash -c "echo 'mysql-server-5.5 mysql-server/root_password password labpass' > /tmp/mysql.preseed"
chroot $ROOTFS bash -c "echo 'mysql-server-5.5 mysql-server/root_password_again password labpass' >> /tmp/mysql.preseed"
chroot $ROOTFS bash -c "echo 'mysql-server-5.5 mysql-server/start_on_boot boolean false' >> mysql.preseed"
chroot $ROOTFS bash -c "cat /tmp/mysql.preseed | debconf-set-selections"

# dependencies
chroot $ROOTFS apt-get -y update
chroot $ROOTFS apt-get -y install mysql-server libmysqlclient-dev

chroot --userspec lab:lab $ROOTFS /bin/bash -c "cd /home/lab ; HOME=/home/lab PATH=/home/lab/.rbenv/shims:/home/lab/.rbenv/bin:/bin:/usr/bin:/usr/sbin gem install mysql2"

# start mysql by default
chroot $ROOTFS -c bash "update-rc.d -f mysql-server defaults"

rm $ROOTFS/usr/sbin/policy-rc.d
