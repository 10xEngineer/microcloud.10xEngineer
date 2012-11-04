#!/bin/sh

if [ -d "/home/labsys" ]; then
	export HOME=/home/labsys
fi

exec bundle exec ruby service.rb $1
