mongoose= require 'mongoose'
Pool    = mongoose.model 'Pool'
Vm      = mongoose.model 'Vm'
Hostnode= mongoose.model 'Hostnode'
broker  = require("../broker")

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
      ]
    , (err, pool) ->
      if err 
        helper.errResponse err
      else 
        log.info "Pool '#{pool.name}' saved"
        res.send pool
    
  destroy : (req, res, next) ->
    res.send "pool_destroy NOT IMPLEMENTED"
  addserver : (req, res, next) ->
    data = JSON.parse req.body
    Pool.findOne name: poolName = req.params.pool, (err, pool) ->
  	  if err
  	    return helper.handleErr res, err
      unless pool then return helper.handleErr res, 
        msg: "No such Pool with name '#{poolName}' found"
        code: 404
      Hostnode.findOne server_id: server_id = data.server_id, (err, server) ->
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
    dataReq = JSON.parse req.body
    if _.isUndefined(dataReq.vms) or _.isEmpty dataReq.vms then return res.send []
    async.auto
  	  # Firstly look if the pool exists
  	  findPool: (next) ->
      	Pool.findOne name: poolName = req.params.pool, (err, doc) ->
      	  unless doc then next
            msg: "No such Pool with name '#{poolName}' found"
            code: 404
          else 
            next null, doc
            
      # Check all available Hostnodes for current pool
      availableHostnodes: ['findPool', (next, results) -> 
          Hostnode.find _pools: results.findPool, next
        ]
        
      # Check parallely all available prepared VM, which are in that pool
      availableVMs: ['findPool', (next, results) ->
        iterator = (vm, cb) ->
          query = 
            state: 'prepared'
            pool: results.findPool._id
          Vm.findAndModify query, [], $set: state: 'locked', {}, cb
        async.map dataReq.vms, iterator, next
        ]
        
    	prepare: ['availableHostnodes', 'availableVMs', (next, results) ->
        # Compare available found VMs with requested VMs
        avms = _.without results.availableVMs, undefined
        if avms && avms.length is dataReq.vms.length
          next null, avms
        # Now if there are not enough VMs, send a request to prepare them      	  
        else
          countToPrepare = dataReq.vms.length - avms.length
          if _.isEmpty results.availableHostnodes then next
            msg: "The Pool #{results.findPool.name} needs hostnodes to prepare #{countToPrepare} VMs but doesn't have any."
            code: 400
          # TODO here create new prepared VMs
          next 
            msg: "Not enough VMs available"
            code: 400
    	  ]
    	
    	allocated: ['prepare', (next, results) ->
    	  avms = results.prepare
    	  iterator = (avm, _next) ->
    	    data = 
            id: avm.uuid
            server: avm.server.hostname
  	      broker.dispatch avm.server.type, 'allocate', data, (message) ->  	        
            if message.status is 'ok' 
              return _next() 
            _next new Error message.options.reason
          
    	  async.forEach avms, iterator, next
    	  ]
    	
    	, (err, results) ->
    	  console.log err
    	  if err
      	  helper.handleErr res, err
        else
      	  res.send 200
  	
  deallocate: (req, res, next) ->
    res.send "pool_deallocate NOT IMPLEMENTED"
  get: (req, res, next) ->
    res.send "pool_get NOT IMPLEMENTED"
