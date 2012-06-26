$LOAD_PATH.unshift File.join(File.dirname(__FILE__))

begin
  require 'config/vagrant'

  $microcloud_endpoint = TenxEngineer::MICROCLOUD_ENDPOINT
rescue LoadError
  puts
  puts "Unable to load per-user Vagrant configuration file (config/vagrant)!"
  puts
end

Vagrant::Config.run do |config|
  # default Vagrant box - 10xeng-precise32
  config.vm.box = '10xeng-precise32'

  # define ports to forward to host
  #config.vm.forward_port 8080, 8080
  config.vm.forward_port 443, 8443
  
  # additional shared folders
  # microcloud root for hostnode
  config.vm.share_folder "10xeng_root", "/var/lib/10xeng", "."
  # use for hostnode CLI tool development
  config.vm.share_folder "cli", "/cli", "/Users/radim/Projects/10xeng/10xengineer-node"
  #config.vm.share_folder "gateone", "/tmp/gateone_src", "/Users/radim/Projects/10xeng/GateOne"

  # 
  # chef-solo provisioner
  #
  config.vm.provision :chef_solo do |chef|
    # shared components
    chef.cookbooks_path = ['chef_repo/cookbooks']
    chef.roles_path = 'chef_repo/roles'

    # per project components
    chef.data_bags_path = 'data_bags'
    chef.log_level = :debug

    # guest configuration
    chef.add_role 'microcloud'
    chef.add_role 'hostnode'
    chef.add_recipe 'gateone::server'

    # override configuration
    chef.json = {
      # location of Microcloud endpoint
      :microcloud => {
        :endpoint => $microcloud_endpoint,
      },
      # hostnode configuration
      "10xeng-node" => {
        :token => "no token",
        :id => "default"
      }
    }
  end
end
