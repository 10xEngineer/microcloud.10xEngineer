#!/bin/sh
#
# Downloads latest snapshot of rootfs-cache-i386.tar.gz to .cache/rootfs-cache-i386 used for
# development setup
# 
# WARNING! File has over 200MBs (but lxc:rootfs-cache will download packages anyway)
#

set -e -x

cache_file="http://tenxlabs-dev.s3.amazonaws.com/rootfs-cache-i386.tar.gz"

mkdir -p .cache
cd .cache

curl -L -O ${cache_file}
