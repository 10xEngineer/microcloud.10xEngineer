require 'yajl'

module TenxEngineer
  #
  # TODO validate all configuration (endpoint, ssh_key)
  # TODO deployment considerations
  #
  def config(config = "/etc/10xlabs-hostnode.json")                                
    return nil unless File.exists?(config)                                        

    config = Yajl::Parser.parse(File.open(config))

    return config
  end   

  module_function :config
end
