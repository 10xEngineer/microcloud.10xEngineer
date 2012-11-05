module.exports = ->

status 			= require('./status')	
tokens 			= require('./tokens')
accounts 		= require('./accounts')
keys 			= require('./keys')
microclouds 	= require('./microclouds')

module.exports.register = (server) ->	
	server.get 	'/ping', 				status.ping

	# Microclouds
	server.get	'/microclouds',			microclouds.index

	server.get 	'/tokens/:token', 		tokens.show
	server.get 	'/accounts/:account', 	accounts.show

	# Keys
	server.get 	'/users/:user/keys', 	keys.index
	server.post '/users/:user/keys', 	keys.create
	server.get	'/users/:user/keys/:key',keys.show
	server.del 	'/users/:user/keys/:key',keys.destroy

