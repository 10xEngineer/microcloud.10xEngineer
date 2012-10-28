module.exports = ->

log 		= require("log4js").getLogger()
mongoose 	= require("mongoose")
async 		= require "async"
param_helper= require "../utils/param_helper"
broker		= require "../broker"
restify		= require "restify"
hostname	= require "../utils/hostname"
config 		= require("../config")
mgmt_api 	= require("../api/mgmt/client")
Node 		= mongoose.model 'Node'
Pool 		= mongoose.model 'Pool'
Machine 	= mongoose.model 'Machine'

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

	getPool = (callback, results) ->
		Pool.find_by_name data.pool, (err, pool) ->
			if err
				return callback(new restify.NotFoundError("Pool not found"))

			callback(null, pool)

	getKey = (callback, results) ->
		key_name = data.key || "default"
		mgmt_api.keys.show key_name, req.user.id, (err, key) ->
			if err 
				return callback(new restify.InternalError("Unable to retrieve SSH key: #{err}"))

			unless key
				return callback(new restify.NotFoundError("Specified key '#{key_name}' not found"))

			return callback(null, key)
				
	getNode = (callback, results) ->
		results.pool.selectNode(callback)

	validateMachine = (callback, results) ->
		unless data.name
			return callback(null)

		Machine
			.findOne({name: data.name, account: req.user.account_id, archived: false})
			.where("meta.deleted_at").equals(null)
			.exec (err, machine) ->
				if machine
					return callback(new restify.ConflictError("Machine '#{data.name}' already exists!"))

				return callback(null)

	createMachine = (callback, results) ->
		broker_data = 
			template: data.template
			server: results.node.hostname
			size: data.size
			defer: true
			name: data.name || hostname.generate()
			authorized_keys: results.key.public_key

		creq = broker.dispatch 'lxc', 'create', broker_data
		creq.on 'data', (message) ->
			machine = 
				uuid: message.options.uuid
				state: message.options.state
				name: message.options.name

			log.info "machine=#{machine.uuid} state=#{machine.state}"

			return callback(null, machine)

		creq.on 'error', (message) ->
			log.error "unable to create machine reason='#{message.options.reason}'"

			return callback(new restify.InternalError(message.options.reason))

	saveMachine = (callback, results) ->
		data = 
			uuid: results.raw_machine.uuid
			name: results.raw_machine.name

			account: req.user.account_id
			# TODO why results.node.node_ref doesn't work
			node: results.node["node_ref"]
			lab: null

			state: results.raw_machine.state
			template: data.template

			ssh_proxy: [results.proxy]

		machine = new Machine(data)
		machine.save (err) ->
			if err
				return next(new restify.InternalError("Unable to retrieve pools: #{err}"))

			callback(null, machine)

	createProxy = (callback, results) ->
		Machine.create_proxy results.key, req.user, (err, proxy) ->
			if err
				return callback(new restify.InternalError(err.message))

			return callback(null, proxy)

	# TODO LRU for pool allocation

	async.auto
		checkParams: checkParams 
		pool: ['checkParams', getPool]
		key: ['pool', getKey]
		node: ['key', getNode]
		proxy: ['key', createProxy]
		validate: ['proxy', validateMachine]
		raw_machine: ['validate', createMachine]
		machine: ['raw_machine', saveMachine]

	, (err, results) ->
		if err
			return next(err)

		res.send 201, results.machine

module.exports.show = (req, res, next) ->
	gateway = config.get "microcloud:gateway"

	getMachine = (callback, results) ->
		Machine
			.findOne({account: req.user.account_id, name: req.params.machine, archived: false})
			.select({_id: 0, account: 0, node: 0, archived: 0, __v: 0})
			.exec (err, machine) ->
				if err
					return callback(new restify.InternalError("Unable to retrieve machine: #{err}"))

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

		return callback(null, machine)

	async.auto
		machine: getMachine
		data: ['machine', buildMachineData]
	, (err, results) ->
		res.send 200, results.data

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
			.findOne({_id: results.machine.node})
			.exec (err, node) ->
				if err
					return callback(new restify.InternalError("Unable to retrieve machine's node: #{err}"))

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
		results.machine.meta.deleted_at = Date.now()
		results.machine.save (err) ->
			if err
				return next(new restify.InternalError("Unable to update machine: #{err}"))

			callback(null)

	removeProxy = (results) ->
		SSHProxy.findById results.machine.ssh_proxy, (err, proxy) ->
			if err
				log.warn("Unable to retrieve proxy=#{proxy._id}")
				return

			proxy.meta.deleted_at = Date.now()
			proxy.save (err) ->
				if err
					log.warn("Unable to remove proxy=#{proxy._id}")
				
				log.debug("proxy=#{proxy._id} removed")
				return

	async.auto
		machine: getMachine
		node: ['machine', getNode]
		destroy: ['node', destroyMachine]
		update: ['destroy', updateMachine]

	, (err, results) ->
		if err
			return next(err)

		res.send 200

		removeProxy(results)
