mongoose = require 'mongoose'
timestamps = require "../utility/timestamp_plugin"
state_machine = require "../utility/state_plugin"

Hostnode = new mongoose.Schema(
  server_id : {type: String, unique: true}
  hostname: String,
  provider: String,
  type: String,
  token: String
)

Hostnode.plugin(timestamps)
Hostnode.plugin(state_machine, 'new')

Hostnode.statics.find_by_server_id = (id, callback) ->
  this.findOne {server_id: id}, callback

Hostnode.statics.paths = ->
  "new":
    confirm: (data) ->
      console.log("confirmed xxx!")
      console.log data

      return "running"

    something: (data) ->
      console.log("didn't start xxx")
      
      return "failed"

  "running":
    confirm: (data) ->
      console.log("confirmed; yet again")

    fail: (data) ->
      console.log("failed!")
      
      return "failed"

module.exports.register = mongoose.model 'Hostnode', Hostnode


