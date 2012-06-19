mongoose = require 'mongoose'

Hostnode = new mongoose.Schema(
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

Hostnode.statics.find_by_server_id = (id, callback) ->
  this.findOne {server_id: id}, callback

Hostnode.method 'confirm', ->
  console.log this
  this.state = 'running'

  hostnode = this
  this.save (err) ->
    if err
      console.log "Unable to update #{hostnode.server_id}"
    else
      console.log "Hostnode #{hostnode.server_id} confirmed"

module.exports.register = mongoose.model 'Hostnode', Hostnode


