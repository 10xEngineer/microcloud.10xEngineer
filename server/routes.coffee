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
	server.get '/providers/:provider/nodes', commands.nodes.index

	#
	# server/hostnode management
	#
	server.post '/nodes/:provider', commands.nodes.create
	server.get '/nodes/:node_id', commands.nodes.show
	server.del '/nodes/:node_id', commands.nodes.destroy
	server.post '/nodes/:node_id/notify', commands.nodes.notify

	#
	# VMs
	#
	# TODO ambiguous definition server_id vs vm_id
	server.get '/vms/:node_id', commands.vms.index
	server.post '/vms/:node_id', commands.vms.create
	server.post '/vms/:vm/notify', commands.vms.updates

  #
  # Lab management
  #

  # -- original
	# lab definition
	# TODO visible on course token based authorization
	server.get '/defs/', commands.definitions.index
	server.get '/defs/:lab_definition_id', commands.definitions.show
	server.post '/defs', commands.definitions.create
	server.del '/defs/:lab_definition_id', commands.definitions.destroy

	# lab provisioning
  # TODO client should be able to pass additional data for allocate (attributes
  #      passed via UI, or config, to customize instances)
  #
	server.post '/defs/:lab_definition_id/labs', commands.definitions.allocate
	server.get '/labs/:lab_id', commands.labs.show

	# ----------- to be refactored/implemented

	# nowjs notification (subscribe/unsubscribe) - TODO review
	server.post '/subscribe/:userid', commands.notifications.subscribe
	server.post '/unsubscribe/:userid', commands.notifications.unsubscribe

	# notification support

	#
	# virtual lab VM pool management
	#
	# TODO define a model
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
	# Requirements
	# 1. create/show/destroy pool
	# 2. add/remove server to pool /pool/:pool/servers REST resource
	# 
  # Use cases
  # 1. Create Pool (specify name, default vm_type, environment)
  # 2. Get Pool
  # 3. Destroy Pool
  # 4. Assign server/hostnode to the pool (node can be used for provisioning of the 
  #    VMs required by pool). 
  #    # TODO server can be within 1..N pools (different vm_types, hypervisor?)
  #    # TODO automatically try to assign VMs to a pools server belongs?
  # 5. Remove server/hostnode from the pool
  # 6. Created N prepared VMs within the pool (find servers and round-robin way allocate
  #    necessary VMs)
  # 7. Allocate VM (allocate single VM for Lab instance)
  #    Will notify specified lab once the allocation finished/failed.
  #    If not enough VMs is available it might try prepare new ones (TODO later).
  # 8. Deallocate VMs (mark VMs as used, will be removed as part of housekeeping)
	server.post '/pools', commands.pool.create
	server.del '/pools/:pool', commands.pool.destroy
	server.get '/pools/:pool/status', commands.pool.status
	server.get '/pools/:pool/startup', commands.pool.startup
	server.get '/pools/:pool/shutdown', commands.pool.shutdown
	# add/remove an ec2 instance to the pool
	server.get '/pools/:pool/addserver/:server', commands.pool.addserver
	server.del '/pools/:pool/servers/:server', commands.pool.removeserver
	# add/remove an LXC instance to the ec2 server in the pool
	server.get '/pools/:pool/allocate', commands.pool.allocate
	server.get '/pool/:server/:container/deallocate', commands.pool.deallocate

  #server.get '/server/start/:destination', commands.server.start
  #server.get '/server/stop/:destination/:server', commands.server.stop
  #server.get '/server/stop/:destination', commands.server.stop
  #server.get '/server/status/:destination/:server', commands.server.status
  #server.get '/server/status/:destination', commands.server.status
  #server.get '/server/restart/:destination/:server', commands.server.restart
  #server.get '/server/restart/:destination', commands.server.restart

	#
	# lxc container verbs
	#server.get '/containers/create', commands.container.create
	#server.get '/containers/:container/delete', commands.container.delete
	#server.get '/containers/:container/clone', commands.container.clone
	#server.get '/containers/:container/start', commands.container.start
	#server.get '/containers/:container/stop', commands.container.stop
	#server.get '/containers/:container/info', commands.container.info
	#server.get '/containers/:container/save', commands.container.save
	#server.get '/containers/:container/restore', commands.container.restore
	# build the chef server default config using chef
	#server.get '/containers/:container/init', commands.container.init
	# optional?) expose a service in a container through the firewall
	#server.get '/containers/:container/expose-service', commands.container.exposeservice

	# set resource limits
	#server.get '/containers/:container/set-cpu-limit', commands.container.setcpulimit
	#server.get '/containers/:container/set-cpu-affinity', commands.container.setcpuaffinity
	#server.get '/containers/:container/set-ram-limit', commands.container.setramlimit
	#server.get '/containers/:container/set-swap-limit', commands.container.setswaplimit
	#server.get '/containers/:container/set-file-limit', commands.container.setfilelimit
	#server.get '/containers/:container/set-network-limit', commands.container.setnetworklimit
