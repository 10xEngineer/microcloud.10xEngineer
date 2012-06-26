process.env.NODE_ENV = 'test'
mongoose  = require 'mongoose'
config    = require '../config'
http      = require 'http'
_         = require 'underscore'
async     = require 'async'
should    = require 'should'

mongoose.connect "mongodb://#{config.get 'mongodb:host'}/#{config.get 'mongodb:dbName'}"


describe "Providers", ->
  # Start up microcloud server in test mode
  require '../../microcloud'
  Provider = mongoose.model 'Provider'
  
  providers = [
    name    : 'provider_1'
    service : 'service_1'
    data    : env: 'Some-data_1'
  , 
    name    : 'provider_2'
    service : 'service_2'
    data    : env: 'Some-data_2'
  ]
  
  beforeEach (done) -> 
    Provider.remove {}, (err) ->
      if err then return done err
      iterator = (provider, next) -> new Provider(provider).save next
      async.forEach providers, iterator, done
      
  # Helpers
  microcloudRequest = (options, response) ->
    http.request _.defaults(options,
      host    : 'localhost'
      port    : config.get('server:port')
      path    : '/providers'
      method  : 'POST'
      headers : 'Content-Type': 'application/json'
    ), response
    
  # Tests
  describe 'Index', ->
    it 'Returns list of providers', (done) ->
      http.get 
        host: 'localhost'
        port: config.get('server:port')
        path: '/providers'
      , (res) ->
        data = ""
        res.on 'data', (chunk) -> data += chunk
        res.on 'end', (err) -> 
          object = JSON.parse data
          object[0].should.have.property 'name', 'provider_1'
          object[0].should.have.property 'service', 'service_1'
          object[1].should.have.property 'name', 'provider_2'
          object[1].should.have.property 'service', 'service_2'
          done err
  
  describe 'Create', ->        
    it 'Creates a new provider', (done) ->
      req = microcloudRequest {}, (res) ->
        data = ""
        res.on 'data', (chunk) -> data += chunk
        res.on 'end', (err) -> 
          if err then return done err
          object = JSON.parse data
          object.should.have.property 'name', 'provider_3'
          object.should.have.property 'service', 'service_3'
          object.should.have.property '_id'
          done err
      req.write JSON.stringify name: 'provider_3', service: 'service_3'
      req.end()
      
    it 'Creates a new provider with the same name, only if the previous one is soft deleted', (done) ->
      req = microcloudRequest {}, (res) ->
        data = ""
        res.on 'data', (chunk) -> data += chunk
        res.on 'end', (err) -> 
          if err then return done err
          object = JSON.parse data
          object.should.have.property 'name', 'provider_1'
          object.should.have.property 'service', 'service_1'
          object.should.have.property '_id'
          Provider.find (err, docs) ->
            docs.should.have.length 3
            done err
      req.write JSON.stringify name: 'provider_1', service: 'service_1'
      
      delReq = microcloudRequest 
        path  : '/providers/provider_1'
        method: 'DELETE'
      , (res) -> 
        res.on 'end', (err) -> req.end()
      delReq.end()
      
    it 'Won\'t create a new provider without a name', (done) ->
      req = microcloudRequest {}, (res) ->
        data = ""
        res.should.have.status 400
        res.on 'data', (chunk) -> data += chunk
        res.on 'end', (err) -> 
          if err then return done err
          object = JSON.parse data
          Provider.find (err, docs) -> 
            docs.should.have.length 2
            done err
      req.write JSON.stringify service: 'service_3'
      req.end()
      
    it 'Won\'t create a new provider without a service name', (done) ->
      req = microcloudRequest {}, (res) ->
        data = ""
        res.should.have.status 400
        res.on 'data', (chunk) -> data += chunk
        res.on 'end', (err) -> 
          if err then return done err
          object = JSON.parse data
          Provider.find (err, docs) -> 
            docs.should.have.length 2
            done err
      req.write JSON.stringify name: 'provider_3'
      req.end()
      
    it 'Won\'t create a new provider with the same name', (done) ->
      req = microcloudRequest {}, (res) ->
        data = ""
        res.should.have.status 400
        res.on 'data', (chunk) -> data += chunk
        res.on 'end', (err) -> 
          if err then return done err
          object = JSON.parse data
          Provider.find (err, docs) -> 
            docs.should.have.length 2
            done err
      req.write JSON.stringify name: 'provider_1', service: 'service_1'
      req.end()
  
  describe 'Destroy', ->
    it 'Soft deletes the record, i.e., it change deleted_at meta key', (done) ->
      req = microcloudRequest 
        path  : '/providers/provider_1'
        method: 'DELETE'
      , (res) ->
        data = ""
        res.should.have.status 200
        res.on 'end', (err) -> 
          if err then return done err            
          Provider.find (err, docs) -> 
            if err then return done err
            docs.should.have.length 2
            Provider.findOne name:'provider_1', (err, doc) ->
              should.exist doc.meta.deleted_at
              done err
              
      # Firstly check, if there isn't deleted_at timestamp
      # then finish the request above by req.end()
      Provider.findOne name:'provider_1', (err, doc) ->
        if err then return done err
        should.not.exist doc.meta.deleted_at
        req.end()
  