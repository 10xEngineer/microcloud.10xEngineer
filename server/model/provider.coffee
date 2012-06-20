mongoose = require 'mongoose'
# TODO needs to be loaded after Provider
Hostnode = mongoose.model('Hostnode')

ProviderDataSchema = new mongoose.Schema({
})

Provider = new mongoose.Schema(
  name: {type: String, unique: true},
  service: String,
  data: {env: String},

  # TODO make this re-usable
  meta: {
    created_at: {type: Date, default: Date.now}
    updated_at: {type: Date, default: Date.now}
  }
)

Provider.statics.for_server = (server, callback) ->
  Hostnode.findOne {server_id: server}, (err, node) ->
    if err
      return callback(err)

    if node
      mongoose.model("Provider").findOne {name: node.provider}, (err, provider) ->
        if err
          return callback(err)
      
        if provider
          return callback(null, provider)
        else
          return callback(new Error("Invalid provider for server '#{server}"))
    else
      return callback(new Error("Server not found"))

module.exports.register = mongoose.model 'Provider', Provider

