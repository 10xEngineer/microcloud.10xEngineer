module.exports = ->

log 		= require("log4js").getLogger()
mongoose 	= require("mongoose")
async 		= require "async"
param_helper= require "../utils/param_helper"
broker		= require "../broker"
restify		= require "restify"
Pool 		= mongoose.model 'Pool'
Machine 	= mongoose.model 'Machine'

#
# Lab Machine commands
#
module.exports.index = (req, res, next) ->
	# FIXME not yet migrated
	res.send 500, {}

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

	getNode = (callback, results) ->
		results.pool.selectNode(callback)

	createMachine = (callback, results) ->
		data = 
			template: data.template
			server: results.node.hostname
			size: data.size
			defer: true

		creq = broker.dispatch 'lxc', 'create', data
		creq.on 'data', (message) ->
			machine = 
				uuid: message.options.uuid
				state: message.options.state

			log.info "machine=#{machine.uuid} state=#{machine.state}"

			return callback(null, machine)

		creq.on 'error', (message) ->
			log.error "unable to create machine reason='#{message.options.reason}'"

			return callback(new restify.InternalError(message.options.reason))

	saveMachine = (callback, results) ->
		data = 
			uuid: results.raw_machine.uuid
			account: req.user.account_id

			node: results.node._id
			lab: null

			state: results.raw_machine.state
			template: data.template

		machine = new Machine(data)
		machine.save (err) ->
			if err
				return next(new restify.InternalError("Unable to retrieve pools: #{err}"))

			callback(null, machine)

	# TODO LRU for pool allocation

	async.auto
		checkParams: checkParams 
		pool: ['checkParams', getPool]
		node: ['pool', getNode]
		raw_machine: ['node', createMachine]
		machine: ['raw_machine', saveMachine]

	, (err, results) ->
		if err
			return next(err)

		res.send 201, results.machine

module.exports.show = (req, res, next) ->
	# FIXME not yet migrated
	res.send 500, {}
