process.env.NODE_ENV = 'test'
mongoose  = require 'mongoose'
config    = require '../config'
broker    = require '../broker'
http      = require 'http'
_         = require 'underscore'
async     = require 'async'
should    = require 'should'
zmq       = require 'zmq'

describe "Broker", ->
  socket = zmq.createSocket('rep')
  beforeEach (done) ->
    socket.bind config.get('broker'), done
    
  it 'should emit data, when message contains no error', (done) ->
    req = broker.dispatch() 
    req.on 'error', (err) -> throw err
    req.on 'data', (err) ->
      err = JSON.parse err.toString()
      err.should.include status: 'ok'
      done()
    socket.send JSON.stringify {status: 'ok'}
    
  it 'should emit error on err data', (done) ->
    req = broker.dispatch() 
    req.on 'data', (err) -> throw err
    req.on 'error', (err) ->
      err = JSON.parse err.toString()
      err.should.include status: 'false'
      done()
    socket.send JSON.stringify {status: 'false'}
    