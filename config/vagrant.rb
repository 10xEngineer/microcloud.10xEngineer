require 'yaml'

module TenxEngineer
  def endpoint(config = File.join(File.dirname(__FILE__), "../config/10xeng.yaml"))
    config = YAML::load(File.open(config))

    config["hostnode"]["endpoint"]
  end
  
  module_function :endpoint
end
