module.exports = ->

mongoose = require("mongoose")
log = require("log4js").getLogger()
Provider = mongoose.model('Provider')

module.exports.index = (req, res, next) ->
  Provider.find {}, {_id: 0, "meta": 0}, (err, doc) ->
    res.send doc

module.exports.create = (req, res, next) ->
  data = JSON.parse req.body

  provider = new Provider(data)
  provider.save (err) ->
    if err
      log.error "Unable to save provider: #{err.message}"

      res.send 409, err.message
    else
      log.info "Provider '#{provider.name}' saved"
      res.send provider

module.exports.show = (req, res, next) ->
  Provider.findOne {name: req.params.provider}, (err, doc) ->
    if doc
      res.send doc
    else
      res.send 404, 'Provider not found'

module.exports.destroy = (req, res, next) ->
  Provider.remove {name: req.params.provider}, ->
      res.send 200
      
