microcloud.10xEngineer
======================

10xEngineer.me microcloud: node.js REST API, pool management, LXC, EC2, Chef, Vagrant 

The REST API/server control a pool of Vagrant local/EC2 server instances running Ubuntu, which in turn have each have a sub-pool of LXC instances containing the target VM's.
The target VM's are managed using Chef and their setup validated using Chef-cucumber.
