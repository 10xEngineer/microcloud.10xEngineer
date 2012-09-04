#!/bin/sh

app_dir=/opt/10xlabs/term_serv/

tmpdir=`mktemp -d /tmp/term_serv.XXXXXXXX` || exit 1
echo "using $tmpdir"

target_dir="${tmpdir}${app_dir}"

# prepare files
mkdir -p ${target_dir}
cp *.coffee ${target_dir}
cp -R bin ${target_dir}
cp -R app ${target_dir}
cp package.json ${target_dir}

fpm -s dir -t deb -d 'g++' -n 10xlabs-term-serv -v 0.1 -a all --after-install local/postinst.sh --exclude local/* --exclude build.sh -C $tmpdir .

rm -Rf $tmpdir