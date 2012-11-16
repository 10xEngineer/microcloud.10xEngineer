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

# create lab user by default
chroot $ROOTFS useradd --create-home --uid 1000 -s /bin/bash lab

# mysql presseed
chroot $ROOTFS bash -c "echo 'mysql-server-5.5 mysql-server/root_password password labpass' > /tmp/mysql.preseed"
chroot $ROOTFS bash -c "echo 'mysql-server-5.5 mysql-server/root_password_again password labpass' >> /tmp/mysql.preseed"
chroot $ROOTFS bash -c "echo 'mysql-server-5.5 mysql-server/start_on_boot boolean false' >> mysql.preseed"
chroot $ROOTFS bash -c "cat /tmp/mysql.preseed | sudo debconf-set-selections"

# dependencies
chroot $ROOTFS apt-get -y update
chroot $ROOTFS apt-get -y install zlib1g-dev libreadline-dev libxml2-dev libxslt1-dev libsqlite3-dev mysql-server libmysqlclient-dev libssl-dev imagemagick libmagickwand-dev

# ruby
chroot $ROOTFS git clone git://github.com/sstephenson/rbenv.git /home/lab/.rbenv
chroot $ROOTFS git clone git clone git://github.com/sstephenson/ruby-build.git /home/lab/.rbenv/plugins/ruby-build
chroot $ROOTFS /bin/bash --userspec lab:lab -c "cd /home/lab ; rbenv install 1.9.3-p327"

# start mysql by default
chroot $ROOTFS -c bash "update-rc.d -f mysql-server remove"

# TODO profile.d

# TODO gems
