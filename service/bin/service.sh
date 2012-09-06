#!/bin/sh

if [ -d "/home/microcloud" ]; then
	export HOME=/home/microcloud
	chmod 0600 /home/microcloud/deploy/service/security/mchammer-dev
	ssh-add /home/microcloud/deploy/service/security/mchammer-dev
end

bundle exec ruby service.rb $1
