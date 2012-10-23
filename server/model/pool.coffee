log = require("log4js").getLogger()

mongoose  = require 'mongoose'
Schema    = mongoose.Schema

timestamps    = require "../utility/timestamp_plugin"

Pool = new Schema
  name: {type: String, unique: true}

  disabled: {type: Boolean, default: false}

  # TODO statistics fields

Pool.plugin timestamps

module.exports.register = mongoose.model 'Pool', Pool
