#!/bin/sh

set -e -x

export TXENG_ROOT=/var/lib/10xeng
export DEBIAN_FRONTEND=noninteractive

# 10xeng root
mkdir -p ${TXENG_ROOT}

# TODO implement rest as part of chef environment distribution
exit

cd /tmp
curl -O http://dist.mc.10xengineer.me/node/chef.tar.gz
tar xvfz chef.tar.gz -C #{TXENG_ROOT}

cd $TXENG_ROOT
if [ -x boostrap.sh ]; then
  ./bootstrap.sh
fi


