Vagrant::Config.run do |config|
  # default Vagrant box - 10xeng-precise32
  config.vm.box = '10xeng-precise32'

  # define ports to forward to host
  config.vm.forward_port 8080, 8080
  
  # additional shared folders
  # microcloud root for hostnode
  config.vm.share_folder "10xeng_root", "/var/lib/10xeng", "."
  # use for hostnode CLI tool development
  #config.vm.share_folder "cli", "/cli", "/Users/radim/Projects/10xeng/10xengineer-node"

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
    chef.add_role 'base'
    chef.add_role 'hostnode'

    # override configuration
    chef.json = {
      :microcloud => {
        :endpoint => "http://localhost:8080/"
      }
    }
  end
end
