#!/bin/sh

tmpdir=`mktemp -d /tmp/node_serv.XXXXXXXX` || exit 1
echo "using $tmpdir"

# prepare files
mkdir -p ${tmpdir}/opt/10xlabs/node_serv
cp *.coffee ${tmpdir}/opt/10xlabs/node_serv
cp package.json ${tmpdir}/opt/10xlabs/node_serv

fpm -s dir -t deb -d 'npm' -d 'nodejs' -n 10xlabs-node-serv -v 0.1 -a all --after-install local/postinst.sh --exclude local/* --exclude build.sh -C $tmpdir .

rm -Rf $tmpdir