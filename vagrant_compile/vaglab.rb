#!/usr/bin/env ruby

require 'vagrant'

# re-use compilation source code
$:.unshift File.join(File.dirname(__FILE__), "../compilation/")
require 'definition/metadata'
require 'definition/vm'

abort "usage: vaglab.rb path-to-vagrantfile" unless ARGV.length == 1

begin
	user_name = `git config user.name`
	user_email = `git config user.email`
rescue Errno::ENOENT
	puts "Unable to retrieve GIT configuration! Please make sure GIT is installed and properly configured."
	puts
	puts "Resources:"
	puts "https://help.github.com/articles/setting-your-username-in-git"
	puts "https://help.github.com/articles/setting-your-email-in-git"
	abort
end

root = File.expand_path(ARGV.shift)
vagrant_file = File.join(root, "Vagrantfile")
unless File.exists? vagrant_file
	abort "Unable to open #{vagrant_file}"
end

# setup environment
env = Vagrant::Environment.new(:cwd => root)

# build VMs
vms = []

env.vms.each do |vm_name, vagrant_vm|
	vm_config = env.config.for_vm(vm_name.to_sym).keys[:vm]

	# validation

	raise "Multiple provisioners not supported" unless vm_config.provisioners.length == 1
	raise "Chef-solo is the only supported provisioner at the moment." unless vm_config.provisioners[0].shortcut == :chef_solo

	vm = Vm.new "vg_#{vm_name}" do
		base_image "ubuntu"
		run_list env.config.for_vm(:default).keys[:vm].provisioners[0].config.run_list
		hostname vm_name
	end

	vms << vm
end

metadata = Metadata.new nil, nil do
	handler "TenxLabs::ChefHandler"
	version "0.0.1"

	maintainer user_name
	maintainer_email user_email
end

# TODO 
# - load vagrant file from the specified root directory (ie. project folder)
# - add vagrant local folder deployment as first recipe
# => detect folder type (none, git)
# => 

puts '--- '
puts vms.inspect