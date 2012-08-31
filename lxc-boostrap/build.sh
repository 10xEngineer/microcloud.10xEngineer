#!/bin/sh

bootstrap_gem_dir=../../10xlabs-bootstrap-handler

if [ ! -d $bootstrap_gem_dir ]; then
  echo "Please, checkout 10xlabs-bootstrap-handler to the directory $bootstrap_gem_dir"
  exit 1
fi

rm 10xlab-bootstrap_*.deb

# build latest version of the gem
bootstrap_dir=`pwd`
cd $bootstrap_gem_dir
gem build 10xlabs-bootstrap-handler.gemspec
cd $bootstrap_dir
rm var/cache/10xlabs/*
mv ${bootstrap_gem_dir}/10xlabs-bootstrap-handler-*.gem ./var/cache/10xlabs

fpm -s dir -t deb -n 10xlab-bootstrap -v 0.4 -a all --after-install local/postinst.sh --exclude local/* --exclude build.sh .
