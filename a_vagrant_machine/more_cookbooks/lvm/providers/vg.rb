# lvm_vg provider

def create_vg(name, volumes)
  require 'lvm'

  lvm = LVM::LVM.new(:command => "/usr/bin/sudo /sbin/lvm")

  group = lvm.volume_groups[new_resource.name]
  unless group
    puts "GO GO!"
  end
end

action :create do
  
end
