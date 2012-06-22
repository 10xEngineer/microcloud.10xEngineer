mongoose = require 'mongoose'
timestamps = require "../utility/timestamp_plugin"
ObjectId = mongoose.Schema.ObjectId

Lab = new mongoose.Schema({
  token: String,
  definition: ObjectId,
  # TODO to be defined later
  user: String,
  terminal_server: String,
  lab_attrs: {}
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

