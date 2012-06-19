commands = require './commands/commands'

# FIXME all resources should be re-use same logic + have callback to modify behaviour
#       something like resources in rails
# FIXME unify responses / response codes

module.exports.registerRoutes = (server)->
	server.get '/ping', commands.get_ping
	server.post '/ping', commands.post_ping

	server.get '/broker/ping', commands.broker_ping

	# nowjs notification (subscribe/unsubscribe)
	server.post '/subscribe/:userid', commands.notifications.subscribe
	server.post '/unsubscribe/:userid', commands.notifications.unsubscribe

	# clie command
	server.get '/command/exectest', commands.test_cli_exec 
	#TODO: spawn  for tail ... etc streaming still doesn't work)
	#server.get '/command/spawntest', commands.test_cli_spawn
	# run a shell command
	server.get '/command/:cmd/:args', commands.cli.call_cli
	server.head '/command/:cmd/:args', commands.cli.call_cli

	# provider management
	server.get '/providers', commands.providers.index
	server.get '/providers/:provider', commands.providers.show
	server.post '/providers', commands.providers.create
	server.del '/providers/:provider', commands.providers.destroy

	# lab definition
	# TODO visible on course token based authorization
	server.get '/labs', commands.labs.index
	server.get '/labs/:lab_definition_id', commands.labs.show
	server.post '/labs', commands.labs.create
	server.del '/labs/:lab_definition_id', commands.labs.destroy

	# lab provisioning
	server.post '/labs/:lab_definition_id', commands.labs.allocate

	# notification support

	# virtual lab VM pool management
	server.get '/pool/status', commands.pool.status
	server.get '/pool/startup', commands.pool.startup
	server.get '/pool/shutdown', commands.pool.shutdown
	# add/remove an ec2 instance to the pool
	server.get '/pool/addserver', commands.pool.addserver
	server.get '/pool/:server/remove', commands.pool.removeserver
	# add/remove an LXC instance to the ec2 server in the pool
	server.get '/pool/:server/allocate', commands.pool.allocate
	server.get '/pool/:server/:container/deallocate', commands.pool.deallocate

	#  vagrant|ec2) server instance verbs
	# TODO: Allow specific instances, not just the last one started
	# TODO: Fix status calls for vagrant and ec2
	# TODO: Fix feedback and termination to client for all calls
	# RDM - making it a bit more RESTful 
	server.post '/servers/:provider', commands.server.create
	server.get '/servers/:provider/:server', commands.server.show
	server.del '/servers/:provider/:server', commands.server.destroy
	# TODO refactor together with other notifications
	# TODO refactor route
	server.post '/server/:server/notify', commands.notifications.dummy

	server.get '/server/start/:destination', commands.server.start
	server.get '/server/stop/:destination/:server', commands.server.stop
	server.get '/server/stop/:destination', commands.server.stop
	server.get '/server/status/:destination/:server', commands.server.status
	server.get '/server/status/:destination', commands.server.status
	server.get '/server/restart/:destination/:server', commands.server.restart
	server.get '/server/restart/:destination', commands.server.restart

	# TODO re-design VM support (that's how containers are called in 10xEngineer terminology)
	#
	# POST /vms/:server - prepare VM
	# GET /vms/:server - list VMs per particular server
	# 
	
	server.get '/vms/:server_id', commands.vms.index
	server.post '/vms/:server_id', commands.vms.create

	#
	# lxc container verbs
	server.get '/containers/create', commands.container.create
	server.get '/containers/:container/delete', commands.container.delete
	server.get '/containers/:container/clone', commands.container.clone
	server.get '/containers/:container/start', commands.container.start
	server.get '/containers/:container/stop', commands.container.stop
	server.get '/containers/:container/info', commands.container.info
	server.get '/containers/:container/save', commands.container.save
	server.get '/containers/:container/restore', commands.container.restore
	# build the chef server default config using chef
	server.get '/containers/:container/init', commands.container.init
	# optional?) expose a service in a container through the firewall
	server.get '/containers/:container/expose-service', commands.container.exposeservice

	# set resource limits
	server.get '/containers/:container/set-cpu-limit', commands.container.setcpulimit
	server.get '/containers/:container/set-cpu-affinity', commands.container.setcpuaffinity
	server.get '/containers/:container/set-ram-limit', commands.container.setramlimit
	server.get '/containers/:container/set-swap-limit', commands.container.setswaplimit
	server.get '/containers/:container/set-file-limit', commands.container.setfilelimit
	server.get '/containers/:container/set-network-limit', commands.container.setnetworklimit
