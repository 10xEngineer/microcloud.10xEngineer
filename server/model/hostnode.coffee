mongoose = require 'mongoose'
timestamps = require "../utility/timestamp_plugin"

Hostnode = new mongoose.Schema(
  server_id : {type: String, unique: true}
  hostname: String,
  provider: String,
  type: String,
  state: {type: String, default: 'new'}
  token: String
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

#Hostnode.plugin(timestamps)

module.exports.register = mongoose.model 'Hostnode', Hostnode


