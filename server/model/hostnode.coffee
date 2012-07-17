log = require("log4js").getLogger()
mongoose = require 'mongoose'
Schema = mongoose.Schema
timestamps = require "../utility/timestamp_plugin"
state_machine = require "../utility/state_plugin"
http = require "http"

Hostnode = new Schema
  server_id : {type: String, unique: true}
  hostname: String
  provider: String
  type: String
  token: String
  _pools: [require('./pool').schema]

Hostnode.plugin timestamps
Hostnode.plugin state_machine, 'new'

Hostnode.statics.find_by_server_id = (id, callback) ->
  this.findOne {server_id: id}, callback

Hostnode.statics.paths = ->
  "new":
    confirm: (node, data) ->
      node.hostname = data.hostname

      if !node.hostname
        log.error("Unable to confirm hostnode=#{node.server_id} reason='Hostname not provided'")
        return "failed"
    
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

Hostnode.addListener 'afterTransition', (node, prev_state) ->
  # TODO hardcoded hostnode type decision
  # TODO replace with shared logic / wrapper / [shared] task queue (resque style)
  if node.type == "loop"
    log.debug "node=#{node.server_id} type=#{node.type} forcing VM prepare"

    # TODO configurable endpoint (or avoid HTTP call alltogether)
    opts = {
      host: 'localhost'
      port: 8080
      path: "/vms/#{node.server_id}"
      method: "POST"
    }
    
    req = http.request opts, (res) ->
      log.debug "node=#{node.server_id} type=#{node.type} action=prepare"

    req.on 'error', (e) ->
      log.error "node=#{node.server_id} type=#{node.tupe} VM prepare failed reason='#{e.message}'"

    req.end()
  
  log.info "node=#{node.server_id} changed state from=#{prev_state} to=#{node.state}"


module.exports.register = mongoose.model 'Hostnode', Hostnode

