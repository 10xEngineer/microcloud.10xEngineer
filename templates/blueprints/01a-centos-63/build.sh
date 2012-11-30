#!/bin/bash

set -x -e

. shared/build-logic.sh

RELEASE=6.3
ARCH=x86_64
TEMPLATE_NAME=$1

TMPL_ROOT=`/bin/mktemp -d`
ROOTFS=${TMPL_ROOT}/rootfs

cleanup()
{
    rm -rf $cache/partial-$ARCH
    rm -rf $cache/rootfs-$ARCH
}

download_centos()
{
    cache=$1

    # TODO does it need yum update

    # TODO
    #packages=vim-tiny,ssh,git,curl,zsh,man-db,info,build-essential,python-software-properties
    #echo "installing packages: $packages"

    trap cleanup EXIT SIGHUP SIGINT SIGTERM

    # check the centos was not already downloaded
    mkdir -p "$cache/partial-$ARCH"
    if [ $? -ne 0 ]; then
        echo "Failed to create '$cache/partial-$ARCH' directory"
        return 1
    fi

    # download centos
    echo "Downloading centos..."
    PARTIAL_ROOT=$cache/partial-$ARCH
    #URL="http://www.mirrorservice.org/sites/mirror.centos.org/${RELEASE}/os/${ARCH}/Packages/centos-release-${RELEASE}.el6.centos.9.${ARCH}.rpm"
    URL="http://www.mirrorservice.org/sites/mirror.centos.org/6.3/os/x86_64/Packages/centos-release-6-3.el6.centos.9.x86_64.rpm"
    curl $URL >$PARTIAL_ROOT/centos-release-${RELEASE}.${ARCH}.rpm

    mkdir -p $PARTIAL_ROOT/var/lib/rpm
    rpm --root $PARTIAL_ROOT --initdb
    rpm --root $PARTIAL_ROOT -ivh $PARTIAL_ROOT/centos-release-${RELEASE}.${ARCH}.rpm

    YUM="yum --installroot $PARTIAL_ROOT -y --nogpgcheck"
    BASE_PACKAGES="yum initscripts passwd rsyslog vim-minimal dhclient chkconfig rootfiles policycoreutils"
    BASE_PACKAGES="$BASE_PACKAGES git openssh-server openssh-clients zsh sudo tree ntp curl "
    $YUM install $BASE_PACKAGES
    $YUM groupinstall "Development Tools"

    if [ $? -ne 0 ]; then
        echo "Failed to download the rootfs, aborting."
        return 1
    fi

    mv $PARTIAL_ROOT $cache/rootfs-$ARCH
    trap EXIT
    trap SIGINT
    trap SIGTERM
    trap SIGHUP
    echo "Download complete"
    return 0
}

copy_centos()
{
    echo "Copying rootfs to $ROOTFS ..."

    mkdir -p $ROOTFS
    rsync -a $cache/rootfs-$ARCH/ $ROOTFS/ || return 1

    return 0
}

install_centos()
{
    cache="/var/cache/templates/${TEMPLATE_NAME}"

    mkdir -p $cache

    echo "Checking cache download in $cache/ROOTFS-$ARCH ... "
    if [ ! -e "$cache/rootfs-$ARCH" ]; then
        download_centos $cache $ARCH $RELEASE
        if [ $? -ne 0 ]; then
            echo "Failed to download 'centos $RELEASE'"
            return 1
        fi
    fi

    copy_centos $cache $ARCH $ROOTFS

    # disable selinux
    mkdir -p $rootfs_path/selinux
    echo 0 > $rootfs_path/selinux/enforce



}


post_process()
{
    chroot ${ROOTFS} chkconfig udev-post off
    chroot ${ROOTFS} chkconfig network on
    chroot ${ROOTFS} chkconfig sshd on

    sed -i 's|.sbin.start_udev||' ${ROOTFS}/etc/rc.sysinit
    sed -i 's|.sbin.start_udev||' ${ROOTFS}/etc/rc.d/rc.sysinit
    # don't mount devpts, for pete's sake
    sed -i 's/^.*dev.pts.*$/#\0/' ${ROOTFS}/etc/rc.sysinit
    sed -i 's/^.*dev.pts.*$/#\0/' ${ROOTFS}/etc/rc.d/rc.sysinit

    chroot ${ROOTFS} chkconfig udev-post off
    chroot ${ROOTFS} chkconfig network on

    dev_path="${ROOTFS}/dev"
    rm -rf $dev_path
    mkdir -p $dev_path
    mknod -m 666 ${dev_path}/null c 1 3
    mknod -m 666 ${dev_path}/zero c 1 5
    mknod -m 666 ${dev_path}/random c 1 8
    mknod -m 666 ${dev_path}/urandom c 1 9
    mkdir -m 755 ${dev_path}/pts
    mkdir -m 1777 ${dev_path}/shm
    mknod -m 666 ${dev_path}/tty c 5 0
    mknod -m 666 ${dev_path}/tty0 c 4 0
    mknod -m 666 ${dev_path}/tty1 c 4 1
    mknod -m 666 ${dev_path}/tty2 c 4 2
    mknod -m 666 ${dev_path}/tty3 c 4 3
    mknod -m 666 ${dev_path}/tty4 c 4 4
    mknod -m 600 ${dev_path}/console c 5 1
    mknod -m 666 ${dev_path}/full c 1 7
    mknod -m 600 ${dev_path}/initctl p
    mknod -m 666 ${dev_path}/ptmx c 5 2    
}

type yum
if [ $? -ne 0 ]; then
    echo "'yum' command is missing"
    exit 1
fi

check_root
mkdir -p rootfs

# copy static assets
cp -R blueprints/$TEMPLATE_NAME/assets/* $TMPL_ROOT/

install_centos
if [ $? -ne 0 ]; then
    echo "failed to install centos $RELEASE"
    exit 1
fi


post_process 
create_archive $TMPL_ROOT $TEMPLATE_NAME $ARCH

rm -Rf $TMPL_ROOT
