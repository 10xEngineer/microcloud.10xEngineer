#!/bin/sh

version=0.1

tmpdir=`mktemp -d /tmp/gateway.XXXXXXXX` || exit 1
echo "using $tmpdir"

# prepare files
mkdir -p ${tmpdir}/opt/10xlabs/gateway
cp *.coffee ${tmpdir}/opt/10xlabs/gateway
cp package.json ${tmpdir}/opt/10xlabs/gateway

fpm -s dir -t deb -d 'npm' -d 'nodejs' -n 10xlabs-gateway -v $version -a all --after-install local/postinst.sh --exclude local/* --exclude build.sh -C $tmpdir .

rm -Rf $tmpdir

mv 10xlabs-gateway_${version}_all.deb ../chef_repo/cookbooks/10xeng-sshgate/files/default