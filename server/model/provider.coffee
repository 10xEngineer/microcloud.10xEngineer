mongoose    = require 'mongoose'
# TODO needs to be loaded after Provider
Hostnode    = mongoose.model('Hostnode')
timestamps  = require "../utility/timestamp_plugin"

ProviderDataSchema = new mongoose.Schema {}

Provider = new mongoose.Schema
  name    : String
  service : String
  data    : {env: String}
  deleted_at: Date

Provider.plugin(timestamps)

Provider.statics.for_server = (server, callback) ->
  Hostnode.findOne {server_id: server}, (err, node) ->
    return callback(err) if err
    
    if node
      mongoose.model("Provider").findOne {name: node.provider}, (err, provider) ->
        return callback(err) if err
      
        if provider then callback null, provider
        else 
          callback new Error "Invalid provider for server '#{server}"
    else
      return callback new Error "Server not found"

module.exports.register = mongoose.model 'Provider', Provider

