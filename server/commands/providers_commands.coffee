module.exports = ->

mongoose  = require 'mongoose'
log       = require('log4js').getLogger()
log.setLevel 'WARN' if process.env.NODE_ENV is 'test'
Provider  = mongoose.model('Provider')
_         = require 'underscore'
async     = require 'async'


helper   = require './helper'

module.exports.index = (req, res, next) ->
  Provider.find {}, {_id: 0, "meta": 0}, (err, doc) ->
    res.send doc

module.exports.create = (req, res, next) ->
  data = JSON.parse req.body
  helper.load data
  async.waterfall [
    # Firstly check if required attributes are filled
    (next) -> helper.checkPresenceOf ["name", "service"], next
    # Check if there isn't already active Provider with the same name
  , (next) -> 
    Provider.checkUniquenessOf [{name: data.name}], next
    # Now try to save
  , (next) ->
      provider = new Provider data
      provider.save (err) ->
        if err
          next 
            msg : "Unable to save provider: #{err.message}"
            code: 409
        else next null, provider
  ], (err, provider) ->
    if err 
      log.error "Unable to save provider: #{err.msg}"
      res.send err.code, err.msg
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
  log.warn "action=destroy provider='#{req.params.provider}'"
  # TODO soft delete only (need to consider security implications)
  # might be better to log events appropriately
  # @params
  #   filter, newly set values, options, callback
  Provider.find {name: req.params.provider}, (err, docs) ->
    if err 
      log.error "Unable to find the destructing provider: #{err.msg}"
      return res.send err.code, err.msg
    for doc in docs 
      doc.meta.deleted_at = Date.now()
      doc.save()
    res.send 200

