log = require("log4js").getLogger()
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
    confirm: (node, data) ->
      node.hostname = data.hostname

      if !node.hostname
        log.error("Unable to confirm hostnode=#{node.server_id} reason='Hostname not provided'")
        return "failed"
    
      log.info("confirmed hostnode=#{node.server_id} hostname=#{node.hostname}") 
      return "running"

    something: (node, data) ->
      console.log("didn't start xxx")
      
      return "failed"

  "running":
    confirm: (node, data) ->
      console.log("confirmed; yet again")

    fail: (node, data) ->
      console.log("failed!")
      
      return "failed"

module.exports.register = mongoose.model 'Hostnode', Hostnode


