process.env.NODE_ENV = 'test'
mongoose  = require 'mongoose'
config    = require '../config'
http      = require 'http'
_         = require 'underscore'
async     = require 'async'
should    = require 'should'

mongoose.connect "mongodb://#{config.get 'mongodb:host'}/#{config.get 'mongodb:dbName'}"

describe "Pool", ->
  # Start up microcloud server in test mode
  require '../../microcloud'
  Pool = mongoose.model 'Pool'
  Hostnode = mongoose.model 'Hostnode'
  Vm = mongoose.model 'Vm'
  
  pools = [
    name : 'pool_1'
    environment : 'env_1'
    vm_type : 'ubuntu'
  ]
  
  hostnodes = [
    server_id: 'server_1'
  ]
  
  vms = [
    # First VM
    uuid: 'xxxx-s121-mcma'
    state: 'prepared'
    vm_type: 'ubuntu'
    # Second VM
  , 
    uuid: 'xxxx-55363-dcas'
    state: 'prepared'
    vm_type: 'ubuntu'
    ]
  
  asyncFillDB = (Model, dataArray) ->
    (next) ->
      Model.remove {}, (err) ->
        if err then return next err
        iterator = (item, next) -> new Model(item).save next
        async.forEach dataArray, iterator, next
        
  beforeEach (done) ->
    async.parallel [  
      do -> asyncFillDB Pool, pools
      do -> asyncFillDB Hostnode, hostnodes
      do -> asyncFillDB Vm, vms
    ], (err) -> 
      if err then return done err 
      Pool.findOne name: 'pool_1', (err, pool) ->
        if err then return done err
        Vm.update {}, {pool: pool}, {multi: true}, (err) ->
          if err then done err
          Hostnode.update {}, {$push: _pools: pool}, done
    
  # Helpers
  microcloudRequest = (options, response) ->
    http.request _.defaults(options,
      host    : 'localhost'
      port    : config.get('server:port')
      path    : '/pools'
      method  : 'POST'
      headers : 'Content-Type': 'application/json'
    ), (res) -> 
      res.data = ""
      res.on 'data', (chunk) -> res.data += chunk
      response res
  
  describe '-X POST /pools', ->        
    it 'creates a new pool', (done) ->
      req = microcloudRequest {}, (res) ->
        res.should.have.status 200
        res.on 'end', (err) -> 
          if err then return done err
          object = JSON.parse res.data
          object.should.have.property 'name', 'pool_2'
          object.should.have.property 'environment', 'env_2'
          object.should.have.property 'vm_type', 'osx'
          done err
      req.write JSON.stringify name: 'pool_2', environment : 'env_2', vm_type: 'osx'
      req.end()
      
              
  describe '-X POST /pools/:pool/servers', ->        
    it 'creates a reference between hostnode and pool (on the hostnodes side)', (done) ->
      req = microcloudRequest path: '/pools/pool_1/servers', (res) ->
        res.should.have.status 200
        Pool.findOne name: 'pool_1', (err, pool) -> 
          if err then return done err
          Hostnode.findOne server_id: 'server_1', ['_pools'], (err, hostnode) ->
            hostnode._pools.should.include pool._id
            done err
      req.end JSON.stringify server_id: 'server_1'  
      
  describe '-X POST /pools/:pool/allocate', ->        
    it 'finds available VMs in the pool and returns them in response (pool has 2 VM and the request contains 2 VM)', (done) ->
      req = microcloudRequest path: '/pools/pool_1/allocate', (res) ->
        res.should.have.status 200
        res.on 'end', (err) -> 
          if err then return done err
          data = JSON.parse res.data  
          data.should.have.length 2
          data[0].should.include vm_type: 'ubuntu'
          data[1].should.include vm_type: 'ubuntu'
          done() 
      req.end JSON.stringify vms: [{vm_type:'ubuntu'}, {vm_type: 'ubuntu'}]
      
    it 'finds available VMs in the pool and returns them in response (pool has 2 VM and the request contains 1 VM)', (done) ->
      req = microcloudRequest path: '/pools/pool_1/allocate', (res) ->
        res.should.have.status 200
        res.on 'end', (err) -> 
          if err then return done err
          data = JSON.parse res.data  
          data.should.have.length 1
          data[0].should.include vm_type: 'ubuntu'
          done() 
      req.end JSON.stringify vms: [vm_type:'ubuntu']
      
    it 'returns empty array in case that no VM is requested', (done) ->
      req = microcloudRequest path: '/pools/pool_1/allocate', (res) ->
        res.should.have.status 200
        res.on 'end', (err) -> 
          if err then return done err
          data = JSON.parse res.data  
          data.should.be.empty
          done() 
      req.end JSON.stringify vms: []
    
    it 'finds available VMs in the pool and ask broker to dispatch remaining', (done) ->
      req = microcloudRequest path: '/pools/pool_1/allocate', (res) ->
        res.should.have.status 200
        res.on 'end', (err) -> 
          if err then return done err
          data = JSON.parse res.data
          done() 
      req.end JSON.stringify vms: [{vm_type:'ubuntu'}, {vm_type: 'ubuntu'}, {vm_type: 'ubuntu'}]
  
      
    