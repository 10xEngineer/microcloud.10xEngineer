# TODO implement individual commands as objects/messages for better representation/validation

zmq = require 'zmq'
config = require('../server/config')
EventEmitter = require('events').EventEmitter

class ServiceClient
	constructor: (broker) ->
		@socket = zmq.createSocket 'req'
		@socket.connect broker
		@emitter = new EventEmitter()
		
	send: (request) -> @socket.send JSON.stringify request

module.exports.service_client = ServiceClient

module.exports.dispatch = (service, action, data = {}, broker = config.get('broker')) ->
	request = 
		"service": service
		"action": action
		"options": data

	raw_dispatch(request, broker)

raw_dispatch = (data, broker) ->
	client = new ServiceClient(broker)
	client.send data
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

module.exports.raw_dispatch = raw_dispatch