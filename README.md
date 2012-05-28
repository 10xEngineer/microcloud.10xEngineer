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
- Download the git repo: 
    '''git clone git@github.com:velniukas/microcloud.10xEngineer.git'''

- Install node.js & npm 

- Install vagrant http://vagrantup.com and VirtualBox 
    http://vagrantup.com/v1/docs/getting-started/index.html

- Run node.js REST server
    '''cd microcloud.10xEngineer
    node server.js'''

- From the command line test the server will instantiate a new vm on demand
    '''curl -O http://localhost:3000/server/start/local'''

(c) 2012 All works in this repository are the sole ownership and use jointly by 10xEngineer.me, Messina Ltd and Steve Messina.
And may not be reproduced, reused, stolen for commercial or non-commercial means without explicit written permission from Steve Messina.