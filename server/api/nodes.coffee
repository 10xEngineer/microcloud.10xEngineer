module.exports = ->

log 		= require("log4js").getLogger()
mongoose 	= require("mongoose")
async 		= require "async"
Pool		= mongoose.model('Pool')
Node 		= mongoose.model('Node')
par_helper  = require "../utils/param_helper"
restify		= require "restify"

module.exports.create = (req, res, next) ->
	try
		data = JSON.parse req.body
	catch e
		return next(new restify.BadRequestError("Invalid data"))

	getPool = (callback) ->
		Pool.find_by_name req.params.pool, (err, pool) ->
			if err
				return callback(new restify.NotFoundError("Pool not found"))

			callback(null, pool)

	verifyParams = (callback) ->
		par_helper.checkPresenceOf data, ['hostname','provider','rsa_key'], callback

	verifyNode = (callback, results) ->
		Node.find_by_hostname data.hostname, (err, node) ->
			if err
				return callback(new restify.InternalError(err))

			if node
				return callback(new restify.ConflictError("Node #{data.hostname} already registered"))

			return callback()

	saveNode = (callback, results) ->
		node = new Node(data)
		node.pool = results.pool
		node.save (err) ->
			if err
				return callback(new restify.InternalError("Unable to save node: #{err}"))

			log.info "node=#{node.hostname} created"

			callback(null, node)

	addToPool = (callback, results) ->
		node_abbr = 
			hostname: data.hostname
			node_ref: results.node._id

		results.pool.nodes.push(node_abbr)
		results.pool.save (err) ->
			if err
				return callback(new restify.InternalError("Unable to add node to the pool: #{err}"))

		callback()

	# TODO add pool to allocation statistics
	#
	# - add node
	# - remove node

	async.auto
		pool: getPool
		params: ['pool', verifyParams]
		verifyNode: ['params', verifyNode]
		node: ['verifyNode', saveNode]
		addToPool: ['node', addToPool]
	, (err, results) ->
		if err
			return next(err)

		res.send results.node




