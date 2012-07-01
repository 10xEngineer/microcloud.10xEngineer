require 'mongoid'

class Vm
  include Mongoid::Document

  field :id, type: String
  field :state, type: String
  field :pool, type: String
  field :type, type: String
  field :descriptor, type: Hash
  field :ip_addr, type: String
  field :mac_addr, type: String

  # TODO timestamps
end
