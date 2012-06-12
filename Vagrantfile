Vagrant::Config.run do |config|
  config.vm.box = 'precise32'
  config.vm.customize do |vm|
    vm.memory_size = 768
  end

  # Microcloud root
  config.vm.share_folder "10xeng_root", "/var/lib/10xeng", "."

  # temporary using for toolchain development
  #config.vm.share_folder "cli", "/cli", "/Users/radim/Projects/10xeng/10xengineer-node"

  #
  # Chef provisioner configuration
  #
  config.vm.provision :chef_solo do |chef|
    # shared part
    chef.cookbooks_path = ['chef_repo/cookbooks']
    chef.roles_path = 'chef_repo/roles'

    # per project
    chef.data_bags_path = 'data_bags'
    chef.log_level = :debug


    # TODO switch to a one role
    chef.add_role 'base'
    chef.add_role 'hostnode'

    # local configuration
    chef.json = {
      :microcloud => {
        :endpoint => "http://localhost:8080/"
      }
    }
  end
end
