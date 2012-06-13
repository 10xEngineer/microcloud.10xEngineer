mongoose = require 'mongoose'

#
#

HostnodeSchema = new mongoose.Schema(
  server_id : {type: String, unique: true}
  hostname: String,
  provider: String,
  type: String,
  state: {type: String, default: 'new'}
  token: String,

  # TODO make this re-usable
  meta: {
    created_at: {type: Date, default: Date.now}
    updated_at: {type: Date, default: Date.now}
  }
)

module.exports.register = mongoose.model 'Hostnode', HostnodeSchema
