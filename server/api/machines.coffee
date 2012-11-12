module.exports = ->

log 			= require("log4js").getLogger()
mongoose 		= require("mongoose")
async 			= require "async"
param_helper	= require "../utils/param_helper"
broker			= require "../broker"
restify			= require "restify"
hostname		= require "../utils/hostname"
config 			= require("../config")
platform_api	= require("../api/platform")
ip 				= require("../utils/ip")
token 			= require("../utils/token")
Node 			= mongoose.model 'Node'
Pool 			= mongoose.model 'Pool'
Machine 		= mongoose.model 'Machine'
Snapshot 		= mongoose.model 'Snapshot'

# FIXME refactor getMachine for better reusability (first attempt failed on inconsistent mongo
#       persistence, ie. destroy wasn't updating object properly).

#
# Lab Machine commands
#
module.exports.index = (req, res, next) ->
	# TODO temporarily hidden labs

	Machine
		.find({account: req.user.account_id})
		# TODO schema initially didn't have archived field 
		.or([{archived: false}, {archived: null}])
		.select({_id:0, lab:0, node: 0, account: 0 })
		.exec (err, machines) ->
			if err
				return callback(new restify.InternalError("Unable to retrieve the list of machines: #{err}"))

			res.send machines

module.exports.create = (req, res, next) ->
	# TODO validate limits
	# TODO optional account_id to create VM under another account (RBAC needed)
	# TODO ability to defer machine start

	try
		data = JSON.parse req.body
	catch e
		return next(new restify.BadRequestError("Invalid data"))

	checkParams = (callback, results) -> 
		param_helper.checkPresenceOf data, ['template','size','pool'], callback

	verifyLimits = (callback, results) ->
		Machine.getCurrentUsage req.user, (err, count) ->
			if err
				return callback(new restify.InternalError("Unable to verify resources: #{err}"))

			unless count < req.user.limits.machines
				return callback(new restify.RequestThrottledError("Machine resource limit exceeded!"))
			
			return callback(null)

	generateIP = (callback, results) ->
		return callback(null, ip.generate())

	getPool = (callback, results) ->
		Pool.find_by_name data.pool, (err, pool) ->
			if err
				return callback(new restify.NotFoundError("Pool not found"))

			callback(null, pool)

	getKey = (callback, results) ->
		key_name = data.key || "default"
		platform_api.keys.show key_name, req.user.id, (err, key) ->
			if err
				unless err.statusCode == 404
					return callback(new restify.InternalError("Unable to retrieve SSH key: #{err}"))
				else
					key = null

			unless key
				return callback(new restify.NotFoundError("SSH key '#{key_name}' not found"))

			return callback(null, key)
				
	getNode = (callback, results) ->
		results.pool.selectNode (err, node) ->
			unless node
				return callback(new restify.ServiceUnavailableError("Hostnode capacity exceeded"))

			return callback(err, node)

	validateMachine = (callback, results) ->
		unless data.name
			return callback(null)

		Machine
			.findOne({name: data.name, account: req.user.account_id, archived: false})
			.where("deleted_at").equals(null)
			.exec (err, machine) ->
				if machine
					return callback(new restify.ConflictError("Machine '#{data.name}' already exists!"))

				return callback(null)

	createMachine = (callback, results) ->
		custom_data = "ipv4=#{results.ip}"

		broker_data = 
			template: data.template
			server: results.node.hostname
			size: data.size
			defer: false
			name: data.name || hostname.generate()
			authorized_keys: results.key.public_key
			data: custom_data

		creq = broker.dispatch 'lxc', 'create', broker_data
		creq.on 'data', (message) ->
			machine = 
				uuid: message.options.uuid
				state: message.options.state
				name: message.options.name
				snapshots: message.options.snapshots

			log.info "machine=#{machine.uuid} state=#{machine.state}"

			return callback(null, machine)

		creq.on 'error', (message) ->
			log.error "unable to create machine reason='#{message.options.reason}'"

			return callback(new restify.InternalError(message.options.reason))

	saveMachine = (callback, results) ->
		node_data = 
			node_id: results.node["node_ref"]
			hostname: results.node["hostname"]

		port_mapping = {}

		if data.port_mapping
			port_mapping["http"] = data.port_mapping.http if data.port_mapping.http

		data = 
			uuid: results.raw_machine.uuid
			name: results.raw_machine.name

			account: req.user.account_id
			# TODO why results.node.node_ref doesn't work
			node: node_data
			lab: null

			state: results.raw_machine.state
			template: data.template
			token: results.token

			port_mapping: port_mapping

			ssh_proxy: [results.proxy]

			ipv4_address: results.ip

		machine = new Machine(data)
		machine.save (err) ->
			if err
				return next(new restify.InternalError("Unable to retrieve pools: #{err}"))

			callback(null, machine)

	saveSnapshots = (callback, results) ->
		async.forEach results.raw_machine.snapshots, (snap_data, iter_next) ->
			snapshot = new Snapshot(snap_data)
			snapshot.machine_id = results.machine._id
			snapshot.account = results.machine.account

			snapshot.save (err) ->
				if err
					return iter_next(err)

				log.debug "snapshot=#{snap_data.name} machine=#{results.machine._id} state=created"

				iter_next(null)
		, (err) ->
			if err
				return next(new restify.InternalError("Unable to save snapshot: #{err}") )

			return callback(null)

	createProxy = (callback, results) ->
		Machine.create_proxy results.key, req.user, (err, proxy) ->
			if err
				return callback(new restify.InternalError(err.message))

			return callback(null, proxy)

	# TODO LRU for pool allocation

	async.auto
		params: checkParams
		limits: ['params', verifyLimits]
		pool: ['limits', getPool]
		ip: ['pool', generateIP]
		key: ['ip', getKey]
		node: ['key', getNode]
		proxy: ['key', createProxy]
		token: token.random
		validate: ['proxy', validateMachine]
		raw_machine: ['validate', createMachine]
		machine: ['raw_machine', 'token', saveMachine]
		snapshots: ['machine', saveSnapshots]

	, (err, results) ->
		if err
			return next(err)

		res.send 201, results.machine

