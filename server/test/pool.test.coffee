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
  
  pools = [
    name : 'pool_1'
    environment : 'env_1'
    vm_type : 'ubuntu'
  ]
  
  beforeEach (done) -> 
    Pool.remove {}, (err) ->
      if err then return done err
      iterator = (pool, next) -> new Pool(pool).save next
      async.forEach pools, iterator, done

  # Helpers
  microcloudRequest = (options, response) ->
    http.request _.defaults(options,
      host    : 'localhost'
      port    : config.get('server:port')
      path    : '/pools'
      method  : 'POST'
      headers : 'Content-Type': 'application/json'
    ), response
  
  describe 'Create', ->        
    it 'Creates a new pool', (done) ->
      req = microcloudRequest {}, (res) ->
        data = ""
        res.on 'data', (chunk) -> data += chunk
        res.on 'end', (err) -> 
          if err then return done err
          object = JSON.parse data
          # object.should.have.property 'name', 'provider_3'
          # object.should.have.property 'service', 'service_3'
          # object.should.have.property '_id'
          done err
      req.write JSON.stringify name: 'pool_2', environment : 'env_2', vm_type: 'osx'
      req.end()
