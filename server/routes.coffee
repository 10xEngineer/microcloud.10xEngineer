commands = require './commands/commands'

# FIXME all resources should be re-use same logic + have callback to modify behaviour
#       something like resources in rails
# FIXME unify responses / response codes

module.exports.registerRoutes = (server) ->	
	#
	# internal/diagnostic commands
	#
	server.get '/ping', commands.get_ping
	server.post '/ping', commands.post_ping
	server.get '/broker/ping', commands.broker_ping

	#
	# compilation service
	#
	server.get '/sandboxes', commands.sandboxes.index
	server.post '/sandboxes', commands.sandboxes.create
	server.post '/sandboxes/:sandbox/exec', commands.sandboxes.execute
	server.del '/sandboxes/:sandbox', commands.sandboxes.destroy

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
	server.get '/nodes', commands.nodes.index
	server.get '/nodes/:node_id', commands.nodes.show
	server.del '/nodes/:node_id', commands.nodes.destroy
	server.post '/nodes/:node_id/notify', commands.nodes.notify

	#
	# VMs
	#
	# TODO ambiguous definition server_id vs vm_id
	server.get '/nodes/:node_id/vms', commands.vms.index
	server.get '/vms/:vm', commands.vms.get
	server.post '/vms/:node_id', commands.vms.create
	server.post '/vms/:vm/notify', commands.vms.updates
	server.post '/vms/:vm/bootstrap', commands.vms.bootstrap
	server.post '/vms/:vm/stop', commands.vms.stop
	server.del '/vms/:vm', commands.vms.destroy

	#
	# Key management
	#
	server.post '/keys', commands.keys.create
	server.get '/keys/:key', commands.keys.show
	server.del '/keys/:key', commands.keys.destroy

	#
	# Lab management
	#
	# TODO subject to heavy refactoring
	#
	# use-cases
	# 1. create new lab (from scratch)
	# 2. clone existing lab
	# 3. push new lab definition (from compilation service)
	# 4. switch to particular version (release/rollback)
	#
	# basic commands
	server.post '/labs', commands.labs.create
	server.get '/labs/:lab', commands.labs.show
	server.del '/labs/:lab', commands.labs.destroy
	server.get '/labs/:lab/archive', commands.labs.archive
	server.get '/labs/:lab/vms', commands.labs.get_vms
	server.get '/labs/:lab/vms/:vm', commands.labs.get_vm
	server.get '/labs/:lab/versions', commands.labs.show_versions
	server.post '/labs/:lab/versions', commands.labs.submit_version
	#server.get '/labs/:lab/versions/:version', commands.labs.show
	server.post '/labs/:lab/versions/:version/release', commands.labs.release_version
	#server.get '/labs/:lab/versions/compare/:ver_from...:ver_to', commands.labs.compare

	#
	# NEW deploy specific labs/cookbooks
	#
	#server.get '/:owner/'
	#server.get '/:owner/:lab'
	#server.get '/:owner/:lab/versions'
	#server.get '/:owner/:lab/versions/:version'
	#server.get '/:owner/cookbooks'
	#server.get '/:owner/cookbooks/:cookbook'
	#server.get '/:owner/cookbooks/:cookbook/versions'
	#server.get '/:owner/cookbooks/:cookbook/versions/:versions'
	#
	#server.get '/cookbooks' -> redirect to default user's cookbooks

	#
	# actions
	#server.post '/labs/:lab', commands.labs.update

	# ---------------- original -----------------------------------------
	# lab definition
	# TODO visible on course token based authorization
	#server.get '/defs/', commands.definitions.index
	#server.get '/defs/:lab_definition_id', commands.definitions.show
	#server.post '/defs', commands.definitions.create
	#server.del '/defs/:lab_definition_id', commands.definitions.destroy

	# lab provisioning
	# TODO client should be able to pass additional data for allocate (attributes
	#      passed via UI, or config, to customize instances)
	#
	#server.post '/defs/:lab_definition_id/labs', commands.definitions.allocate
	#server.get '/labs/:lab_id', commands.labs.show

	#
	# cookbook management (chef style)
	#
	# server.get '/cookbooks'
	# server.get '/cookbooks/:cookbook', commands.cookbooks.show
	# server.get '/cookbooks/:cookbook/:version', commands.cookbooks.show
	# 

	# 
	# microcloud events
	#
	# TODO need to provide clear separation between events (10xlabs based) and
	#      notifications (towards UI/API clients)
	#
	server.post '/events', commands.events.accept

	# ----------- to be refactored/implemented

	# nowjs notification (subscribe/unsubscribe) - TODO review
	server.post '/subscribe/:userid', commands.notifications.subscribe
	server.post '/unsubscribe/:userid', commands.notifications.unsubscribe
	
	server.post '/notification', commands.notifications.send
	

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
  # 4. Assign hostnode to the pool (node can be used for provisioning of the 
  #    VMs required by pool). 
  #    # TODO server can be within 1..N pools (different vm_types, hypervisor?)
  #    # TODO automatically try to assign VMs to a pools server belongs?
  # 5. Remove hostnode from the pool
  # 6. Created N prepared VMs within the pool (find servers and round-robin way allocate
  #    necessary VMs)
  # 7. Allocate VM (allocate single VM for Lab instance)
  #    Will notify specified lab once the allocation finished/failed.
  #    If not enough VMs is available it might try prepare new ones (TODO later).
  # 8. Deallocate VMs (mark VMs as used, will be removed as part of housekeeping)
	server.post '/pools', commands.pool.create
	server.del '/pools/:pool', commands.pool.destroy
	server.get '/pools/:pool', commands.pool.get
	# add/remove an ec2 instance to the pool
	server.post '/pools/:pool/nodes', commands.pool.addserver
	server.del '/pools/:pool/nodes/:server_id', commands.pool.removeserver
	# add/remove an LXC instance to the ec2 server in the pool
	server.post '/pools/:pool/allocate', commands.pool.allocate
	server.post '/pool/:server/:container/deallocate', commands.pool.deallocate

  #server.get '/server/start/:destination', commands.server.start
  #server.get '/server/stop/:destination/:server', commands.server.stop
  #server.get '/server/stop/:destination', commands.server.stop
  #server.get '/server/status/:destination/:server', commands.server.status
  #server.get '/server/status/:destination', commands.server.status
  #server.get '/server/restart/:destination/:server', commands.server.restart
  #server.get '/server/restart/:destination', commands.server.restart

