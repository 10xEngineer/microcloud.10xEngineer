class ServiceClient
  constructor: ->
    @socket = require('zmq').socket 'req'
    @socket.connect require('nconf').get('broker')

  send: (request) -> @socket.send JSON.stringify request

module.exports = ServiceClient
