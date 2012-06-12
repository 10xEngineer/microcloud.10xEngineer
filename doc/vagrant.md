# Vagrant environment

Using Ubuntu 12.04 LTS (precise) box. To setup the local vagrant environment you can use base image

    vagrant box add 10xeng-precise32 http://ops-images.s3.amazonaws.com/10xeng-precise32.box

Compared to a default Ubuntu 12.04 it has only 10GB file allocated towards logical volumes. Rest is kept for LXC provisioning. If you need to re-build it, use the definition `tenxeng-precise32` for [VeeWee](https://github.com/jedi4ever/veewee) to build it.

By default the box is using following settings

* 1 CPUs
* 512 MB RAM
* 20 GB disk storage (used 10GB, rest used for LVM/LXC)

