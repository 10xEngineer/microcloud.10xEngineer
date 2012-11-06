module.exports = ->

log 		= require("log4js").getLogger()
async 		= require 'async'
mongoose 	= require("mongoose")
broker		= require "../broker"
restify 	= require 'restify'
Machine 	= mongoose.model 'Machine'
Snapshot 	= mongoose.model 'Snapshot'
Node 		= mongoose.model 'Node'

getMachine = (callback, results) ->
	Machine
		.findOne({name: results.req.params.machine, account: results.req.user.account_id, archived: false, deleted_at: null})
		.exec (err, machine) ->
			if err
				return callback(new restify.InternalError("Unable to retrieve the list of machines: #{err}"))

			unless machine
				return callback(new restify.NotFoundError("Machine not found."))

			callback(null, machine)

getNode = (callback, results) ->
	Node
		.findOne({_id: results.machine.node.node_id})
		.exec (err, node) ->
			if err
				return callback(new restify.InternalError("Unable to retrieve machine's node: #{err}"))

			return callback(null, node)

#
# Snapshots commands
#
module.exports.index = (req, res, next) ->

	getSnapshots = (callback, results) ->
		Snapshot
			.find({machine_id: results.machine._id, deleted_at: null})
			.select({_id: 0, real_size: 0, machine_id: 0})
			.exec (err, snapshots) ->
				if err
					return callback(new restify.InternalError("Unable to retrieve the list of snapshots: #{err}"))

				callback(null, snapshots)

	async.auto
		req:		(callback) -> return callback(null, req)
		machine: 	['req', getMachine]
		snapshots: 	['machine', getSnapshots]
	, (err, results) ->
		if err
			return next(err)

		res.send results.snapshots

module.exports.create = (req, res, next) ->
	try
		data = JSON.parse req.body
	catch e
		return next(new restify.BadRequestError("Invalid data"))

	verifyName = (callback, results) ->
		return callback(null) unless data.name

		unless /[\w\-]{3,32}$/.test(data.name)
			return callback(new restify.BadRequestError("Invalid snapshot name"))

		reserved_names = ['head', 'template', 'labs', 'lab']
		if reserved_names.indexOf(data.name) >= 0
			return callback(new restify.BadRequestError("Snapshot name is reserved"))

		return callback(null)

	createSnapshot = (callback, results) ->
		broker_data = 
			server: results.node.hostname
			machine_id: results.machine.uuid

		broker_data["name"] = data.name if data.name

		sreq = broker.dispatch 'lxc', 'snapshot', broker_data
		sreq.on 'data', (message) ->
			snapshot = 
				name: message.options.name
				used_size: message.options.used_size
				real_size: message.options.real_size

			log.info "machine=#{results.machine._id} snapshot=#{snapshot.name} created"

			return callback(null, snapshot)

		sreq.on 'error', (message) ->
			log.error "unable to create snapshot machine=#{results.machine._id} reason='#{message.options.reason}'"

			return callback(new restify.InternalError(message.options.reason))

	saveSnapshot = (callback, results) ->
		snapshot = new Snapshot(results.snapshot)
		snapshot.machine_id = results.machine._id
		snapshot.account = results.machine.account
		snapshot.save (err) ->
			if err 
				return next(new restify.InternalError("Unable to save machine snapshot: #{err}"))

			return callback(null)

	async.auto
		req:		(callback) -> return callback(null, req)
		name:		['req', verifyName]
		machine:	['name', getMachine]
		node: 		['machine',getNode]
		snapshot:	['node', createSnapshot]
		store:		['snapshot', saveSnapshot]
	, (err, results) ->
		if err
			return next(err)

		res.send 201, results.snapshot

module.exports.destroy = (req, res, next) ->
	getSnapshot = (callback, results) ->
		Snapshot
			.findOne({name: req.params.snapshot, machine_id: results.machine._id, deleted_at: null})
			.exec (err, snapshot) ->
				if err
					return callback(new restify.InternalError("Unable to retrieve snapshot: #{err}"))

				unless snapshot
					return callback(new restify.NotFoundError("Snapshot not found"))

				callback(null, snapshot)

	deleteSnapshot = (callback, results) ->
		results.snapshot.delete (err) ->
			if err
				return callback(new restify.InternalError("Unable to mark snapshot as deleted: #{err}"))

			return callback(null)

	destroySnapshot = (callback, results) ->
		broker_data = 
			server: results.node.hostname
			machine_id: results.machine.uuid
			name: results.snapshot.name

		sreq = broker.dispatch 'lxc', 'delshot', broker_data
		sreq.on 'data', (message) ->
			log.info "machine=#{results.machine._id} snapshot=#{results.snapshot.name} destroyed"

			return callback(null)

		sreq.on 'error', (message) ->
			log.error "unable to destroy snapshot machine=#{results.machine._id} reason='#{message.options.reason}'"

			return callback(new restify.InternalError(message.options.reason))

	async.auto
		req:		(callback) -> return callback(null, req)
		machine:	['req', getMachine]
		node: 		['machine',getNode]
		snapshot:	['node', getSnapshot]
		deleteSnap:	['snapshot', deleteSnapshot]
		wipeSnap:	['deleteSnap', destroySnapshot]
	, (err, results) ->
		if err
			return next(err)

		res.send 200
