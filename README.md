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

