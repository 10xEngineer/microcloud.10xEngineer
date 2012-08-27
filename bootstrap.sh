#!/bin/sh

#
# DO NOT REMOVE!
#
# Part of 10xlab hostnode bootstrap
#
mkdir /var/chef

/usr/local/bin/chef-solo -c hostnode-config.rb -j hostnode.json 
