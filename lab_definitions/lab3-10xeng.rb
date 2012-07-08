#
# Basic lab definition - 
#
Lab.definition :lab1_10xeng do
  # VMs
  vm :web_serv do
    base_image :ubuntu_precise32
    hostname "webserv.local"
    networking do
      # 10xeng lab requires fixed ip addressing
      # interface is alias for interface_ipv4
      interface "10.0.0.1/24"
    end
  end

  # web application component with unmanaged (ie plain chef recipe based) application
  component :webapp do
    # allocate webapp to specific VM
    vm :web_serv

    # configuration, like ruby/java version configured in my_app recipe
    run_list ["role[base]", "recipe[my_app]"]
    attributes {
      :some_attr => 666
    }

    # dependency also sets up component as subscriber to component's (or related) notifications
    depends_on :acme_db 
  end  

  # DB (as actual dabase, not database server)
  component :acme_db do
    # dynamically allote VM
    # TODO naming strategy
    instance 1

    run_list ["role[pgql_dbserv"]
  end

end