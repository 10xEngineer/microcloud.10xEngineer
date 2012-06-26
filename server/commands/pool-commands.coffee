mongoose= require 'mongoose'
Pool    = mongoose.model 'Pool'

async   = require 'async'
_       = require 'underscore'
log     = require('log4js').getLogger()

helper  = require './helper'

module.exports = 
  create  : (req, res, next) ->
    data = JSON.parse req.body
    helper.load data
    async.waterfall [
      (next) -> helper.checkPresenceOf ["name", "environment", "vm_type"], next
    , (next) -> 
        Pool.checkUniquenessOf [{vm_type: data.vm_type}], next
    , (next) ->
        pool = new Pool data
        pool.save (err) ->
          if err
            next 
              msg : "Unable to save provider: #{err.message}"
              code: 409
          else next null, pool
    ], (err, pool) ->
      if err 
        log.error "Unable to save pool: #{err.msg}"
        res.send err.code, err.msg
      else 
        log.info "Pool '#{pool.name}' saved"
        res.send pool
    
  destroy : (req, res, next) ->
  status  : (req, res, next) ->
  	res.send "pool_status NOT IMPLEMENTED"
  startup : (req, res, next) ->
  	res.send "pool_startup NOT IMPLEMENTED"
  shutdown: (req, res, next) ->
  	res.send "pool_shutdown NOT IMPLEMENTED"
  addserver : (req, res, next) ->
  	res.send "pool_addserver NOT IMPLEMENTED"
  removeserver : (req, res, next) ->
	  res.send "pool_removeserver NOT IMPLEMENTED"
  allocate  : (req, res, next) ->
  	res.send "pool_allocate NOT IMPLEMENTED"
  deallocate: (req, res, next) ->
  	res.send "pool_deallocate NOT IMPLEMENTED"
