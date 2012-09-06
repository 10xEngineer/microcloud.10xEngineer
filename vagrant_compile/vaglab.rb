#!/usr/bin/env ruby

require 'vagrant'

# FIXME hardcoded (ARGV)
root = "/Users/radim/Projects/10xeng/microcloud.10xEngineer"
env = Vagrant::Environment.new(:cwd => root)

# build VMs
vms = []

env.vms.each do |vm_name, vagrant_vm|
	vm_config = env.config.for_vm(vm_name.to_sym).keys[:vm]

	# validation

	raise "Multiple provisioners not supported" unless vm_config.provisioners.length == 1
	raise "Chef-solo is the only supported provisioner at the moment." unless vm_config.provisioners[0].shortcut == :chef_solo

	vm = {
		:name => "vg_#{vm_name}",
		# TODO resolve vm_type based on the provided box
		:vm_type => "ubuntu",
		:hostname => vm_name,
		:run_list => env.config.for_vm(:default).keys[:vm].provisioners[0].config.run_list
	}

	vms << vm
end

# TODO 
# - load vagrant file from the specified root directory (ie. project folder)
# - add vagrant local folder deployment as first recipe
# => detect folder type (none, git)
# => 

puts '--- '
puts vms.inspect