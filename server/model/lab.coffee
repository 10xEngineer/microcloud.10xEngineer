mongoose = require 'mongoose'
timestamps = require "../utility/timestamp_plugin"

Lab = new mongoose.Schema({
  token: String,
  #definition: ObjectId,
  terminal_server: String
})

Lab.plugin(timestamps)

tokenGenerator = (schema, callback) ->
  require("crypto").randomBytes 4, (ex,buf) ->
    token = buf.toString('hex')

    schema.path("token").set(token)

Lab.pre 'save', (next) ->
  lab = this
  if !this.token
    require("crypto").randomBytes 4, (ex,buf) ->
      lab.token = buf.toString('hex')
      next()
  else
    next()

module.exports.register = mongoose.model 'Lab', Lab

