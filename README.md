Introduction to microcloud.10xEngineer.me
=========================================

This repository forms part of the back-end RESTify service for 10xEngineer which provides the virtual lab functionality.
It consists of:
- node.js RESTify server to provide the API access
- Vagrant and/or EC2 backed pool of servers
- Ubuntu LXC (Linux Containers) implemented on top of the pool of servers above to create a micro-cloud (so VM on top of VM)
    This is done for several reasons:
    - Due to the fact that most learning tasks aren't cpu intensive, we don't need a whole server to satisfy the user
    - We save money on the number of EC2 instances
    - LXC is able to save and restore its state very quickly, and easy to manage, esp. if the container file system is managed in 1 file
    - It's a cool concept :)
- We use http://github.com/LiftOff/GateOne to provide the terminal in a browser connectivity

To setup your environment
=========================

Microcloud and all related services should be run from virtual machine. To setup the environment

Get the microcloud repo:

    git clone --recursive git@github.com:10xEngineer/microcloud.10xEngineer.git

Install vagrant http://vagrantup.com and VirtualBox 
    
    http://vagrantup.com/v1/docs/getting-started/index.html

Add 10xEngineer.me default Vagrant box

    vagrant box add 10xeng-precise32 http://tenxlabs-dev.s3.amazonaws.com/tenxeng-precise32.box

Prepare local development cache (will download over 200MB of Ubuntu packages)

    ./setup_cache.sh

File don't need to be re-downloaded as long as the `.cache` folder remains intact. To update the file simple delete `.cache/` and run the script again.

Run the environment and ssh in

    vagrant up
    vagrant ssh

Microcloud API
==============

Is available within vagrant 

    vagrant ssh
    cd /vagrant
    npm install
    coffee microcloud.coffee

It depends on a service broker w/associated services. In other terminal do 

    vagrant ssh
    cd /vagrant/server
    bundle install
    bundle exec foreman start

After initial setup you can skip the `npm install`/`bundle install` part (unless you need to update packages).

## Run tests

You will need to install **mocha** and **should** globally 

	npm install mocha -g
	npm install should -g
		
then navigate to `server/` and run tests

	cd server/
	mocha
		
(Tests are located in folder `server/test/`)

(c) 2012 All works in this repository are the sole ownership and use jointly by 10xEngineer.me, Messina Ltd and Steve Messina.
And may not be reproduced, reused, stolen for commercial or non-commercial means without explicit written permission from Steve Messina.
