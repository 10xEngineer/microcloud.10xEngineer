#!/bin/sh

fpm -s dir -t deb -n 10xlab-bootstrap -v 0.1 -a all --after-install local/postinst.sh --exclude local/* --exclude build.sh .