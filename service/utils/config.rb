require 'yaml'

module TenxEngineer
  #
  # TODO validate all configuration (endpoint, ssh_key)
  # TODO deployment considerations
  #
  def config(config = "/etc/10xlabs-hostnode.yaml")                                
    return nil unless File.exists?(config)                                        

    config = YAML::load(File.open(config))                                        

    return config
  end   

  module_function :config
end
