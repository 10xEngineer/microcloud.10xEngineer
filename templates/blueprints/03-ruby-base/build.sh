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

# dependencies
chroot $ROOTFS apt-get -y update
chroot $ROOTFS apt-get -y install zlib1g-dev libreadline-dev libxml2-dev libxslt1-dev libsqlite3-dev libssl-dev imagemagick libmagickwand-dev ruby1.9.1 ruby1.9.1-dev libruby1.9.1 ri1.9.1

# ruby gems
chroot $ROOTFS /bin/bash -c "HOME=/root /usr/bin/gem install rails"
chroot $ROOTFS /bin/bash -c "HOME=/root /usr/bin/gem install nokogiri"
chroot $ROOTFS /bin/bash -c "HOME=/root /usr/bin/gem install rmagick"
chroot $ROOTFS /bin/bash -c "HOME=/root /usr/bin/gem install sqlite3"
chroot $ROOTFS /bin/bash -c "HOME=/root /usr/bin/gem install pry"
chroot $ROOTFS /bin/bash -c "HOME=/root /usr/bin/gem install sinatra"

create_archive $TMPL_ROOT $TEMPLATE_NAME $ARCH