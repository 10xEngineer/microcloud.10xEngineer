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

# install tomcat 7
chroot $ROOTFS /usr/bin/apt-get -y install tomcat7

# Set environment variables
chroot $ROOTFS /bin/bash -c 'HOME=/root /bin/cat >> /usr/local/Tomcat7/bin/setenv.sh <<EOF

export CATALINA_OPTS="$CATALINA_OPTS -Xms128m -Xmx1024m -XX:MaxPermSize=256m"

EOF'

# Set default user and password 'admin/lab' - TODO - This must be changed
chroot $ROOTFS /bin/bash -c 'HOME=/root /bin/cat >> /usr/local/Tomcat7/conf/./tomcat-users.xml <<EOF

<role rolename="manager-gui" />
<role rolename="manager-script" />
<role rolename="manager-jmx" />
<role rolename="manager-status" />
<user username="admin" password="lab" roles="manager-gui,manager-script,manager-jmx,manager-status"/>

EOF'

# change the default port (if necessary)
#chroot $ROOTFS /bin/bash -c 'HOME=/root /bin/cat >> /usr/local/Tomcat7/conf/./server.xml <<EOF
#EOF'


create_archive $TMPL_ROOT $TEMPLATE_NAME $ARCH

rm -Rf $TMPL_ROOT