path = require "path"
mongoose = require("mongoose")
Provider = mongoose.model('Provider')

vagrant = (next) ->
  # vagrant provider
  vagrant_root = path.dirname(__filename)

  vagrant_def = {
    name: 'vagrant',
    service: 'vagrant',
    data: [{'env': vagrant_root}]
  }

  vagrant = new Provider(vagrant_def)
  vagrant.save (err) ->
    if err
      console.log "Unable to create vagrant provider: #{err.message}"
1
module.exports.seed = vagrant
