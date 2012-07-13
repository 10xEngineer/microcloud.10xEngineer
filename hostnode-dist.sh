#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

#TODO multi-region support 
#     or switch to CF based distribution (check ec2 service)
#TARGET=s3://ops-images/hostnode-dist.tar.gz
TARGET=s3://tenx-labs-ops/hostnode-dist.tar.gz
DISTFILE=/tmp/hostnode-dist.tar.gz

command -v s3cmd >/dev/null 2>&1 || { echo >&2 "s3tools are required to run hostnode distribution bundler. Come back when you have it installed."; exit 1; }

tar -cz -f $DISTFILE -X hostnode-dist.exclude ./

s3cmd put $DISTFILE $TARGET
#s3cmd setacl $TARGET --acl-public

#rm $DISTFILE
