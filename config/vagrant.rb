require 'yaml'

module TenxEngineer
  def endpoint(config = File.join(File.dirname(__FILE__), "../config/10xlabs-hostnode.yaml"))
    config = YAML::load(File.open(config))

    config["endpoint"]
  end
  
  module_function :endpoint
end
