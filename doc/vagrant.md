# Vagrant environment

Using Ubuntu 12.04 LTS (precise) box. To setup the local vagrant environment you can use base image

    vagrant box add precise32 http://ops-images.s3.amazonaws.com/precise32-mc.box

Compared to a default Ubuntu 12.04 it has only 10GB file allocated towards logical volumes. Rest is kept for LXC provisioning. If you need to re-build it, use the definition `precise32-mc` for [VeeWee](https://github.com/jedi4ever/veewee) to build it.

By default the box is using following settings

* 1 CPUs
* 512 MB RAM
* 20 GB disk storage

