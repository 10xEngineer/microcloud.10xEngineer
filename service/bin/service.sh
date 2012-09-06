#!/bin/sh

if [ -d "/home/microcloud" ]; then
	export HOME=/home/microcloud
end

bundle exec ruby service.rb $1
