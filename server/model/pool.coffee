log = require("log4js").getLogger()

mongoose  = require 'mongoose'
Schema    = mongoose.Schema

timestamps    = require "../utility/timestamp_plugin"
uniqueness    = require "../utility/uniquenessPlugin"
stateMachine  = require "../utility/state_plugin"

Pool = new Schema
  name: String
  environment: String
  vm_type: String
  # TODO owner

Pool.plugin timestamps
Pool.plugin uniqueness
Pool.plugin stateMachine, 'new'

Pool.statics.paths = ->
  'new':
    startup: (node, data) -> 'running'
  'running':
    confirm: (node, data) -> 
    shutdown: (node, data) -> 'down'
  'down':
    shutdown: ->

module.exports.register = mongoose.model 'Pool', Pool
