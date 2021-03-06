require 'mongoid'

class Vm
  include Mongoid::Document

  field :uuid, type: String
  field :state, type: String
  field :hostnode, type: String
  field :pool, type: String, default: nil
  field :type, type: String
  field :descriptor, type: Hash
  field :ip_addr, type: String, default: nil
  field :mac_addr, type: String, default: nil

  field :created_at, type: Time, default: Time.now
  field :updated_at, type: Time, default: Time.now

  # TODO touch updated_at on save
end
