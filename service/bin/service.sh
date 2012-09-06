#!/bin/sh

if [ -d "/home/microcloud" ]; then
	export HOME=/home/microcloud
	
	# TODO refactor key distribution (comes from 10xeng-mc::default recipe)
	# https://trello.com/card/re-factor-key-distribution/50067c2712a969ae032917f4/71
	ssh-add /etc/10xlabs/mchammer
fi

bundle exec ruby service.rb $1