module.exports.show = (req, res, next) ->
	gateway = config.get "microcloud:gateway"
	deploy_domain = config.get "deploy"

	getMachine = (callback, results) ->
		Machine
			.findOne({account: req.user.account_id, name: req.params.machine, archived: false})
			.select({_id: 0, account: 0, node: 0, archived: 0, __v: 0})
			.exec (err, machine) ->
				if err
					return callback(new restify.InternalError("Unable to retrieve machine: #{err}"))

				unless machine
					return callback(new restify.NotFoundError("No machine found."))

				return callback(null, machine.toObject())

	buildMachineData = (callback, results) ->
		machine = results.machine

		# replace ssh_proxy 
		proxies = []
		for proxy in machine.ssh_proxy

			if proxy.user == req.user.id
				delete proxy.user
				delete proxy._id

				proxy["gateway"] = gateway

				proxies.push(proxy)

		delete machine.ssh_proxy

		machine["ssh_proxy"] = proxies[0]
		machine["microcloud"] = deploy_domain

		return callback(null, machine)

	async.auto
		machine: getMachine
		data: ['machine', buildMachineData]
	, (err, results) ->
		if err
			next(err)
			
		res.send 200, results.data

module.exports.show_by_token = (req, res, next) ->
	getMachine = (callback, results) ->
		Machine
			.findOne({token: req.params.token, archived: false, deleted_at: null})
			.exec (err, machine) ->
				if err
					return callback(new restify.InternalError("Unable to retrieve machine: #{err}"))

				unless machine
					return callback(new restify.NotFoundError("No machine found"))

				return callback(null, machine)

	async.auto
		machine: getMachine
	, (err, results) ->
		if err
			return next(err)
			
		res.send 200, results.machine

