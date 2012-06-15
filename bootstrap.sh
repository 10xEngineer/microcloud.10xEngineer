#!/bin/sh

#
# temporary bootstrap
#
mkdir /var/chef

/usr/local/bin/chef-solo -c hostnode-config.rb -j hostnode.json 
