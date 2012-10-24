module.exports = ->
	
status 			= require('./status')
tokens 			= require('./tokens')
accounts 		= require('./accounts')
#microclouds 	= require('./microclouds')

module.exports.register = (server) ->	
	server.get '/ping', status.ping
	server.get '/tokens/:token', tokens.show

	server.get '/accounts/:account', accounts.show
