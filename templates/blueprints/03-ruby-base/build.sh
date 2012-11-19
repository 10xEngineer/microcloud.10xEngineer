#!/bin/bash

set -x -e

. shared/build-logic.sh

TEMPLATE_NAME=$1
BASE_IMAGE=03-ruby-base
TMPL_ROOT=`/bin/mktemp -d`
ROOTFS=${TMPL_ROOT}/rootfs
ARCH=amd64

check_root
mkdir -p ${ROOTFS}

copy_base_image $BASE_IMAGE $TMPL_ROOT

# create lab user by default
chroot $ROOTFS useradd --create-home --uid 1000 -s /bin/bash lab

# policy-rc.d
cp blueprints/${TEMPLATE_NAME}/assets/invoke-rc.d $ROOTFS/usr/sbin/policy-rc.d

# dependencies
chroot $ROOTFS apt-get -y update
chroot $ROOTFS apt-get -y install zlib1g-dev libreadline-dev libxml2-dev libxslt1-dev libsqlite3-dev libssl-dev imagemagick libmagickwand-dev

# ruby
chroot $ROOTFS git clone git://github.com/sstephenson/rbenv.git /home/lab/.rbenv
chroot $ROOTFS git clone git://github.com/sstephenson/ruby-build.git /home/lab/.rbenv/plugins/ruby-build
chroot $ROOTFS /bin/bash -c "chown lab:lab -R /home/lab/.rbenv"
chroot --userspec lab:lab $ROOTFS /bin/bash -c "cd /home/lab ; HOME=/home/lab PATH=/home/lab/.rbenv/shims:/home/lab/.rbenv/bin:/bin:/usr/bin:/usr/sbin rbenv install 1.9.3-p327"

# ruby gems
chroot --userspec lab:lab $ROOTFS /bin/bash -c "cd /home/lab ; HOME=/home/lab PATH=/home/lab/.rbenv/shims:/home/lab/.rbenv/bin:/bin:/usr/bin:/usr/sbin gem install rails"
chroot --userspec lab:lab $ROOTFS /bin/bash -c "cd /home/lab ; HOME=/home/lab PATH=/home/lab/.rbenv/shims:/home/lab/.rbenv/bin:/bin:/usr/bin:/usr/sbin gem install nokogiri"
chroot --userspec lab:lab $ROOTFS /bin/bash -c "cd /home/lab ; HOME=/home/lab PATH=/home/lab/.rbenv/shims:/home/lab/.rbenv/bin:/bin:/usr/bin:/usr/sbin gem install rmagick"
chroot --userspec lab:lab $ROOTFS /bin/bash -c "cd /home/lab ; HOME=/home/lab PATH=/home/lab/.rbenv/shims:/home/lab/.rbenv/bin:/bin:/usr/bin:/usr/sbin gem install rmagick"
chroot --userspec lab:lab $ROOTFS /bin/bash -c "cd /home/lab ; HOME=/home/lab PATH=/home/lab/.rbenv/shims:/home/lab/.rbenv/bin:/bin:/usr/bin:/usr/sbin gem install sqlite3"
chroot --userspec lab:lab $ROOTFS /bin/bash -c "cd /home/lab ; HOME=/home/lab PATH=/home/lab/.rbenv/shims:/home/lab/.rbenv/bin:/bin:/usr/bin:/usr/sbin gem install pry"
chroot --userspec lab:lab $ROOTFS /bin/bash -c "cd /home/lab ; HOME=/home/lab PATH=/home/lab/.rbenv/shims:/home/lab/.rbenv/bin:/bin:/usr/bin:/usr/sbin gem install sinatra"

rm $ROOTFS/usr/sbin/policy-rc.d
