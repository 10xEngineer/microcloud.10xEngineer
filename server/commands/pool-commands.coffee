mongoose= require 'mongoose'
Pool    = mongoose.model 'Pool'
Vm      = mongoose.model 'Vm'
Hostnode= mongoose.model 'Hostnode'
broker  = require("../broker")
config  = require '../config'

async   = require 'async'
http    = require 'http'
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
              msg : "Unable to save pool: #{err.message}"
              code: 500
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
      Hostnode.findOne server_id: server_id = data.server_id, (err, hostnode) ->
        if err
          return helper.handleErr res, err
        unless hostnode then return helper.handleErr res, 
          msg: "No such hostnode with server_id '#{server_id}' found"
          code: 404
        hostnode.pool = pool
        hostnode.save (err) ->
          res.send 200
  removeserver : (req, res, next) ->
    query = 
      server_id: server_id = req.params.server_id
    update = 
      $set: pool: null
    Hostnode.update query, update, (err, hostnode) ->
      console.log hostnode
      if err
        return helper.handleErr res, err
      unless hostnode then return helper.handleErr res, 
        msg: "No such hostnode with server_id '#{server_id}' found"
        code: 404
      res.send 200
  allocate  : (req, res, next) ->
    dataReq = JSON.parse req.body
    if _.isUndefined(dataReq.vms) or _.isEmpty dataReq.vms then return res.send []
    
    # Steps of Async.auto
	  # Firstly look if the pool exists
    findPool = (next) ->
    	Pool.findOne name: poolName = req.params.pool, (err, doc) ->
    	  unless doc then next
          msg: "No such Pool with name '#{poolName}' found"
          code: 404
        else 
          next null, doc
          
    # Check all available Hostnodes for current pool
    availableHostnodes = ['findPool', (next, results) -> 
      Hostnode.find pool: results.findPool._id, next
    ]
      
    # Check parallely all available prepared VM, which are in that pool
    availableVMs = ['findPool', (next, results) ->
      iterator = (vm, cb) ->
        query = 
          state: 'prepared'
          pool: results.findPool._id
        Vm.findAndModify query, [], $set: state: 'locked', {}, cb
      async.map dataReq.vms, iterator, next
      ]
      
    prepare = ['availableHostnodes', 'availableVMs', (next, results) ->
      # Compare available found VMs with requested VMs
      avms = _.without results.availableVMs, undefined
      if avms && avms.length is dataReq.vms.length
        next null, avms
      # Now if there are not enough VMs, send a request to prepare them      	  
      else
        countToPrepare = dataReq.vms.length - avms.length
        if _.isEmpty results.availableHostnodes then return next
          msg: "The Pool #{results.findPool.name} needs hostnodes to prepare #{countToPrepare} VMs but doesn't have any."
          code: 400
        # We've got hostnodes, pool -> let's ask for new VM
    
        # This is the iterator which goes through hostnodes in the pool
        # and call request for a new VM on them
        iterator = (node, forEachNext) ->
          forEachNext.failCounter ?= 0
          opt = {node, forEachNext}
          if forEachNext.failCounter > 3 then forEachNext
            msg: "Problem while creating a new VM on node #{node._id}"
            code: 500 
          countToPrepare--
          req = http.request
            port    : config.get('server:port')
            path    : "/vms/#{node.server_id}"
            method  : 'POST'
            headers : 'Content-Type': 'application/json'
          , (res) -> createVmRequest res, opt
          req.end JSON.stringify {pool: results.findPool._id}  
        createVmRequest = (res, opt) ->
          unless res.statusCode is 200 then countToPrepare++
          data = ""
          res.on 'data', (chunk) -> data += chunk
          res.on 'end', -> finishVmRequest data, opt
        finishVmRequest = (data, opt) -> 
          {node, forEachNext} = opt
          vm = JSON.parse data
          avms.push vm
          fn = 
            if countToPrepare is 0 
              -> forEachNext()
            else
              forEachNext.failCounter++
              iterator
          # TODO
          # Immediatelly lock the VM                  
        nodes = results.availableHostnodes[0...countToPrepare]
        async.forEach nodes, iterator, (err) ->
          next err, avms
    ]
  	
    allocate = ['prepare', (next, results) ->
      avms = results.prepare
      iterator = (avm, _next) ->
        data = 
          id: avm.uuid
          server: avm.server.hostname
        req = broker.dispatch avm.server.type, 'allocate', data
        req.on 'data', (message) ->  	        
          if message.status is 'ok' 
            return _next() 
          _next new Error message.options.reason
      async.forEach avms, iterator, next
    ]
  	
    async.auto
      findPool: findPool
      availableHostnodes: availableHostnodes
      availableVMs: availableVMs
      prepare: prepare
      allocate: allocate
    , (err, results) -> 
        console.log err
        if err
          helper.handleErr res, err
        else
          res.send 200
  	
  deallocate: (req, res, next) ->
    query =
      server: req.params.server
      container: req.params.container
    # TODO ask broker to deallocate
    res.send "pool_deallocate NOT IMPLEMENTED"
  get: (req, res, next) ->
    res.send "pool_get NOT IMPLEMENTED"
