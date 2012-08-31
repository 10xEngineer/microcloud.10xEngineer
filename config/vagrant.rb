require 'yajl'

module TenxEngineer
  def endpoint(config = File.join(File.dirname(__FILE__), "../config/10xlabs-hostnode.json"))
    config = Yajl::Parser.parse(File.open(config))

    config["endpoint"]
  end
  
  module_function :endpoint
end
