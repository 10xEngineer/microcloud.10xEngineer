log = require("log4js").getLogger()

mongoose  = require 'mongoose'
Schema    = mongoose.Schema

timestamps    = require "../utility/timestamp_plugin"
uniqueness    = require "../utility/uniquenessPlugin"
stateMachine  = require "../utility/state_plugin"

Pool = new Schema
  name: {type: String, unique: true}
  environment: String
  vm_type: String
  # TODO owner

Pool.plugin timestamps

module.exports.schema = Pool
module.exports.register = mongoose.model 'Pool', Pool
