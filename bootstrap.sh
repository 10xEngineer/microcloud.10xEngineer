#!/bin/sh
#
# DO NOT REMOVE!
#
# Part of 10xlab hostnode bootstrap
#
# 

# TODO support both remote and local execution
# TODO provide initial bootstrap template
# TODO 
#
# ./bootstrap.sh node_type [user@hostname]
#
# TODO EC2 amis are already using `ami_builder/definition/postinstall.sh' 
# TODO 

export DEBIAN_FRONTEND=noninteractive
export CHEF_ROOT=/var/chef
export NODES_PATH=${CHEF_ROOT}/nodes
export COOKBOOKS_PATH=${CHEF_ROOT}/cookbooks

# check hostnode type provided
if [ ! $1 ]; then
	echo "node type required."
	exit 1
fi

export NODE_TYPE=$1

if [ $2 ]; then
	echo "Target provided; using remote bootstrap."	
	# TODO 
fi

# setup folder (if it doesn't exist)
mkdir -p /var/chef

/usr/local/bin/chef-solo -c /var/chef/nodes/${NODE_TYPE}.rb -j /var/chef/nodes/${NODE_TYPE}/${NODE_TYPE}.json 