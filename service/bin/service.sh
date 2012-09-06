#!/bin/sh

if [ -d "/home/microcloud" ]; then
	export HOME=/home/microcloud
	ssh-add /etc/10xlabs/mchammer
fi

bundle exec ruby service.rb $1
