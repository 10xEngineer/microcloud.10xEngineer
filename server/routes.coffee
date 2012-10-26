api = require './api/index'
auth = require("./utils/auth")

# TODO rails like resource helper (CRUD)

module.exports.registerRoutes = (server) ->	
	server.get '/ping', api.status.ping

	# Lab Templates
	server.get '/templates', api.templates.index

	# Lab Pools
	server.get '/pools', api.pools.index
	server.get '/pools/:pool', auth.verify('_internal', api.pools.show)
	server.post '/pools/:pool/nodes', api.nodes.create

	# Lab Machines
	server.post '/machines', api.machines.create
	server.get '/machines', api.machines.index
	server.del '/machines/:machine', api.machines.destroy


	# Keys
	server.get '/keys', api.keys.index
	server.post '/keys', api.keys.create
	server.del '/keys/:key', api.keys.destroy
	
