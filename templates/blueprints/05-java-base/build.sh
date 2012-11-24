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

# dependencies
# Oracle JDK 7 from PPA
chroot $ROOTFS /usr/bin/apt-add-repository -y ppa:webupd8team/java
chroot $ROOTFS apt-get -y update

# Alternative JDK: OpenJDK 7
# chroot $ROOTFS /bin/bash/apt-get -y install openjdk-7-jdk

# JDK-Oracle-7
# This requires prompt to accept the Oracle license terms
# will the 2nd command work (removed sudo)? - SGM
chroot $ROOTFS /bin/bash -c "HOME=/root /bin/echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections"
chroot $ROOTFS /usr/bin/apt-get -y install oracle-java7-installer

# Set JAVA_HOME environment variable
chroot $ROOTFS /bin/bash -c 'HOME=/root /bin/cat >> ~/.bashrc <<EOF

JAVA_HOME=/usr/bin/
export JAVA_HOME
PATH=$PATH:$JAVA_HOME
export PATH

EOF'

# Select a default JDK - TODO set the location of the 2 jdk's if we install both
#chroot $ROOTFS /usr/sbin/update-alternatives --install "/usr/bin/java" "java" "/usr/bin/java" 1
#chroot $ROOTFS /usr/sbin/update-alternatives --install "/usr/bin/javac" "javac" "/usr/bin/javac" 1
#chroot $ROOTFS /usr/sbin/update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/bin/javaws" 1
#chroot $ROOTFS /usr/sbin/update-alternatives --config java
#chroot $ROOTFS /usr/sbin/update-alternatives --config javac
#chroot $ROOTFS /usr/sbin/update-alternatives --config javaws

# Ant
chroot $ROOTFS /usr/bin/apt-get -y install ant

# Maven 3 (default from 12.04)
chroot $ROOTFS /usr/bin/apt-get -y install maven


create_archive $TMPL_ROOT $TEMPLATE_NAME $ARCH

rm -Rf $TMPL_ROOT