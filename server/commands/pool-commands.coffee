mongoose= require 'mongoose'
Pool    = mongoose.model 'Pool'
Vm      = mongoose.model 'Vm'
Hostnode= mongoose.model 'Hostnode'

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
        pool = new Pool data
        pool.save (err) ->
          if err
            next 
              msg : "Unable to save provider: #{err.message}"
              code: 409
          else next null, pool
    ], (err, pool) ->
      if err 
        helper.errResponse err
      else 
        log.info "Pool '#{pool.name}' saved"
        res.send pool
    
  destroy : (req, res, next) ->
  status  : (req, res, next) ->
    Pool.findOne name: poolName = req.params.pool, ['state'], (err, doc) ->
      if err then return helper.handleErr res, err
      unless doc then return helper.handleErr res, 
        msg: "No such Pool with name '#{poolName}' found"
        code: 404
      log.info "Pool '#{poolName}' status: '#{doc}'"
      res.send doc
  startup : (req, res, next) ->
  	Pool.findOne name: req.params.pool, (err, doc) ->
  	  doc.fire 'startup', {}, (err, pool) ->
  	    if err then return helper.handleErr res, err
  	    res.send pool
  shutdown: (req, res, next) ->
    Pool.findOne name: req.params.pool, (err, doc) ->
  	  doc.fire 'shutdown', {}, (err, pool) ->
  	    if err then return helper.handleErr res, err
  	    res.send pool
  addserver : (req, res, next) ->
  	Pool.findOne {name: poolName = req.params.pool}, (err, pool) ->
  	  if err 
  	    return helper.handleErr res, err
      unless pool then return helper.handleErr res, 
        msg: "No such Pool with name '#{poolName}' found"
        code: 404
      Hostnode.findOne {server_id: server_id = req.params.server}, (err, server) ->
        if err
          return helper.handleErr res, err
        unless server then return helper.handleErr res, 
          msg: "No such Server with server_id '#{server_id}' found"
          code: 404
        server._pools.push pool
        server.save (err) ->
          res.send 200
  removeserver : (req, res, next) ->
	  res.send "pool_removeserver NOT IMPLEMENTED"
  allocate  : (req, res, next) ->
  	async.auto
  	  # Firstly look if the pool exists
  	  findPool: (next) ->
      	Pool.findOne name: poolName = req.params.pool, (err, doc) ->
      	  unless doc then next
            msg: "No such Pool with name '#{poolName}' found"
            code: 404
          else 
            pool = doc
            next()
            
      # Check all available Hostnodes for current pool
      availableHostnodes: ['findPool', (next) -> 
          Hostnodes.find pools: pool, next
        ]
        
      # Parallel with that check all available VM, which are in that pool
      availableVMs: ['findPool', (next) ->
        Vm.findAndModify state: 'prepared', _pool: pool, [], {$set: {state: 'locked'}}, {}, (err, vm) ->
          next null, vm
        ]
        
  	, (err, results) -> 
  	  unless _.isNull vms = results.availableVMs then return res.send vms
  	  # Now if there are not enough VMs, send a request to allocate them
      # therefore, we need Hostnodes to sent them requests
  	  if _.isEmpty results.availableHostnodes then helper.handlerErr
  	    msg: "The Pool #{pool.name} needs Hostnodes to allocate VMs and doesn't have any."
    # TODO: Why following line cannot stay in front of async.auto line? 
    # CoffeeScript returns Unexpected 'TERMINATOR'
    pool = null
  	
  deallocate: (req, res, next) ->
  	res.send "pool_deallocate NOT IMPLEMENTED"
