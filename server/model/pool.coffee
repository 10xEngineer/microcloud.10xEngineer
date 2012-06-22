log = require("log4js").getLogger()
mongoose = require 'mongoose'
timestamps = require "../utility/timestamp_plugin"
state_machine = require "../utility/state_plugin"

Pool = new mongoose.Schema(
  name: String,

  environment: String,
  vm_type: String,
  
  # TODO owner
)

Lab.plugin(timestamps)

module.exports.register = mongoose.model 'Pool', Pool
