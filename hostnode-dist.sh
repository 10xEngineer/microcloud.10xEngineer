#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

#TODO multi-region support 
#     or switch to CF based distribution (check ec2 service)
#TARGET=s3://ops-images/hostnode-dist.tar.gz
TARGET=s3://tenxlabs-ap-southeast-1/hostnode-dist.tar.gz
DISTFILE=/tmp/hostnode-dist.tar.gz

command -v s3cmd >/dev/null 2>&1 || { echo >&2 "s3tools are required to run hostnode distribution bundler. Come back when you have it installed."; exit 1; }

# TODO hostnode.json to be configurable at hostnode distribution level
#      or instance start ec2.rb user_data
tar -cz -f $DISTFILE -X hostnode-dist.exclude ./

s3cmd put $DISTFILE $TARGET
s3cmd setacl $TARGET --acl-public

#rm $DISTFILE
