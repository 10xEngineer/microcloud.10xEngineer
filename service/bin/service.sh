#!/bin/sh

if [ -d "/home/labsys" ]; then
	export HOME=/home/labsys
	
	# TODO refactor key distribution (comes from 10xeng-mc::default recipe)
	# https://trello.com/card/re-factor-key-distribution/50067c2712a969ae032917f4/71
	ssh-add /etc/labs/mchammer
fi

exec bundle exec ruby service.rb $1
