# lvm_vg provider

def create_vg(name, volumes)
  require 'lvm'

  lvm = LVM::LVM.new(:command => "/usr/bin/sudo /sbin/lvm")

  group = lvm.volume_groups[name]
  unless group
    Chef::Log.info "Creating new volume group '#{name}'"

    lvm.raw "vgcreate #{name} #{volumes.join(' ')}"
  else
    # TODO add/remove physical devices from the group
  end
end

action :create do
  create_vg(new_resource.name, new_resource.physical_volumes)
end
