require 'httparty'
require 'yajl'

# FIXME duplicate with 10xengineer-node microcloud.rb
#       find a way how to re-use it
class Microcloud
  include HTTParty
  format :json

  def initialize(endpoint)
    Microcloud.base_uri HTTParty.normalize_base_uri(endpoint)
  end

  def notify(resource, resource_id, hash)
    body = create_body hash

    self.class.post("/#{resource}/#{resource_id}/notify", :body => body)
  end

private

  def create_body(hash)
    Yajl::Encoder.encode(hash)
  end

end


