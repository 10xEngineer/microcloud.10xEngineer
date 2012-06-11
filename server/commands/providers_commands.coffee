module.exports = ->

mongoose = require("mongoose")
Provider = mongoose.model('Provider')

module.exports.show = (req, res, next) ->
  console.log "provider " + req.params.provider
  Provider.findOne {name: req.params.provider}, (err, doc) ->
    if doc
      res.send doc
    else
      res.send 404, 'Provider not found'

  

  

