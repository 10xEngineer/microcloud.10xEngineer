# TODO implement individual commands as objects/messages for better representation/validation

class ServiceClient
  constructor: ->
    @socket = require('zmq').socket 'req'
    @socket.connect require('nconf').get('broker')

  send: (request) -> @socket.send JSON.stringify request

module.exports.service_client = ServiceClient

module.exports.dispatch = (service, action, data = {}, cb) ->
  client = new ServiceClient
  request = {
    service: service
    action: action
    data: data
  }

  client.send request
  client.socket.on 'message', (message) ->
    response = JSON.parse message

    cb response
