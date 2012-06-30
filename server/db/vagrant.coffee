path = require "path"
mongoose = require("mongoose")
Provider = mongoose.model('Provider')

vagrant = ->
  # vagrant provider
  vagrant_root = path.dirname(__filename)

  vagrant_def = 
    name: 'vagrant',
    service: 'vagrant',
    handler: 'lxc',

    data: {'env': vagrant_root}

  vagrant = new Provider(vagrant_def)
  vagrant.save (err) ->
    if err
      console.log "Unable to create vagrant provider: #{err.message}"

module.exports.seed = vagrant
