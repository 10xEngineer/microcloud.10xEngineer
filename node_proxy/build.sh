#!/bin/sh

version=0.1

tmpdir=`mktemp -d /tmp/gateway.XXXXXXXX` || exit 1
echo "using $tmpdir"

# prepare files
mkdir -p ${tmpdir}/opt/10xlabs/http_proxy
cp *.coffee ${tmpdir}/opt/10xlabs/http_proxy
cp package.json ${tmpdir}/opt/10xlabs/http_proxy

fpm -s dir -t deb -d 'npm' -d 'nodejs' -n 10xlabs-httproxy -v $version -a all --after-install local/postinst.sh --exclude local/* --exclude build.sh -C $tmpdir .

rm -Rf $tmpdir

mv 10xlabs-httproxy_${version}_all.deb ../chef_repo/cookbooks/10xeng-node/files/default
