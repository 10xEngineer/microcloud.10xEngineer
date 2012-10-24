api = require './api/index'
auth = require("./utils/auth")

module.exports.registerRoutes = (server) ->	
	#server.get '/ping', commands.get_ping

	# Lab Templates

	# Lab Pools
	server.get '/pools', api.pools.index
	server.get '/pools/:pool', auth.verify('_internal', api.pools.show)
	server.post '/pools/:pool/nodes', api.nodes.create

	# Lab Machines
	server.post '/machines', api.machines.create
	
