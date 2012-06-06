require 'bundler/setup'
require 'yajl'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..')

def build_request(service, action, options = {})
  request = {
    "service" => service,
    "action" => action,
    "options" => options
  }

  #Yajl::Encoder.encode(request)
end

RSpec.configure do |config|
end
