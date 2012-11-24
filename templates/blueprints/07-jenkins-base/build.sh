#!/bin/bash

set -x -e

. shared/build-logic.sh

TEMPLATE_NAME=$1
BASE_IMAGE=05-java-base
TMPL_ROOT=`/bin/mktemp -d`
ROOTFS=${TMPL_ROOT}/rootfs
ARCH=amd64

check_root
mkdir -p ${ROOTFS}

copy_base_image $BASE_IMAGE $TMPL_ROOT

# dependencies
chroot $ROOTFS apt-get -y update
chroot $ROOTFS /usr/bin/apt-get -y install nginx

# install jenkins - from https://wiki.jenkins-ci.org/display/JENKINS/Installing+Jenkins+on+Ubuntu
# jenkins 1.424.6 is in default repo, 1.491 + is installed using the 2 lines below
chroot $ROOTFS /bin/bash -c "HOME=/root /usr/bin/wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -"
chroot $ROOTFS /bin/bash -c "HOME=/root /bin/echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list"
chroot $ROOTFS apt-get -y update
chroot $ROOTFS /usr/bin/apt-get -y install jenkins


# Set up an Nginx to Proxy for port 80 -> 8080
# remove the default configuration
chroot $ROOTFS /bin/bash -c "HOME=/root /bin/rm /etc/nginx/sites-available/default"

# Create a new jenkins configuration - TODO: need to replace ci.$HOSTNAME.com with local url
chroot $ROOTFS /bin/bash -c "HOME=/root /bin/cat > /etc/nginx/sites-available/jenkins <<EOF
upstream app_server {
    server 127.0.0.1:8080 fail_timeout=0;
}

server {
    listen 80;
    listen [::]:80 default ipv6only=on;
    server_name ci.$HOSTNAME.com;

    location / {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;

        if (!-f $request_filename) {
            proxy_pass http://app_server;
            break;
        }
    }
}
EOF"

# Link the new configuration
chroot $ROOTFS /bin/bash -c 'HOME=/root /bin/ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/'

# restart nginx
chroot $ROOTFS /bin/bash -c 'HOME=/root /usr/sbin/service nginx restart'

create_archive $TMPL_ROOT $TEMPLATE_NAME $ARCH

rm -Rf $TMPL_ROOT