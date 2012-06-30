#!/usr/bin/env ruby

require 'yajl'
require 'rest_client'

if ARGV.length == 0
  abort "node_confirm.rb node_name"
end

node = ARGV.shift

# TODO get config 10xeng.yaml
url = "http://localhost:8080/nodes/#{node}/notify"
message = {
  :action => :confirm,
  :node => {
    :hostname => "no.hostname.from.node.confirm"
  }
}

RestClient.post url, Yajl::Encoder.encode(message), :content_type => :json, :accept => :json
