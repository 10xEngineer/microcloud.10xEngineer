#
# Basic lab definition - 2 VMs with no wiring whatsoever
# 
#
Lab.definition :lab1_10xeng do

  # mixin 
  include_aspect UBS::Base 

  # explicit VM definition
  # TODO how to specify resource pool (and therefore provider)?
  # TODO how to override provider settings? (instance size?)

  # TODO how to declare managed/unmanaged VM?
  #      how to declare provisioning layer?
  # TODO how to declare remote access to VM/toolchain compliance?

  vm :web_serv do
    base_image :ubuntu_precise32
    hostname "webserv.local"
    networking do
      # 10xeng lab requires fixed ip addressing
      # interface is alias for interface_ipv4
      interface :subnet_1, "10.0.0.1/24"
    end

    run_list ["recipe[ruby]", "recipe[ntpdate::client"]
    vm_attributes {
      :ruby => {
        :version => "1.9.3-p125"
      }
    }
  end

  vm :db_serv do
    base_image :ubuntu_precise32
    hostname "dbserv.local"
    network do
      # static IP address
      interface :subnet_1, "10.0.0.2/24"
    end

    run_list ["recipe[postgresql:server]"]
    vm_attributes {
      :postgresql => {
        :version => "9.1.4"
      }
    }

    # TODO how to select particular VM, or postgresql on particular VM or assigned to particular component
    on "vm::start" => DynectProvider.register_hostname

    # notification received each time PgSQL archive command is executed 
    on "postgresql::archive" => CustomLogic.archive_wal
  end


end