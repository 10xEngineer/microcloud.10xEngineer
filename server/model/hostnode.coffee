mongoose = require 'mongoose'

#
#

HostnodeSchema = new mongoose.Schema(
  hostname: {type: String, unique: true},
  provider: String,
  type: String,
  state: {type: String, default: 'new'}
  token: String,

  # TODO make this re-usable
  meta: {
    created_at: Date
    updated_at: Date
  }
)

module.exports.register = mongoose.model 'Hostnode', HostnodeSchema
