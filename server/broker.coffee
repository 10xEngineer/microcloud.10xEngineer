# TODO implement individual commands as objects/messages for better representation/validation

zmq = require 'zmq'
config = require('../server/config')
broker = config.get('broker')

class ServiceClient
	constructor: ->
		@socket = zmq.createSocket 'req'
		@socket.connect broker
		
	send: (request) -> @socket.send JSON.stringify request

module.exports.service_client = ServiceClient

module.exports.dispatch = (service, action, data = {}, cb) ->
	client = new ServiceClient
	request = {
		"service": service
		"action": action
		"options": data
	}

	client.send request
	client.socket.on 'message', (message) ->
		response = JSON.parse message

		cb response

  client.socket.on 'error', (error) ->
    console.log "0mq socket entered error state #{error}"
    cb "{}"
