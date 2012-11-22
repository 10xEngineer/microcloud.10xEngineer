api = require './api/index'
auth = require("../utils/auth")

# TODO rails like resource helper (CRUD)

module.exports.registerRoutes = (server) ->	
	server.get 		'/ping', api.status.ping

	# Lab Templates
	server.get 		'/templates', api.templates.index

	# Lab Pools
	server.get 		'/pools', api.pools.index
	server.get 		'/pools/:pool', auth.verify('_internal', api.pools.show)
	server.post 	'/pools/:pool/nodes', api.nodes.create

	# Lab Machines
	server.post 	'/machines', api.machines.create
	server.get 		'/machines', api.machines.index
	server.get 		'/machines/:machine', api.machines.show
	server.del 		'/machines/:machine', api.machines.destroy

	server.get 		'/machines/:machine/processes', api.machines.ps_exec

	# TODO get machine by token
	# auth.verify('_internal', 
	server.get 		'/machines/token/:token', api.machines.show_by_token

	# Snapshots
	server.get 		'/snapshots', api.snapshots.index_all
	#server.post		'/snapshots', api.snapshots.create_persistent
	server.get 		'/machines/:machine/snapshots', api.snapshots.index
	server.post 	'/machines/:machine/snapshots', api.snapshots.create
	server.put 		'/machines/:machine/snapshots', api.snapshots.revert
	server.del 		'/machines/:machine/snapshots/:snapshot', api.snapshots.destroy

	server.get 		'/proxy_users/:user', api.proxy_users.show

	# Statistics
	server.get		'/stats/gecko',	api.status.gecko_widget


