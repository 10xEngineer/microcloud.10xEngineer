module.exports = ->
	
tokens = require ('./tokens')
accounts = require('./accounts')
#tenants = require('./tenants')
#microclouds = require('./microclouds')

module.exports.register = (server) ->	
	server.get '/tokens/:token', tokens.show

	server.get '/accounts/:account', accounts.show
