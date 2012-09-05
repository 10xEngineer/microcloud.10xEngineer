#!/bin/sh

app_dir=/home/git/compilation/

tmpdir=`mktemp -d /tmp/compilation.XXXXXXXX` || exit 1
echo "using $tmpdir"

target_dir="${tmpdir}${app_dir}"

# prepare files
mkdir -p ${target_dir}
rm -Rf vendor
cp -R * ${target_dir}

fpm -s dir -t deb -n 10xlabs-compilation -v 0.1 -a all --after-install local/postinst.sh --exclude local/* --exclude build.sh -C $tmpdir .

rm -Rf $tmpdir