# Wrapper
Redis = require '../utility/Redis'
# Origin npm library
redis = require 'redis'

describe 'Redis Wrapper', ->
  writer = redis.createClient()
  reader = redis.createClient()
  
  it 'runs redis functions on reader and writer', (done) ->
    r = new Redis 
      writer: writer
      reader: reader
    r.set 'foo', 'bar', (err, val) ->
      r.get 'foo', (err, val) ->
        val.should.eql 'bar'
        done()
    
  it 'runs redis functions on writer (if there is no reader)', (done) ->
    r = new Redis 
      writer: writer
    r.set 'foo', 'bar', (err, val) ->
      r.get 'foo', (err, val) ->
        val.should.eql 'bar'
        done()
    
    