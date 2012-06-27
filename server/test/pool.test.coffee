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
  
  pools = [
    name : 'pool_1'
    environment : 'env_1'
    vm_type : 'ubuntu'
  ]
  
  hostnodes = [
    server_id: 'server_1'
  ]
  
  beforeEach (done) -> 
    async.parallel [
      (next) ->
        Pool.remove {}, (err) ->
          if err then return done err
          iterator = (pool, next) -> new Pool(pool).save next
          async.forEach pools, iterator, next      
      (next) ->
        Hostnode.remove {}, (err) ->
          if err then return done err
          iterator = (hostnode, next) -> new Hostnode(hostnode).save next
          async.forEach hostnodes, iterator, next
    ], done
    
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
      
  describe '-X GET /pools/:pool/status', ->        
    it 'returns status of the pool (current state of the pools state machine)', (done) ->
      req = microcloudRequest path:'/pools/pool_1/status', method: 'GET', (res) ->
        res.on 'end', (err) -> 
          if err then return done err
          object = JSON.parse res.data
          object.should.have.property 'state', 'new'
          done err
      req.end()      
    it 'returns 404 if the vm_type doesn\'t exist', (done) ->
      req = microcloudRequest path:'/pools/foobar/status', method: 'GET', (res) ->
        res.should.have.status 404
        done()
      req.end()
      
  describe '-X GET /pools/:pool/startup', ->        
    it 'puts pool in running state', (done) ->
      req = microcloudRequest path:'/pools/pool_1/startup', method: 'GET', (res) ->
        res.should.have.status 200
        res.on 'end', (err) -> 
          if err then return done err
          object = JSON.parse res.data
          object.should.have.property 'state', 'running'
          done err
      req.end()     
      
  describe '-X GET /pools/:pool/shutdown', ->        
    it 'puts pool in down state', (done) ->
      req = microcloudRequest path: '/pools/pool_1/shutdown', method: 'GET', (res) ->
        res.should.have.status 200
        res.on 'end', (err) -> 
          if err then return done err
          object = JSON.parse res.data
          object.should.have.property 'state', 'down'
          done err
      # Firstly put pool in running state
      (microcloudRequest path: '/pools/pool_1/startup', method: 'GET', (res) ->
        req.end()).end()
              
  describe '-X GET /pools/:pool/addserver/:server', ->        
    it 'creates a reference between hostnode and pool (on the hostnodes side)', (done) ->
      req = microcloudRequest path: '/pools/pool_1/addserver/server_1', method: 'GET', (res) ->
        res.should.have.status 200
        Pool.findOne name: 'pool_1', (err, pool) -> 
          if err then return done err
          Hostnode.findOne server_id: 'server_1', ['_pools'], (err, hostnode) ->
            hostnode._pools.should.include pool._id
            done err
      req.end()