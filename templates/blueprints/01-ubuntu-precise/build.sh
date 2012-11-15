#!/bin/bash

set -x -e

. shared/build-logic.sh

RELEASE=precise
ARCH=amd64
TEMPLATE_NAME=$1

TMPL_ROOT=`/bin/mktemp -d`
ROOTFS=${TMPL_ROOT}/rootfs

write_sourceslist()
{
    # $3 => whether to use the multi-arch syntax or not

    case $ARCH in
      amd64|i386)
            MIRROR=${MIRROR:-http://eu-west-1.ec2.archive.ubuntu.com/ubuntu/}
            SECURITY_MIRROR=${SECURITY_MIRROR:-http://eu-west-1.ec2.archive.ubuntu.com/ubuntu/}
            ;;
      *)
            MIRROR=${MIRROR:-http://ports.ubuntu.com/ubuntu-ports}
            SECURITY_MIRROR=${SECURITY_MIRROR:-http://ports.ubuntu.com/ubuntu-ports}
            ;;
    esac
    if [ -n "$3" ]; then
        cat >> "${cache}/partial-$ARCH/etc/apt/sources.list" << EOF
deb [arch=$ARCH] $MIRROR ${RELEASE} main restricted universe multiverse
deb [arch=$ARCH] $MIRROR ${RELEASE}-updates main restricted universe multiverse
deb [arch=$ARCH] $SECURITY_MIRROR ${RELEASE}-security main restricted universe multiverse
EOF
    else
        cat >> "${cache}/partial-$ARCH/etc/apt/sources.list" << EOF
deb $MIRROR ${RELEASE} main restricted universe multiverse
deb $MIRROR ${RELEASE}-updates main restricted universe multiverse
deb $SECURITY_MIRROR ${RELEASE}-security main restricted universe multiverse
EOF
    fi
}

cleanup()
{
    rm -rf $cache/partial-$ARCH
    rm -rf $cache/rootfs-$ARCH
}

download_ubuntu()
{
    cache=$1

    packages=vim-tiny,ssh,git,curl,zsh,man,info,build-essential,python-software-properties
    echo "installing packages: $packages"

    trap cleanup EXIT SIGHUP SIGINT SIGTERM
    # check the mini ubuntu was not already downloaded
    mkdir -p "$cache/partial-$ARCH"
    if [ $? -ne 0 ]; then
        echo "Failed to create '$cache/partial-$ARCH' directory"
        return 1
    fi

    # download a mini ubuntu into a cache
    echo "Downloading ubuntu $RELEASE minimal ..."
    debootstrap --verbose --components=main,universe --arch=$ARCH --include=$packages $RELEASE $cache/partial-$ARCH $APT_MIRROR

    if [ $? -ne 0 ]; then
        echo "Failed to download the rootfs, aborting."
        return 1
    fi

    # Serge isn't sure whether we should avoid doing this when
    # $release == `distro-info -d`
    echo "Installing updates"
    > $cache/partial-$ARCH/etc/apt/sources.list
    write_sourceslist $cache/partial-$ARCH/ $ARCH

    chroot "$1/partial-${ARCH}" apt-get update
    if [ $? -ne 0 ]; then
        echo "Failed to update the apt cache"
        return 1
    fi
    cat > "$1/partial-${ARCH}"/usr/sbin/policy-rc.d << EOF
#!/bin/sh
exit 101
EOF
    chmod +x "$1/partial-${ARCH}"/usr/sbin/policy-rc.d

    lxc-unshare -s MOUNT -- chroot "$1/partial-${ARCH}" apt-get dist-upgrade -y || { suggest_flush; false; }
    rm -f "$1/partial-${ARCH}"/usr/sbin/policy-rc.d

    chroot "$1/partial-${ARCH}" apt-get clean

    mv "$1/partial-$ARCH" "$1/rootfs-$ARCH"
    trap EXIT
    trap SIGINT
    trap SIGTERM
    trap SIGHUP
    echo "Download complete"
    return 0
}

copy_ubuntu()
{
    echo "Copying rootfs to $ROOTFS ..."

    mkdir -p $ROOTFS
    rsync -a $cache/rootfs-$ARCH/ $ROOTFS/ || return 1

    return 0
}

install_ubuntu()
{
    cache="/var/cache/templates/${TEMPLATE_NAME}"

    #rm -rf $cache
    mkdir -p $cache

    echo "Checking cache download in $cache/ROOTFS-$ARCH ... "
    if [ ! -e "$cache/rootfs-$ARCH" ]; then
        download_ubuntu $cache $ARCH $RELEASE
        if [ $? -ne 0 ]; then
            echo "Failed to download 'ubuntu $RELEASE base'"
            return 1
        fi
    fi

    echo "Copy $cache/rootfs-$ARCH to $ROOTFS ... "
    copy_ubuntu $cache $ARCH $ROOTFS
    if [ $? -ne 0 ]; then
        echo "Failed to copy rootfs"
        return 1
    fi

    return 0
}

post_process()
{
    chroot $ROOTFS /usr/sbin/locale-gen en_US en_US.UTF-8
    chroot $ROOTFS /usr/sbin/dpkg-reconfigure locales

    rm $ROOTFS/etc/legal
}

type debootstrap
if [ $? -ne 0 ]; then
    echo "'debootstrap' command is missing"
    exit 1
fi

check_root
mkdir -p rootfs

# copy static assets
cp -R blueprints/$TEMPLATE_NAME/assets/* $TMPL_ROOT/

# install ubuntu
install_ubuntu 
if [ $? -ne 0 ]; then
    echo "failed to install ubuntu $RELEASE"
    exit 1
fi

post_process 
create_archive $TMPL_ROOT $TEMPLATE_NAME $ARCH

rm -Rf $TMPL_ROOT
