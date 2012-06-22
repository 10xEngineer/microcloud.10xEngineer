commands = require './commands/commands'

# FIXME all resources should be re-use same logic + have callback to modify behaviour
#       something like resources in rails
# FIXME unify responses / response codes

module.exports.registerRoutes = (server)->	
	#
	# internal/diagnostic commands
	#
	server.get '/ping', commands.get_ping
	server.post '/ping', commands.post_ping
	server.get '/broker/ping', commands.broker_ping

	# 
	# provider management
	#
	server.get '/providers', commands.providers.index
	server.get '/providers/:provider', commands.providers.show
	server.post '/providers', commands.providers.create
	server.del '/providers/:provider', commands.providers.destroy
	server.get '/providers/:provider/servers', commands.server.index

	#
	# server/hostnode management
	#
	# TODO server.get '/servers', ...
	server.post '/servers/:provider', commands.server.create
	server.get '/servers/:server', commands.server.show
	server.del '/servers/:server', commands.server.destroy
	server.post '/servers/:server/notify', commands.server.notify

	#
	# VMs
	#
	# TODO ambiguous definition server_id vs vm_id
	server.get '/vms/:server_id', commands.vms.index
	server.post '/vms/:server_id', commands.vms.create
	server.post '/vms/:vm/notify', commands.vms.updates

	# ----------- to be refactored/implemented

	# nowjs notification (subscribe/unsubscribe) - TODO review
	server.post '/subscribe/:userid', commands.notifications.subscribe
	server.post '/unsubscribe/:userid', commands.notifications.unsubscribe

	# lab definition
	# TODO visible on course token based authorization
	server.get '/labs', commands.labs.index
	server.get '/labs/:lab_definition_id', commands.labs.show
	server.post '/labs', commands.labs.create
	server.del '/labs/:lab_definition_id', commands.labs.destroy

	# lab provisioning
	server.post '/labs/:lab_definition_id', commands.labs.allocate

	# notification support

	#
	# virtual lab VM pool management
	#
	# Pool represents a 'availability zone' for VM provisioning. Its characteristics
	# include attributes like:
	# * name (id)
	# * environment (custom - generally dev/test/staging, or team level)
	# * location (???)
	# * vm_type (ubuntu, windows, os/390_hercules, etc.); the underlying technology
	# * 
	#
	# Hostnodes (and providers) are assigned to provide/manage VMs for particular pool.
	#
	# Pools should have strict ALCs and auditing (together with other objects)
	# https://trello.com/card/microcloud-org-security/4fc57db3060a0e9f4339d07d/29
	# 
	# Examples:
	#
	# acme-dev-ubuntu-apac-1 (company, ubuntu_1204_1 template, dev environment, comms room 1)
	# acme-dev-ubuntu-ec2-apac-1 (...) and so on
	# 
	#
	server.get '/pool/status', commands.pool.status
	server.get '/pool/startup', commands.pool.startup
	server.get '/pool/shutdown', commands.pool.shutdown
	# add/remove an ec2 instance to the pool
	server.get '/pool/addserver', commands.pool.addserver
	server.get '/pool/:server/remove', commands.pool.removeserver
	# add/remove an LXC instance to the ec2 server in the pool
	server.get '/pool/:server/allocate', commands.pool.allocate
	server.get '/pool/:server/:container/deallocate', commands.pool.deallocate

	server.get '/server/start/:destination', commands.server.start
	server.get '/server/stop/:destination/:server', commands.server.stop
	server.get '/server/stop/:destination', commands.server.stop
	server.get '/server/status/:destination/:server', commands.server.status
	server.get '/server/status/:destination', commands.server.status
	server.get '/server/restart/:destination/:server', commands.server.restart
	server.get '/server/restart/:destination', commands.server.restart

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
