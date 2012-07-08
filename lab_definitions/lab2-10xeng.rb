#
# Basic lab definition - 
#
Lab.definition :lab1_10xeng do
  # explicit VM definition
  # TODO how to specify resource pool (and therefore provider)?
  # TODO how to override provider settings? (instance size?)

  # vm(name, template, hostname, options)
  vm :web_serv do
    template :ubuntu
    hostname "webserv.local"
    networking do
      interface "10.0.0.1/24"
    end
  end

  vm :web_serv, :ubuntu, 'webserv.local', {
    :network => {:ip_addr => "10.0.0.1/24"}
  }

  vm :db_serv, :ubuntu, 'dbserv.local', :network => {ip_addr => "10.0.0.2/24"}


end