module.exports.destroy = (req, res, next) ->
	getMachine = (callback, results) ->
		Machine
			.findOne({account: req.user.account_id, name: req.params.machine})
			.or([{archived: false}, {archived: null}])
			.exec (err, machine) ->
				if err
					return callback(new restify.InternalError("Unable to retrieve the list of machines: #{err}"))

				unless machine
					return callback(new restify.NotFoundError("Machine not found"))

				return callback(null, machine)

	getNode = (callback, results) ->
		Node
			.findOne({_id: results.machine.node.node_id})
			.exec (err, node) ->
				if err
					return callback(new restify.InternalError("Unable to retrieve machine's node: #{err}"))

				unless node
					return callback(new restify.ServiceUnavailableError("No hostnode available."))

				return callback(null, node)

	destroyMachine = (callback, results) ->
		data = 
			server: results.node.hostname
			uuid: results.machine.uuid

		creq = broker.dispatch 'lxc', 'destroy', data
		creq.on 'data', (message) ->
			log.info "machine=#{results.machine.uuid} state=destroyed"

			return callback(null)

		creq.on 'error', (message) ->
			log.error "unable to destroy machine reason='#{message.options.reason}'"

			return callback(new restify.InternalError("Unable to remove machine."))

	updateMachine = (callback, results) ->
		results.machine.state = "destroyed"
		results.machine.deleted_at = Date.now()
		results.machine.save (err) ->
			if err
				return next(new restify.InternalError("Unable to update machine: #{err}"))

			callback(null)

	async.auto
		machine: getMachine
		node: ['machine', getNode]
		destroy: ['node', destroyMachine]
		update: ['destroy', updateMachine]

	, (err, first_results) ->
		if err
			return next(err)

		# say bye to client
		res.send 200

		getSnapshots = (callback, results) ->
			Snapshot
				.find({machine_id: first_results.machine._id, deleted_at: null})
				.exec (err, snapshots) ->
					if err
						return callback(new restify.InternalError("Unable to retrieve the list of snapshots: #{err}"))

					callback(null, snapshots)

		removeSnapshots = (callback, results) ->
			# soft delete is enough as zfs destroy -r is used to delete machine dataset
			async.forEach results.snapshots, (snapshot, iter_next) ->
				snapshot.delete (err) ->
					return iter_next(err)

		async.auto
			snapshots: getSnapshots
			remove: ['snapshots', removeSnapshots]
		, (err, n_results) ->
			if err
				log.warn "unable to finish machine=#{results.machine._id} cleanup"

			log.debug "machine=#{results.machine._id} cleanup finished"

module.exports.ps_exec = (req, res, next) ->
	getMachine = (callback, results) ->
		Machine
			.findOne({account: req.user.account_id, name: req.params.machine})
			.or([{archived: false}, {deleted_at: null}])
			.exec (err, machine) ->
				if err
					return callback(new restify.InternalError("Unable to retrieve the list of machines: #{err}"))

				unless machine
					return callback(new restify.NotFoundError("Machine not found"))

				return callback(null, machine)

	execPs = (callback, results) ->
		broker_data = 
			server: results.machine.node.hostname
			uuid: results.machine.uuid

		creq = broker.dispatch 'lxc', 'ps_exec', broker_data
		creq.on 'data', (message) ->
			log.info "machine=#{results.machine.uuid} process state retrieved"

			ps = message.options

			return callback(null, ps)

		creq.on 'error', (message) ->
			log.error "unable to retrieve machine processes status reason='#{message.options.reason}'"

			return callback(new restify.InternalError(message.options.reason))

	async.auto
		machine: getMachine
		ps: ['machine', execPs]
	, (err, results) ->
		if err
			log.warn "unable to retrieve process status machine=#{results.machine._id}"

		res.send 200, results.ps

