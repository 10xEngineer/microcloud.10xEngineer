# Vagrant environment

Using Ubuntu 12.04 LTS (precise) box. To setup the local vagrant environment you can use base image

    vagrant box add precise32 http://ops-images.s3.amazonaws.com/precise32.box

If you need to re-build it, the image has been provisioned using  default [VeeWee](https://github.com/jedi4ever/veewee) template `ubuntu-12.04-server-i386`.

By default it's using following settings

* 2 CPUs
* 2 GB RAM
* 10 GB disk storage

Modify Vagrant file to use other settings

     config.vm.customize do |vm|
        vm.memory_size = 768
        vm.cpu_count = 1   
     end

