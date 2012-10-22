module.exports = ->
	
tokens = require ('./tokens')
#tenants = require('./tenants')
#microclouds = require('./microclouds')

module.exports.register = (server) ->	
	server.get '/tokens/:token', tokens.show
