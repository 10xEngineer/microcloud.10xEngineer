# TODO implement individual commands as objects/messages for better representation/validation

zmq = require 'zmq'
config = require('../server/config')
broker = config.get('broker')
EventEmitter = require('events').EventEmitter

class ServiceClient
	constructor: ->
		@socket = zmq.createSocket 'req'
		@socket.connect broker
		@emitter = new EventEmitter()
		
	send: (request) -> @socket.send JSON.stringify request

module.exports.service_client = ServiceClient

module.exports.dispatch = (service, action, data = {}) ->
	client = new ServiceClient
	request = 
		"service": service
		"action": action
		"options": data

	client.send request
	client.socket.on 'message', (message) ->
    _message = JSON.parse message.toString()
    if _message.status is 'ok'
      client.emitter.emit 'data', _message
    else
      client.emitter.emit 'error', _message

  client.socket.on 'error', (error) ->
    console.log "0mq socket entered error state #{error}"
    client.emitter.emit 'error', error
  
  client.emitter
